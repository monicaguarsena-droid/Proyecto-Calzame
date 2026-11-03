import { Categoria } from "../modelos/categorias.js";

export const obtenerCategorias = async (req, res) => {
    try {
        const categorias = await Categoria.getAll();
        res.status(200).json(categorias);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const obtenerCategoriaPorId = async (req, res) => {
    try {
        const categoria = await Categoria.getById(req.params.id);
        if (!categoria) return res.status(404).json({ error: "Categoría no encontrada" });
        res.status(200).json(categoria);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const crearCategoria = async (req, res) => {
    try {
        // Verificamos que req.body exista antes de leer sus propiedades
        const nombre = req.body ? req.body.nombre : null;
        const imagenUrl = req.file ? req.file.path : null; // O la URL que retorne tu servicio de subida

        if (!nombre) {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio" });
        }

        const nuevaCategoria = await Categoria.create({
            nombre,
            imagen_url: imagenUrl,
        });

        res.status(201).json({
            mensaje: "Categoría creada con éxito",
            data: nuevaCategoria
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

export const actualizarCategoria = async (req, res) => {
    try {
        const categoriaActualizada = await Categoria.update(req.params.id, req.body);
        res.status(200).json({
            mensaje: "Categoría actualizada con éxito",
            data: categoriaActualizada
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

export const eliminarCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        
        const { error } = await supabase.from('categorias').delete().eq('id', id);
        
        if (error) throw error;
        
        res.status(200).json({ mensaje: "Categoría eliminada con éxito" });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};