import { crearPedido, obtenerPedidosPorUsuario, obtenerPedidoConDetalles, actualizarEstadoPedido, crearDetallePedido, eliminarPedidos } from '../modelos/pedidos.js';
import { enviarConfirmacionPedido } from '../utils/sendEmail.js';
import { obtenerUsuarioPorId as obtenerUsuario } from '../modelos/user.js';

// crear un pedido
export const postPedido = async (req, res) => {
    try {
        const { usuario_id, telefono, direccion_envio, detalles } = req.body;
        
        if (!usuario_id || !detalles || detalles.length === 0) {
            return res.status(400).json({ error: 'Datos incompletos' });
        }

        
        // Calcular total
        let total = 0;
        detalles.forEach(d => {
            total += d.subtotal;
        });

        // 1. Crear pedido
        const { data: pedido, error: errorPedido } = await crearPedido({
            usuario_id, direccion_envio, telefono, total
        });

        if (errorPedido || !pedido) {
            return res.status(500).json({ error: 'Error al crear pedido' });
        }

        // 2. Crear detalles del pedido
        const detallesConPedido = detalles.map(d => ({
            ...d, pedido_id: pedido[0].id
        }));

        for (let detalle of detallesConPedido) {
            await crearDetallePedido(detalle);
        }

        // 3. Obtener info del usuario para el correo
        const { data: usuario } = await obtenerUsuario(usuario_id);

        // 4. ENVIAR CORREO DE CONFIRMACIÓN
        if (usuario && usuario.email) {
            await enviarConfirmacionPedido(
                usuario.email,
                usuario.nombre,
                pedido[0].id,
                total
            );
        }

        return res.status(201).json({
            message: 'Pedido creado y correo enviado',
            pedido: pedido[0]
        });

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// obtener pedidos de un usuario
export const getPedidosUsuario = async (req, res) => {
    try {
        const { usuario_id } = req.params;

        const { data, error } = await obtenerPedidosPorUsuario(usuario_id);

        if (error) {
            return res.status(500).json({ error: 'Error al obtener los pedidos' });
        }

        return res.status(200).json({ pedidos: data });
    } catch (error) {
        console.error('Error en getPedidosUsuario:', error);
        return res.status(500).json({ error: error.message });
    }
};

export const actualizarEstado = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body;
        if (!estado) return res.status(400).json({ error: 'Estado requerido' });
        return res.status(200).json({ message: 'Estado actualizado', estado });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const eliminarPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await eliminarPedidos(id);
        if (error) return res.status(500).json({ error: 'Error al eliminar pedido' });
        return res.status(200).json({ message: 'Pedido eliminado', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};