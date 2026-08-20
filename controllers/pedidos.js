import { crearPedido, obtenerPedidosPorUsuario }
 from '../modelos/pedidos.js';

// guardar un pedido
export const postPedido = async (req, res) => {
    try {
        const { usuario_id, total, direccion_envio } = req.body;

        if (!usuario_id || !total) {
            return res.status(400).json({ error: 'Datos del peddi' });
        }

        const { data, error } = await crearPedido(usuario_id, total, direccion_envio);

        if (error) {
            return res.status(500).json({ error: 'Error al registrar el pedido' });
        }

        return res.status(201).json({
            mensaje: 'Pedido registrado con exito ...git add .',
            pedido: data[0]
        });
    } catch (error) {
        console.error('Error en postPedido:', error);
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