import { supabase } from '../config/supabase.js';


export const crearPedido = async (usuario_id, total, direccion_envio) => {
    const { data, error } = await supabase
        .from('pedidos')
        .insert([{ usuario_id, total, direccion_envio, estado: 'pendiente' }])
        .select();

    return { data, error };
};

// Busca todos los pedidos del cliente que quiera uno buscar 
export const obtenerPedidosPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('pedidos')
        .select('*')
        .eq('usuario_id', usuario_id);

    return { data, error };
};