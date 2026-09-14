import { supabase } from '../config/supabase.js';

export const obtenerFavoritosPorUsuario = async (usuario_id) => {
    const { data: favoritos, error } = await supabase
        .from('favoritos')
        .select('*')
        .eq('usuario_id', usuario_id);

    if (error) return { data: null, error };

    const favoritosConDetalle = [];
    for (let fav of favoritos) {
        const { data: producto } = await supabase
            .from('Productos')
            .select('*')
            .eq('id', fav.producto_id)
            .single();
        
        favoritosConDetalle.push({
            ...fav,
            Productos: producto || null
        });
    }

    return { data: favoritosConDetalle, error: null };
};

export const agregarFavorito = async (usuario_id, producto_id) => {
    const { data, error } = await supabase
        .from('favoritos')
        .insert([{ usuario_id, producto_id }])
        .select();
    return { data, error };
};

export const eliminarFavorito = async (usuario_id, producto_id) => {
    const { data, error } = await supabase
        .from('favoritos')
        .delete()
        .eq('usuario_id', usuario_id)
        .eq('producto_id', producto_id)
        .select();
    return { data, error };
};