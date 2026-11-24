import {
    obtenerUsuarioParaPedido,
    obtenerTokenUsuarioPorCedula,
    obtenerPedidoParaActualizar,
    guardarCedulaUsuario,
    obtenerUsuariosPorCedulas,
    obtenerProductosPorIds,
    crearPedido,
    obtenerPedidos,
    ocultarPedidoDeCliente,
    actualizarEstadoPedido,
    eliminarPedidoCompleto,
    crearDetallesPedido,
    obtenerDetallesPorPedidos,
    descontarStockPedido
} from '../modelos/pedidos.js';
import { obtenerCarritoPorUsuario, vaciarCarritoUsuario } from '../modelos/carrito.js';
import { OfertaModel } from '../modelos/ofertas.js';
import { enviarConfirmacionPedido } from '../utils/sendEmail.js';
import { calcularPrecioConDescuento, parsearDescuento } from '../utils/descuentos.js';
import { obtenerTokensAdministradores } from '../modelos/user.js';
import messaging from '../config/firebase.js';

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

const notificarStockBajo = async (productos) => {
    const productosBajos = productos.filter(
        (producto) => Number(producto.stockAnterior) >= 4 && Number(producto.stock) < 4
    );
    if (productosBajos.length === 0) return;

    try {
        const { data: administradores, error } = await obtenerTokensAdministradores();
        if (error) {
            console.error('❌ Stock bajo: no se pudieron consultar los administradores', error);
            return;
        }

        const tokens = [...new Set(
            (administradores ?? [])
                .map((administrador) => administrador.fcm_token)
                .filter((token) => typeof token === 'string' && token.length > 0)
        )];
        if (tokens.length === 0) {
            console.warn('⚠️ Stock bajo: no hay administradores con notificaciones activas');
            return;
        }

        for (const producto of productosBajos) {
            const resultados = await Promise.allSettled(
                tokens.map((token) => messaging.send({
                    notification: {
                        title: `Stock bajo: ${producto.nombre}`,
                        body: `Quedan ${producto.stock} pares de este calzado.`
                    },
                    data: {
                        tipo: 'stock_bajo',
                        productoId: String(producto.id),
                        ruta: '/admin/inventario'
                    },
                    token
                }))
            );
            for (const resultado of resultados) {
                if (resultado.status === 'rejected') {
                    console.error('❌ Stock bajo: no se pudo enviar una notificación', resultado.reason);
                }
            }
        }
    } catch (error) {
        console.error('❌ Stock bajo: error al notificar a los administradores', error);
    }
};

const notificarClientePedido = async (token, pedidoId, estado, nuevoPedido = false) => {
    if (!token) {
        console.warn(`⚠️ Pedido #${pedidoId}: el cliente no tiene un token FCM registrado`);
        return;
    }

    const mensajesPorEstado = {
        'Pendiente': 'Hemos recibido tu pedido y pronto comenzaremos a prepararlo.',
        'Listo para recoger': 'Tu pedido está listo para recoger.',
        'Entregado': 'Tu pedido ha sido entregado.',
        'Cancelado': 'Tu pedido fue cancelado.'
    };

    try {
        await messaging.send({
            notification: {
                title: nuevoPedido ? `Pedido recibido · #${pedidoId}` : `Pedido #${pedidoId}: ${estado}`,
                body: mensajesPorEstado[estado] ?? `El estado de tu pedido cambió a ${estado}.`
            },
            data: {
                tipo: nuevoPedido ? 'pedido_recibido' : 'estado_pedido',
                pedidoId: String(pedidoId),
                estado,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                route: '/pedidos'
            },
            token
        });
    } catch (error) {
        console.error(`❌ Pedido #${pedidoId}: no se pudo enviar la notificación`, error);
    }
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
            // La fecha sale de created_at (Fecha_pedido es de tipo time y solo guarda la hora)
            fecha: p.created_at ?? null,
            celular: p.Celular !== null && p.Celular !== undefined ? String(p.Celular) : '',
            metodoPago: p.Metodo_Pago ?? '',
            comprobantePago: p.Comprobante_Pago ?? '',
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
        const comprobantePago = req.file?.path ?? null;

        if (celular.length < 7) {
            return res.status(400).json({ error: 'Escribe un teléfono de contacto válido' });
        }
        if (metodoPago === 'Nequi / Bre-B (QR)' && !comprobantePago) {
            return res.status(400).json({ error: 'Adjunta la captura del pago para continuar' });
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
        let ofertasActivas;
        try {
            ofertasActivas = await OfertaModel.getActivasPorProductos(productoIds);
        } catch (error) {
            console.error('❌ Pedido: error leyendo las ofertas activas', error);
            return res.status(500).json({ error: 'Error al consultar los descuentos', detalle: error.message });
        }
        const descuentosPorProducto = new Map();
        for (const oferta of ofertasActivas) {
            const descuento = parsearDescuento(oferta.descuento);
            const productoId = String(oferta.producto_id);
            if (
                descuento !== null &&
                descuento > (descuentosPorProducto.get(productoId) ?? 0)
            ) {
                descuentosPorProducto.set(productoId, descuento);
            }
        }

        const lineas = [];
        let total = 0;
        for (const item of carrito) {
            const producto = productosPorId.get(String(item.producto_id));
            if (!producto) {
                return res.status(400).json({ error: 'Un producto de tu carrito ya no está disponible' });
            }
            const precioOriginal = Number(producto.Precio) || 0;
            const descuento = descuentosPorProducto.get(String(producto.id)) ?? 0;
            const precio = descuento > 0
                ? calcularPrecioConDescuento(precioOriginal, descuento)
                : precioOriginal;
            const cantidad = Number(item.cantidad);
            if (!Number.isInteger(cantidad) || cantidad < 1) {
                return res.status(400).json({ error: 'La cantidad solicitada no es válida' });
            }
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
            nombre_contacto: nombreContacto || usuario.nombre,
            comprobante_pago: comprobantePago
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

        // 7. Descontar el inventario de forma atómica para evitar vender más del disponible
        const cantidadesPorProducto = new Map();
        for (const linea of lineas) {
            const productoId = String(linea.Producto_Id);
            cantidadesPorProducto.set(
                productoId,
                (cantidadesPorProducto.get(productoId) ?? 0) + linea.Cantidad
            );
        }
        const { data: resultadoStock, error: errorStock } = await descontarStockPedido(
            [...cantidadesPorProducto].map(([producto_id, cantidad]) => ({
                producto_id,
                cantidad
            }))
        );
        if (errorStock || !resultadoStock) {
            console.error('❌ Pedido: no se pudo descontar el inventario', errorStock);
            const { error: errorEliminarPedido } = await eliminarPedidoCompleto(pedido.id);
            if (errorEliminarPedido) {
                console.error('❌ Pedido: no se pudo eliminar tras fallar el inventario', errorEliminarPedido);
            }
            return res.status(500).json({
                error: 'No se pudo actualizar el inventario. Intenta de nuevo.',
                detalle: errorStock?.message
            });
        }
        if (resultadoStock.success !== true) {
            const { error: errorEliminarPedido } = await eliminarPedidoCompleto(pedido.id);
            if (errorEliminarPedido) {
                console.error('❌ Pedido: no se pudo eliminar por stock insuficiente', errorEliminarPedido);
            }
            return res.status(409).json({
                error: `${resultadoStock.producto_nombre}: solo quedan ${resultadoStock.stock_disponible} pares disponibles. Ajusta la cantidad del pedido.`
            });
        }

        await notificarStockBajo(resultadoStock.productos ?? []);

        void notificarClientePedido(
            usuario.fcm_token,
            pedido.id,
            pedido.Estado ?? 'Pendiente',
            true
        );

        // 8. Vaciar el carrito del usuario
        const { error: errorVaciar } = await vaciarCarritoUsuario(usuarioId);
        if (errorVaciar) console.error('⚠️ Pedido: no se pudo vaciar el carrito', errorVaciar);

        // 9. Correo de confirmación: no bloquea la respuesta si tarda o falla
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
                fecha: pedido.created_at,
                comprobantePago
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

        const { data, error } = await obtenerPedidos({ cedula: usuario.cedula, soloVisibles: true });
        if (error) {
            return res.status(500).json({ error: 'Error al obtener los pedidos', detalle: error.message });
        }
        return res.status(200).json({ pedidos: await armarPedidos(data) });
    } catch (error) {
        console.error('❌ Pedidos: error en getMisPedidos', error);
        return res.status(500).json({ error: error.message });
    }
};

// PUT /pedidos/:id/ocultar  (el cliente quita un pedido de su historial)
export const putOcultarPedido = async (req, res) => {
    try {
        const { data: usuario } = await obtenerUsuarioParaPedido(req.usuario?.id);
        if (!usuario || usuario.cedula === null || usuario.cedula === undefined) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }

        const { data, error } = await ocultarPedidoDeCliente(req.params.id, usuario.cedula);
        if (error) {
            console.error('❌ Pedidos: error al ocultar', error);
            return res.status(500).json({ error: 'Error al eliminar el pedido de tu historial', detalle: error.message });
        }
        if (!data || data.length === 0) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }
        return res.status(200).json({ message: 'Pedido eliminado de tu historial' });
    } catch (error) {
        console.error('❌ Pedidos: error en putOcultarPedido', error);
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

        const { data: pedidoActual, error: errorPedidoActual } =
            await obtenerPedidoParaActualizar(id);
        if (errorPedidoActual) {
            return res.status(500).json({
                error: 'Error al consultar el pedido',
                detalle: errorPedidoActual.message
            });
        }
        if (!pedidoActual) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }

        const { data, error } = await actualizarEstadoPedido(id, estado);
        if (error) {
            return res.status(500).json({ error: 'Error al actualizar el estado', detalle: error.message });
        }
        if (!data || data.length === 0) {
            return res.status(404).json({ error: 'No se encontró el pedido' });
        }

        if (pedidoActual.Estado !== estado) {
            const { data: usuario, error: errorUsuario } =
                await obtenerTokenUsuarioPorCedula(pedidoActual.Usuario_Cc);
            if (errorUsuario) {
                console.error(`❌ Pedido #${id}: no se pudo consultar el token FCM`, errorUsuario);
            } else {
                void notificarClientePedido(usuario?.fcm_token, id, estado);
            }
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