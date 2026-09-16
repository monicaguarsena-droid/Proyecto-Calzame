import { 
    crearPedido, 
    obtenerPedidosPorUsuario, 
    obtenerPedidoConDetalles, 
    actualizarEstadoPedido, 
    crearDetallePedido, 
    eliminarPedidos 
} from '../modelos/pedidos.js';
import { enviarConfirmacionPedido } from '../utils/sendEmail.js';
import { obtenerUsuarioPorId as obtenerUsuario } from '../modelos/user.js';
import { supabase } from '../config/supabase.js';

// Crear un pedido
export const postPedido = async (req, res) => {
    try {
        const { usuario_id, telefono, direccion_envio, detalles } = req.body;
        
        if (!usuario_id || !detalles || detalles.length === 0) {
            return res.status(400).json({ error: 'Datos incompletos' });
        }

        let total = 0;
        detalles.forEach(d => {
            total += d.subtotal || (d.Precio_unitario * d.Cantidad);
        });

        const { data: pedido, error: errorPedido } = await crearPedido({
            usuario_id, direccion_envio, telefono, total
        });

        if (errorPedido || !pedido) {
            return res.status(500).json({ error: 'Error al crear pedido', detalle: errorPedido?.message });
        }

        const detallesConPedido = detalles.map(d => ({
            ...d, Pedido_Id: pedido[0].id
        }));

        for (let detalle of detallesConPedido) {
            await crearDetallePedido(detalle);
        }

        const { data: usuario } = await obtenerUsuario(usuario_id);

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


export const getTodosLosPedidos = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('Pedidos')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({ error: 'Error al obtener los pedidos', detalle: error.message });
        }

        return res.status(200).json({ pedidos: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const getPedidosUsuario = async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const { data, error } = await obtenerPedidosPorUsuario(usuario_id);

        if (error) {
            return res.status(500).json({ error: 'Error al obtener los pedidos del usuario' });
        }

        return res.status(200).json({ pedidos: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const getPedidoPorId = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerPedidoConDetalles(id);

        if (error) {
            return res.status(404).json({ error: 'Pedido no encontrado' });
        }

        return res.status(200).json({ pedido: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const actualizarEstado = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body;
        
        if (!estado) return res.status(400).json({ error: 'Estado requerido' });

        const { data, error } = await actualizarEstadoPedido(id, estado);

        if (error) return res.status(500).json({ error: 'Error al actualizar el estado' });

        return res.status(200).json({ message: 'Estado actualizado exitosamente', pedido: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Eliminar pedido
export const eliminarPedido = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await eliminarPedidos(id);
        
        if (error) return res.status(500).json({ error: 'Error al eliminar pedido' });
        
        return res.status(200).json({ message: 'Pedido eliminado exitosamente', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};