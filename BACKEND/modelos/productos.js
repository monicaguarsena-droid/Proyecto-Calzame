import { supabase } from '../config/supabase.js';

export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('Productos')
        .select('*');
    return { data, error };
};

export const crearProducto = async (Nombre, Categoria, Precio, Stock,  Descripcion, Tallas, Imagen) => {
    const { data, error } = await supabase
        .from('Productos')
        .insert([
            { 
                Nombre: Nombre,
                Categoria: Categoria,
                Precio: Precio,
                Stock: Stock,
                Descripcion: Descripcion,
                Tallas: Tallas,
                Imagen: Imagen,
                
            }
        ])
        .select();
    return { data, error };
};

export const actualizarProducto = async (id, campos) => {
    const camposMapeados = {};
    if (campos.nombre !== undefined) camposMapeados.Nombre = campos.nombre;
    if (campos.precio !== undefined) camposMapeados.Precio = campos.precio;
    if (campos.stock !== undefined) camposMapeados.Stock = campos.stock;
    if (campos.descripcion !== undefined) camposMapeados.Descripcion = campos.descripcion;
    if (campos.tallas !== undefined) camposMapeados.Tallas = campos.tallas;
    if (campos.imagen !== undefined || campos.imagen_url !== undefined) {
        camposMapeados.Imagen_url = campos.imagen !== undefined ? campos.imagen : campos.imagen_url;
    }
    if (campos.categoria !== undefined) camposMapeados.Categoria = campos.categoria;

    const { data, error } = await supabase
        .from('Productos')
        .update(camposMapeados)
        .eq('id', id)
        .select();
    return { data, error };
};

export const eliminarProducto = async (id) => {
    const { data, error } = await supabase
        .from('Productos')
        .delete()
        .eq('id', id)
        .select();
    return { data, error };
};