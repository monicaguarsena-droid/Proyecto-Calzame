import { supabase } from '../config/supabase.js';

export const agregarAlCarrito = async (carritoData) => {
    const { data, error } = await supabase
        .from('carrito')
        .insert([{
            usuario_cc: carritoData.usuario_id,
            producto_id: carritoData.producto_id,
            cantidad: carritoData.cantidad,
            precio: carritoData.precio,
            talla: carritoData.talla,
            color: carritoData.color
        }])
        .select()
        .single();

    return { data, error };
};

export const obtenerCarritoPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .select('*')
        .eq('usuario_cc', usuario_id)
        .order('id', { ascending: true });

    return { data, error };
};

export const actualizarCantidadCarrito = async (id, usuario_id, cantidad) => {
    const { data, error } = await supabase
        .from('carrito')
        .update({ cantidad })
        .eq('id', id)
        .eq('usuario_cc', usuario_id)
        .select()
        .maybeSingle();

    return { data, error };
};

export const eliminarItemCarrito = async (id, usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('id', id)
        .eq('usuario_cc', usuario_id)
        .select()
        .maybeSingle();

    return { data, error };
};

export const vaciarCarritoUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('usuario_cc', usuario_id);

    return { data, error };
};
