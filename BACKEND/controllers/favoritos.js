import { 
    obtenerFavoritosPorUsuario, 
    agregarFavorito, 
    eliminarFavorito 
} from '../modelos/favoritos.js';
import { supabase } from '../config/supabase.js';

export const obtenerTodosFavoritos = async (req, res) => {
    try {
        const { data, error } = await supabase.from('favoritos').select('*');
        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json({ favoritos: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const obtenerFavoritosUsuario = async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const { data, error } = await obtenerFavoritosPorUsuario(usuario_id);
        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json({ favoritos: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};


export const crearFavorito = async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        const { data, error } = await agregarFavorito(usuario_id, producto_id);
        if (error) return res.status(400).json({ error: error.message });
        return res.status(201).json({ mensaje: 'Favorito agregado', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};


export const eliminarFavoritoController = async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        const { data, error } = await eliminarFavorito(usuario_id, producto_id);
        if (error) return res.status(400).json({ error: error.message });
        return res.status(200).json({ mensaje: 'Favorito eliminado', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};