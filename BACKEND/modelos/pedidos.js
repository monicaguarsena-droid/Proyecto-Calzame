import { supabase } from '../config/supabase.js';

export const crearPedido = async (pedidoData) => {
    const { data, error } = await supabase
        .from('Pedidos') // Asegúrate de respetar mayúsculas si tu tabla se llama así
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

export const obtenerPedidoConDetalles = async (id) => {
  const { data, error } = await supabase
    .from('Pedidos')
    .select(`
        *,
        usuario:usuarios(id, nombre, email),
        detalles:detalle_pedido(id, cantidad, precio_unitario, subtotal, productos:producto(id, nombre, imagen_url))
    `)
    .eq('id', id)
    .single();
    
  return { data, error };
};

export const obtenerPedidosPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .select('*')
        .eq('Usuario_Cc', usuario_id)
        .order('Fecha_pedido', { ascending: false });

    return { data, error };
};

export const actualizarEstadoPedido = async (id, estado) => {
  const { data, error } = await supabase
    .from('Pedidos')
    .update({ Estado: estado })
    .eq('id', id)
    .select();
  return { data, error };
};

export const crearDetallePedido = async (detalleData) => {
  const { data, error } = await supabase
    .from('detalle_pedido')
    .insert(detalleData)
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