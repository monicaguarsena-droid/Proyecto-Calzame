import { supabase } from '../config/supabase.js';

// Trae la lista de zapatos desde Superbeis
export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('productos')
        .select('*');
    return { data, error };
};
export const obtenerPorCategoria = async (categoria) => {
    const { data, error } = await supabase.from('productos').select('*').eq('categoria', categoria);
    return { data, error };
};
// coloca un zapato nuevo en la tabla productos
export const crearProducto = async (productoData) => {
    const { data, error } = await supabase
        .from('productos')
        .insert(productoData)
        .select();
 return { data, error };
};
export const actualizarproducto = async (id, productoData) => {
    const { data, error } = await supabase.from('productos').update(productoData).eq('id', id).select();
    return { data, error };
};


export const eliminarProducto = async (id) => {
    const { data, error } = await supabase.from('productos').delete().eq('id', id).select();
    return { data, error };
};