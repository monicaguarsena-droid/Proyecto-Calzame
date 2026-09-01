import { supabase } from '../config/supabase.js';
export const obtenerFavoritosPorUsuario = async (usuario_id) => {
    const { data, error } = await supabase
        .from('favoritos')
        .select(`
            id,
            producto_id,
            Productos:producto_id (id, Nombre, Precio, Imagen_url, Descripcion, Talla, Categoria)
        `)
        .eq('usuario_id', usuario_id);
    return { data, error };
};

// Agregar un producto a favoritos
export const agregarFavorito = async (usuario_id, producto_id) => {
    const { data, error } = await supabase
        .from('favoritos')
        .insert([{ usuario_id, producto_id }])
        .select();
    return { data, error };
};

// Eliminar un producto de favoritos
export const eliminarFavorito = async (usuario_id, producto_id) => {
    const { data, error } = await supabase
        .from('favoritos')
        .delete()
        .eq('usuario_id', usuario_id)
        .eq('producto_id', producto_id)
        .select();
    return { data, error };
};