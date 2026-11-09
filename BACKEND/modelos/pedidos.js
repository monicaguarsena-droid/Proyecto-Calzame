import { supabase } from '../config/supabase.js';

// ---------- Usuarios ----------

export const obtenerUsuarioParaPedido = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, nombre, email, cedula')
        .eq('id', id)
        .maybeSingle();
    return { data, error };
};

export const guardarCedulaUsuario = async (id, cedula) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update({ cedula })
        .eq('id', id)
        .select('id');
    return { data, error };
};

export const obtenerUsuariosPorCedulas = async (cedulas) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, nombre, email, cedula')
        .in('cedula', cedulas);
    return { data, error };
};

// ---------- Productos ----------

export const obtenerProductosPorIds = async (ids) => {
    const { data, error } = await supabase
        .from('Productos')
        .select('id, Nombre, Precio, Imagen, Colores')
        .in('id', ids);
    return { data, error };
};

// ---------- Pedidos ----------

export const crearPedido = async (pedidoData) => {
    const { data, error } = await supabase
        .from('Pedidos')
        .insert([
            {
                Usuario_Cc: pedidoData.usuario_cc,
                Celular: pedidoData.celular,
                Total: pedidoData.total,
                Estado: pedidoData.estado,
                Metodo_Pago: pedidoData.metodo_pago,
                Nombre_Contacto: pedidoData.nombre_contacto
            }
        ])
        .select();

    return { data, error };
};

// Todos los pedidos (admin) o solo los de una cédula
export const obtenerPedidos = async ({ cedula } = {}) => {
    let consulta = supabase
        .from('Pedidos')
        .select('*')
        .order('id', { ascending: false });

    if (cedula !== undefined && cedula !== null) {
        consulta = consulta.eq('Usuario_Cc', cedula);
    }

    const { data, error } = await consulta;
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

export const eliminarPedidoCompleto = async (id) => {
    const { error: errorDetalles } = await supabase
        .from('detalle_pedido')
        .delete()
        .eq('Pedido_Id', id);
    if (errorDetalles) return { data: null, error: errorDetalles };

    const { data, error } = await supabase
        .from('Pedidos')
        .delete()
        .eq('id', id)
        .select();
    return { data, error };
};

// ---------- Detalle del pedido ----------

export const crearDetallesPedido = async (detalles) => {
    const { data, error } = await supabase
        .from('detalle_pedido')
        .insert(detalles)
        .select();
    return { data, error };
};

export const obtenerDetallesPorPedidos = async (pedidoIds) => {
    const { data, error } = await supabase
        .from('detalle_pedido')
        .select('*')
        .in('Pedido_Id', pedidoIds)
        .order('id', { ascending: true });
    return { data, error };
};