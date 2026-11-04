import { supabase } from "../config/supabase.js";

export const obtenerCategorias = async () => {
    const { data, error } = await supabase
        .from("categorias")
        .select("*");
    return { data, error };
};

export const obtenerCategoriaPorId = async (id) => {
    const { data, error } = await supabase
        .from("categorias")
        .select("*")
        .eq("id", id)
        .single();
    return { data, error };
};

export const crearCategoria = async (nombre, descripcion, imagenUrl) => {
    const { data, error } = await supabase
        .from("categorias")
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
        .from("categorias")
        .update(camposMapeados)
        .eq("id", id)
        .select();
    return { data, error };
};

export const eliminarCategoria = async (id) => {
    const { data, error } = await supabase
        .from("categorias")
        .delete()
        .eq("id", id)
        .select();
    return { data, error };
};