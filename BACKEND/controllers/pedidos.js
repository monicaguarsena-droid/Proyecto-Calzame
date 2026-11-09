import {
    obtenerUsuarioParaPedido,
    guardarCedulaUsuario,
    obtenerUsuariosPorCedulas,
    obtenerProductosPorIds,
    crearPedido,
    obtenerPedidos,
    actualizarEstadoPedido,
    eliminarPedidoCompleto,
    crearDetallesPedido,
    obtenerDetallesPorPedidos
} from '../modelos/pedidos.js';
import { obtenerCarritoPorUsuario, vaciarCarritoUsuario } from '../modelos/carrito.js';
import { enviarConfirmacionPedido } from '../utils/sendEmail.js';

// Estados que puede tener un pedido (la tienda solo entrega en el local)
export const ESTADOS_PEDIDO = ['Pendiente', 'Listo para recoger', 'Entregado', 'Cancelado'];

const soloDigitos = (valor) => String(valor ?? '').replace(/\D/g, '');

const parsearLista = (valor) => {
    if (Array.isArray(valor)) return valor;
    if (typeof valor === 'string' && valor.trim()) {
        try {
            const decoded = JSON.parse(valor);
            return Array.isArray(decoded) ? decoded : [];
        } catch {
            return [];
        }
    }
    return [];
};

// Foto del color comprado; si no hay, la imagen principal
const imagenPara = (producto, color) => {
    if (!producto) return '';
    const buscado = String(color ?? '').trim().toLowerCase();
    const coincide = parsearLista(producto.Colores).find(
        (c) => String(c?.color ?? '').trim().toLowerCase() === buscado && c?.imagenUrl
    );
    return coincide?.imagenUrl || producto.Imagen || '';
};

// Convierte los registros de la base de datos en el formato que usa la app
const armarPedidos = async (pedidos) => {
    if (!pedidos || pedidos.length === 0) return [];

    const pedidoIds = pedidos.map((p) => p.id);
    const cedulas = [...new Set(pedidos.map((p) => p.Usuario_Cc).filter((c) => c !== null && c !== undefined))];

    const { data: detalles, error: errorDetalles } = await obtenerDetallesPorPedidos(pedidoIds);
    if (errorDetalles) throw errorDetalles;

    const productoIds = [...new Set((detalles ?? []).map((d) => d.Producto_Id))];

    const [resProductos, resUsuarios] = await Promise.all([
        productoIds.length ? obtenerProductosPorIds(productoIds) : { data: [], error: null },
        cedulas.length ? obtenerUsuariosPorCedulas(cedulas) : { data: [], error: null }
    ]);
    if (resProductos.error) throw resProductos.error;
    if (resUsuarios.error) throw resUsuarios.error;

    const productosPorId = new Map((resProductos.data ?? []).map((p) => [String(p.id), p]));
    const usuariosPorCedula = new Map((resUsuarios.data ?? []).map((u) => [String(u.cedula), u]));

    return pedidos.map((p) => {
        const usuario = usuariosPorCedula.get(String(p.Usuario_Cc));
        const lineas = (detalles ?? []).filter((d) => String(d.Pedido_Id) === String(p.id));

        return {
            id: p.id,
            estado: p.Estado ?? 'Pendiente',
            total: Number(p.Total) || 0,
            fecha: p.Fecha_pedido ?? p.created_at ?? null,
            celular: p.Celular !== null && p.Celular !== undefined ? String(p.Celular) : '',
            metodoPago: p.Metodo_Pago ?? '',
            nombreContacto: p.Nombre_Contacto ?? '',
            cedula: p.Usuario_Cc !== null && p.Usuario_Cc !== undefined ? String(p.Usuario_Cc) : '',
            cliente: usuario ? { id: usuario.id, nombre: usuario.nombre, email: usuario.email } : null,
            detalles: lineas.map((d) => {
                const producto = productosPorId.get(String(d.Producto_Id));
                return {
                    cantidad: Number(d.Cantidad) || 0,
                    precioUnitario: Number(d.Precio_unitario) || 0,
                    subtotal: Number(d.Subtotal) || 0,
                    talla: d.talla ?? '',
                    color: d.color ?? '',
                    producto: {
                        id: d.Producto_Id,
                        nombre: producto?.Nombre ?? 'Producto eliminado',
                        imagen: imagenPara(producto, d.color)
                    }
                };
            })
        };
    });
};

// ---------- Cliente ----------

// POST /pedidos/crear  { nombre, cedula, telefono, metodo_pago }
// El pedido se arma con el carrito del usuario guardado en la base de datos.
export const postPedido = async (req, res) => {
    try {
        const usuarioId = req.usuario?.id;
        if (!usuarioId) {
            console.error('❌ Pedido: el token no trae el id del usuario. req.usuario =', req.usuario);
            return res.status(401).json({ error: 'No se pudo identificar al usuario desde el token' });
        }

        const nombreContacto = String(req.body.nombre ?? '').trim();
        const celular = soloDigitos(req.body.telefono);
        const metodoPago = String(req.body.metodo_pago ?? '').trim();

        if (celular.length < 7) {
            return res.status(400).json({ error: 'Escribe un teléfono de contacto válido' });
        }

        // 1. Usuario
        const { data: usuario, error: errorUsuario } = await obtenerUsuarioParaPedido(usuarioId);
        if (errorUsuario || !usuario) {
            return res.status(404).json({ error: 'No se encontró el usuario' });
        }

        // 2. Cédula (la tabla Pedidos se relaciona con la cédula del cliente)
        let cedula =
            usuario.cedula !== null && usuario.cedula !== undefined && String(usuario.cedula).trim() !== ''
                ? String(usuario.cedula)
                : null;

        if (!cedula) {
            const digitos = soloDigitos(req.body.cedula);
            if (digitos.length < 5) {
                return res.status(400).json({ error: 'Registra tu cédula para poder hacer el pedido' });
            }
            const { error: errorCedula } = await guardarCedulaUsuario(usuarioId, digitos);
            if (errorCedula) {
                console.error('❌ Pedido: no se pudo guardar la cédula', errorCedula);
                return res.status(409).json({
                    error: 'No se pudo guardar tu cédula. Puede que ya esté registrada en otra cuenta.'
                });
            }
            cedula = digitos;
        }

        // 3. Carrito del usuario
        const { data: carrito, error: errorCarrito } = await obtenerCarritoPorUsuario(usuarioId);
        if (errorCarrito) {
            console.error('❌ Pedido: error leyendo el carrito', errorCarrito);
            return res.status(500).json({ error: 'Error al leer tu carrito', detalle: errorCarrito.message });
        }
        if (!carrito || carrito.length === 0) {
            return res.status(400).json({ error: 'Tu carrito está vacío' });
        }

        // 4. Precios reales desde la tabla Productos (no se confía en el celular)
        const productoIds = [...new Set(carrito.map((i) => i.producto_id))];
        const { data: productos, error: errorProductos } = await obtenerProductosPorIds(productoIds);
        if (errorProductos) {
            console.error('❌ Pedido: error leyendo productos', errorProductos);
            return res.status(500).json({ error: 'Error al leer los productos', detalle: errorProductos.message });
        }
        const productosPorId = new Map((productos ?? []).map((p) => [String(p.id), p]));

        const lineas = [];
        let total = 0;
        for (const item of carrito) {
            const producto = productosPorId.get(String(item.producto_id));
            if (!producto) {
                return res.status(400).json({ error: 'Un producto de tu carrito ya no está disponible' });
            }
            const precio = Number(producto.Precio) || 0;
            const cantidad = Number(item.cantidad) || 1;
            const subtotal = precio * cantidad;
            total += subtotal;
            lineas.push({
                Producto_Id: item.producto_id,
                Cantidad: cantidad,
                Precio_unitario: precio,
                Subtotal: subtotal,
                talla: item.talla,
                color: item.color
            });
        }

        // 5. Crear el pedido
        const { data: pedidoCreado, error: errorPedido } = await crearPedido({
            usuario_cc: cedula,
            celular,
            total,
            estado: 'Pendiente',
            metodo_pago: metodoPago,
            nombre_contacto: nombreContacto || usuario.nombre
        });
        if (errorPedido || !pedidoCreado || pedidoCreado.length === 0) {
            console.error('❌ Pedido: no se pudo crear', errorPedido);
            return res.status(500).json({ error: 'Error al crear el pedido', detalle: errorPedido?.message });
        }
        const pedido = pedidoCreado[0];

        // 6. Crear los detalles (si fallan, se borra el pedido para no dejarlo incompleto)
        const { error: errorDetalles } = await crearDetallesPedido(
            lineas.map((l) => ({ ...l, Pedido_Id: pedido.id }))
        );
        if (errorDetalles) {
            console.error('❌ Pedido: no se pudieron crear los detalles', errorDetalles);
            await eliminarPedidoCompleto(pedido.id);
            return res.status(500).json({ error: 'Error al guardar los productos del pedido', detalle: errorDetalles.message });
        }

        // 7. Vaciar el carrito del usuario
        const { error: errorVaciar } = await vaciarCarritoUsuario(usuarioId);
        if (errorVaciar) console.error('⚠️ Pedido: no se pudo vaciar el carrito', errorVaciar);

        // 8. Correo de confirmación: no bloquea la respuesta si tarda o falla
        if (usuario.email) {
            Promise.resolve()
                .then(() => enviarConfirmacionPedido(usuario.email, usuario.nombre, pedido.id, total))
                .catch((error) => console.error('⚠️ Pedido: no se pudo enviar el correo de confirmación', error));
        }

        return res.status(201).json({
            message: 'Pedido creado con éxito',
            pedido: {
                id: pedido.id,
                estado: pedido.Estado ?? 'Pendiente',
                total,
                fecha: pedido.Fecha_pedido ?? pedido.created_at
            }
        });
    } catch (error) {
        console.error('❌ Pedido: error inesperado', error);
        return res.status(500).json({ error: error.message });
    }
};

// GET /pedidos/mis-pedidos  (pedidos del usuario con sesión iniciada)
export const getMisPedidos = async (req, res) => {
    try {
        const { data: usuario } = await obtenerUsuarioParaPedido(req.usuario?.id);
        if (!usuario || usuario.cedula === null || usuario.cedula === undefined) {
            return res.status(200).json({ pedidos: [] });
        }

        const { data, error } = await obtenerPedidos({ cedula: usuario.cedula });
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los pedidos', detalle: error.message });
        }
        return res.status(200).json({ pedidos: await armarPedidos(data) });
    } catch (error) {
        console.error('❌ Pedidos: error en getMisPedidos', error);
        return res.status(500).json({ error: error.message });
    }
};

// ---------- Administrador ----------

// GET /pedidos/admin
export const getPedidosAdmin = async (req, res) => {
    try {
        const { data, error } = await obtenerPedidos();
        if (error) {
            console.error('❌ Pedidos: error de Supabase', error);
            return res.status(500).json({ error: 'Error al obtener los pedidos', detalle: error.message });
        }
        return res.status(200).json({ pedidos: await armarPedidos(data) });
    } catch (error) {
        console.error('❌ Pedidos: error en getPedidosAdmin', error);
        return res.status(500).json({ error: error.message });
    }
};

// PUT /pedidos/:id/estado  { estado }
export const putEstadoPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const estado = String(req.body.estado ?? '').trim();

        if (!ESTADOS_PEDIDO.includes(estado)) {
            return res.status(400).json({ error: `Estado inválido. Usa: ${ESTADOS_PEDIDO.join(', ')}` });
        }

        const { data, error } = await actualizarEstadoPedido(id, estado);
        if (error) {
            return res.status(500).json({ error: 'Error al actualizar el estado', detalle: error.message });
        }
        if (!data || data.length === 0) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }
        return res.status(200).json({ message: 'Estado actualizado', estado });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// DELETE /pedidos/:id
export const deletePedido = async (req, res) => {
    try {
        const { data, error } = await eliminarPedidoCompleto(req.params.id);
        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el pedido', detalle: error.message });
        }
        if (!data || data.length === 0) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }
        return res.status(200).json({ message: 'Pedido eliminado' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};