import { supabase } from '../config/supabase.js';

// tener todos los productos de Supabase
export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('Productos')
        .select('*');
    return { data, error };
};

// colocar un nuevo producto
export const crearProducto = async (nombre, descripcion, precio, talla, stock, imagen, categoria) => {
    const { data, error } = await supabase
        .from('Productos')
        .insert([
            { 
                Nombre: nombre,
                Descripcion: descripcion,
                Precio: precio,
                Talla: talla,
                Stock: stock,
                Imagen_url: imagen,
                Categoria: categoria
            }
        ])
        .select();
    return { data, error };
};

// actuakizar productos por id
export const actualizarProducto = async (id, campos) => {
    const { data, error } = await supabase
        .from('Productos')
        .update(campos)
        .eq('id', id)
        .select();
    return { data, error };
};

// eliminar producto por id 
export const eliminarProducto = async (id) => {
    const { data, error } = await supabase
        .from('Productos')
        .delete()
        .eq('id', id)
        .select();
    return { data, error };
};