import { obtenerCategorias, obtenerCategoriaPorId, obtenerTiposCalzadoModelo,contarProductosPorTipo,crearCategoria, actualizarCategoria, eliminarCategoria } from '../modelos/categorias.js';

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
export const obtenerTiposCalzadoConConteo = async (req, res) => {
    try {
        // 1. Llamamos al modelo para traer los tipos de calzado
        const { data: tiposCalzado, error: errTipos } = await obtenerTiposCalzadoModelo();

        if (errTipos) {
            return res.status(400).json({ error: errTipos.message });
        }

        // 2. Recorremos cada tipo y usamos el modelo de conteo para cada uno
        const tiposConConteo = await Promise.all(
            tiposCalzado.map(async (tipo) => {
                const { count } = await contarProductosPorTipo(tipo.nombre);

                return {
                    ...tipo,
                    cantidadProductos: count // Asigna el número real de productos
                };
            })
        );

        // 3. Devolvemos la respuesta formateada que espera tu app de Flutter
        return res.status(200).json({
            categorias: tiposConConteo
        });

    } catch (error) {
        console.error('Error en el controlador:', error);
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
        const { nombre } = req.body;
        const imagenUrl = req.file ? (req.file.path || req.file.secure_url) : null;

        if (!nombre) {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio" });
        }

        const { data, error } = await crearCategoria(nombre, imagenUrl);

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