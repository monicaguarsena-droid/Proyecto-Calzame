import * as FavoritoModel from '../modelos/favoritos.js';

export const getFavoritosPorUsuario = async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const { data, error } = await FavoritoModel.obtenerFavoritosPorUsuario(usuario_id);
        
        if (error) return res.status(400).json({ error: error.message });
        res.status(200).json(data);
    } catch (err) {
        res.status(500).json({ error: 'Error del servidor al obtener favoritos' });
    }
};

export const postAgregarFavorito = async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        const { data, error } = await FavoritoModel.agregarFavorito(usuario_id, producto_id);
        
        if (error) return res.status(400).json({ error: error.message });
        res.status(201).json({ mensaje: 'Producto agregado a favoritos', data });
    } catch (err) {
        res.status(500).json({ error: 'Error del servidor al agregar favorito' });
    }
};

export const deleteFavorito = async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        const { data, error } = await FavoritoModel.eliminarFavorito(usuario_id, producto_id);
        
        if (error) return res.status(400).json({ error: error.message });
        res.status(200).json({ mensaje: 'Producto eliminado de favoritos', data });
    } catch (err) {
        res.status(500).json({ error: 'Error del servidor al eliminar favorito' });
    }
};