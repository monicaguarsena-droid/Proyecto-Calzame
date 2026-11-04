import { obtenerCategorias, obtenerCategoriaPorId, crearCategoria, actualizarCategoria, eliminarCategoria } from '../modelos/categorias.js';

// Trae todas las categorías
export const getCategorias = async (req, res) => {
    try {
        const { data, error } = await obtenerCategorias();

        if (error) {
            console.error('Error de Supabase en getCategorias:', error);
            return res.status(500).json({ error: 'Error al obtener las categorías', detalle: error.message });
        }

        return res.status(200).json({ categorias: data });
    } catch (error) {
        console.error('Error en getCategorias:', error);
        return res.status(500).json({ error: error.message });
    }
};

// Trae una categoría por su ID
export const getCategoriaPorId = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await obtenerCategoriaPorId(id);

        if (error) {
            return res.status(404).json({ error: "Categoría no encontrada", detalle: error.message });
        }

        return res.status(200).json({ categoria: data });
    } catch (error) {
        console.error('Error en getCategoriaPorId:', error);
        return res.status(500).json({ error: error.message });
    }
};

// Crear una categoría nueva
export const postCategoria = async (req, res) => {
    try {
        const { nombre, descripcion } = req.body;
        const imagenUrl = req.file ? (req.file.path || req.file.secure_url) : null;

        if (!nombre) {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio" });
        }

        const { data, error } = await crearCategoria(nombre, descripcion, imagenUrl);

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        return res.status(201).json({
            mensaje: "Categoría creada con éxito",
            data: data ? data[0] : null
        });
    } catch (error) {
        console.error('Error en postCategoria:', error);
        return res.status(400).json({ error: error.message });
    }
};

// Actualizar una categoría
export const putCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        const categoriaData = req.body;
        
        // Si viene un archivo nuevo en la petición, lo agregamos al objeto de datos
        if (req.file) {
            categoriaData.imagen_url = req.file.path || req.file.secure_url;
        }

        const { data, error } = await actualizarCategoria(id, categoriaData);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json({
            mensaje: "Categoría actualizada con éxito",
            categoria: data ? data[0] : null
        });
    } catch (error) {
        console.error('Error en putCategoria:', error);
        return res.status(500).json({ error: error.message });
    }
};

// Eliminar una categoría
export const deleteCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await eliminarCategoria(id);

        if (error) {
            return res.status(500).json({ error: error.message });
        }

        return res.status(200).json({ mensaje: "Categoría eliminada con éxito" });
    } catch (error) {
        console.error('Error en deleteCategoria:', error);
        return res.status(500).json({ error: error.message });
    }
};