import { supabase } from '../config/supabase.js';

/**
 * Si el usuario ya tiene el mismo producto con la misma talla y color,
 * suma la cantidad; si no, crea un registro nuevo.
 * Devuelve { data, error, actualizado }.
 */
export const agregarAlCarrito = async (carritoData) => {
    const { data: existentes, error: errorBusqueda } = await supabase
        .from('carrito')
        .select('id, cantidad')
        .eq('usuario_id', carritoData.usuario_id)
        .eq('producto_id', carritoData.producto_id)
        .eq('talla', carritoData.talla)
        .eq('color', carritoData.color)
        .order('id', { ascending: true })
        .limit(1);

    if (errorBusqueda) {
        return { data: null, error: errorBusqueda, actualizado: false };
    }

    if (existentes && existentes.length > 0) {
        const existente = existentes[0];
        const { data, error } = await supabase
            .from('carrito')
            .update({ cantidad: existente.cantidad + carritoData.cantidad })
            .eq('id', existente.id)
            .select()
            .single();
        return { data, error, actualizado: true };
    }

    const { data, error } = await supabase
        .from('carrito')
        .insert([{
            usuario_id: carritoData.usuario_id,
            producto_id: carritoData.producto_id,
            cantidad: carritoData.cantidad,
            precio: carritoData.precio,
            talla: carritoData.talla,
            color: carritoData.color
        }])
        .select()
        .single();

    return { data, error, actualizado: false };
};

export const obtenerCarritoPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .select('*')
        .eq('usuario_id', usuario_id)
        .order('id', { ascending: true });

    return { data, error };
};

export const actualizarCantidadCarrito = async (id, usuario_id, cantidad) => {
    const { data, error } = await supabase
        .from('carrito')
        .update({ cantidad })
        .eq('id', id)
        .eq('usuario_id', usuario_id)
        .select()
        .maybeSingle();

    return { data, error };
};

export const eliminarItemCarrito = async (id, usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('id', id)
        .eq('usuario_id', usuario_id)
        .select()
        .maybeSingle();

    return { data, error };
};

export const vaciarCarritoUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('usuario_id', usuario_id);

    return { data, error };
};