import { supabase } from '../config/supabase.js';

export const obtenerProductos = async () => {
    const { data, error } = await supabase
        .from('Productos')
        .select('*');
    return { data, error };
};

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

export const actualizarProducto = async (id, campos) => {
    const camposMapeados = {};
    if (campos.nombre !== undefined) camposMapeados.Nombre = campos.nombre;
    if (campos.descripcion !== undefined) camposMapeados.Descripcion = campos.descripcion;
    if (campos.precio !== undefined) camposMapeados.Precio = campos.precio;
    if (campos.talla !== undefined) camposMapeados.Talla = campos.talla;
    if (campos.stock !== undefined) camposMapeados.Stock = campos.stock;
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