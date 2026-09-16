import { supabase } from '../config/supabase.js';

export const crearPedido = async (pedidoData) => {
    const { data, error } = await supabase
        .from('Pedidos') 
        .insert([
            {
                Usuario_Cc: pedidoData.usuario_id,
                Direccion_Entrega: pedidoData.direccion_envio,
                Celular: pedidoData.telefono,
                Total: pedidoData.total
            }
        ])
        .select();

    return { data, error };
};

export const obtenerPedidosPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .select('*')
        .eq('Usuario_Cc', usuario_id)
        .order('created_at', { ascending: false });

    return { data, error };
};

export const obtenerPedidoConDetalles = async (pedido_id) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .select(`*, detalle_pedido(*)`) 
        .eq('id', pedido_id)
        .single();

    return { data, error };
};

export const actualizarEstadoPedido = async (pedido_id, estado) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .update({ estado })
        .eq('id', pedido_id)
        .select();

    return { data, error };
};

export const crearDetallePedido = async (detalleData) => {
    const { data, error } = await supabase
        .from('detalle_pedido') 
        .select();
    return { data, error };
};

export const eliminarPedidos = async (id) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .delete()
        .eq('id', id);
    return { data, error };
};