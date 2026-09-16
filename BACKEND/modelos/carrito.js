import { supabase } from '../config/supabase.js';

export const agregarAlCarrito = async (carritoData) => {
    const { data, error } = await supabase
        .from('carrito')
        .insert([
            {
                usuario_cc: carritoData.usuario_id || carritoData.usuario_cc,
                producto_id: carritoData.producto_id,
                cantidad: carritoData.cantidad,
                precio: carritoData.precio
            }
        ])
        .select();

    if (error) throw new Error(error.message);
    return data[0];
};

export const obtenerCarritoPorUsuario = async (usuario_cc) => {
    const { data, error } = await supabase
        .from('carrito')
        .select('*')
        .eq('usuario_cc', usuario_cc);

    if (error) throw new Error(error.message);
    return data;
};

export const eliminarItemCarrito = async (id) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('id', id)
        .select();

    if (error) throw new Error(error.message);
    return data;
};

export const vaciarCarritoUsuario = async (usuario_cc) => {
    const { data, error } = await supabase
        .from('carrito')
        .delete()
        .eq('usuario_cc', usuario_cc)
        .select();

    if (error) throw new Error(error.message);
    return data;
};