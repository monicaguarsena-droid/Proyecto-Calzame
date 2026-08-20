import { supabase } from '../config/supabase.js';

// Trae la lista de zapatos desde Superbeis
export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('productos')
        .select('*');
    return { data, error };
};

// coloca un zapato nuevo en la tabla productos
export const crearProducto = async (nombre, descripcion, precio, talla, stock, imagen) => {
    const { data, error } = await supabase
        .from('productos')
        .insert([{ nombre, descripcion, precio, talla, stock, imagen }])
        .select();
 return { data, error };
};