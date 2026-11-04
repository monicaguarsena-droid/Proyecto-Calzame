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
        const nombre = req.body ? req.body.nombre : null;

        const imagenUrl = req.file ? req.file.path : null; 

        if (!nombre) {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio" });
        }

        const nuevaCategoria = await Categoria.create({
            nombre,
            imagen_url: imagenUrl, // Se guarda la URL completa (ej: https://res.cloudinary.com/...)
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
        const { id } = req.params;
        const { nombre, descripcion } = req.body;
        
        const imagenUrl = req.file ? req.file.path : undefined;

        const datosActualizar = {
            nombre,
            descripcion,
        };

        if (imagenUrl) {
            datosActualizar.imagen_url = imagenUrl;
        }

        const categoriaActualizada = await Categoria.update(id, datosActualizar);
        
        // ¡Importante! Asegúrate de enviar un JSON de respuesta explícito
        return res.status(200).json({
            mensaje: "Categoría actualizada con éxito",
            data: categoriaActualizada
        });
    } catch (error) {
        return res.status(400).json({ error: error.message });
    }
};

export const eliminarCategoria = async (req, res) => {
    try {
        await Categoria.delete(req.params.id);
        return res.status(200).json({ mensaje: "Categoría eliminada con éxito" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};