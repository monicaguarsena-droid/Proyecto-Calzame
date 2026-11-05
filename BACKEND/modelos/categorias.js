import { supabase } from "../config/supabase.js";

export const obtenerCategorias = async () => {
    const { data, error } = await supabase
        .from("TipoCalzado")
        .select("*");
    return { data, error };
};

// Modelo para obtener los tipos de calzado
export const obtenerTiposCalzadoModelo = async () => {
    const { data, error } = await supabase
        .from('Tipocalzado')
        .select('*');
    return { data, error };
};

// Modelo para contar cuántos productos usan un tipo de calzado específico
export const contarProductosPorTipo = async (nombreTipo) => {
    const { count, error } = await supabase
        .from('Productos')
        .select('*', { count: 'exact', head: true })
        .eq('TipoCalzado', nombreTipo);
    
    return { count: count || 0, error };
};
export const obtenerCategoriaPorId = async (id) => {
    const { data, error } = await supabase
        .from("TipoCalzado")
        .select("*")
        .eq("id", id)
        .single();
    return { data, error };
};

export const crearCategoria = async (nombre, descripcion, imagenUrl) => {
    const { data, error } = await supabase
        .from("TipoCalzado")
        .insert([
            {
                nombre: nombre,
                descripcion: descripcion,
                imagen_url: imagenUrl,
            }
        ])
        .select();
    return { data, error };
};

export const actualizarCategoria = async (id, campos) => {
    const camposMapeados = {};
    if (campos.nombre !== undefined) camposMapeados.nombre = campos.nombre;
    if (campos.descripcion !== undefined) camposMapeados.descripcion = campos.descripcion;
    if (campos.imagen !== undefined || campos.imagen_url !== undefined) {
        camposMapeados.imagen_url = campos.imagen !== undefined ? campos.imagen : campos.imagen_url;
    }

    const { data, error } = await supabase
        .from("TipoCalzado")
        .update(camposMapeados)
        .eq("id", id)
        .select();
    return { data, error };
};

export const eliminarCategoria = async (id) => {
    const { data, error } = await supabase
        .from("TipoCalzado")
        .delete()
        .eq("id", id)
        .select();
    return { data, error };
};