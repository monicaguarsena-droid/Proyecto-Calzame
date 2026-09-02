import { obtenerProductos, crearProducto, actualizarProducto, eliminarProducto } from '../modelos/productos.js';

// trae el catalogo nuevo 
export const getProductos = async (req, res) => {
    try {
        const { data, error } = await obtenerProductos();

        if (error) {
            console.error('Error de Supabase en getProductos:', error);
            return res.status(500).json({ error: 'Error al obtener los productos', detalle: error.message });
        }

        return res.status(200).json({ productos: data });
    } catch (error) {
        console.error('Error en getProductos:', error);
        return res.status(500).json({ error: error.message });
    }
};


// trae los zapatos por categoria
export const getProductosPorCategoria = async (req, res) => {
    try {
        const { categoria } = req.params;
        const { data, error } = await obtenerPorCategoria(categoria);

        if (error) {
            return res.status(500).json({ error: 'Error al obtener los productos por categoría' });
        }

        return res.status(200).json({ productos: data });
    } catch (error) {
        console.error('Error en getProductosPorCategoria:', error);
        return res.status(500).json({ error: error.message });
    }
};


// crear un producto nuevo 
export const postProducto = async (req, res) => {
    try {
        const { nombre, descripcion, precio, talla, stock, imagen, categoria } = req.body;

        if (!nombre || !precio) {
            return res.status(400).json({ error: 'El nombre y el precio son obligatorios' });
        }

        const { data, error } = await crearProducto(nombre, descripcion, precio, talla, stock, imagen, categoria);

        if (error) {
            console.error('Error de Supabase al crear producto:', error);
            return res.status(500).json({ error: 'Error al crear el producto', detalle: error.message });
        }

        return res.status(201).json({
            mensaje: 'Producto registrado exitosamente',
            producto: data ? data[0] : null
        });
    } catch (error) {
        console.error('Error en postProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};

//actualizar un zapato
export const putProducto = async (req, res) => {
    try {
        const { id } = req.params;
        const productoData = req.body;
        const { data, error } = await actualizarproducto(id, productoData);
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        return res.status(200).json({ mensaje: 'Producto actualizado exitosamente', producto: data[0] });
    } catch (error) {
        console.error('Error en putProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};

//eliminar un zapato
export const deleteProducto = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await eliminarProducto(id);
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        return res.status(200).json({ mensaje: 'Producto eliminado exitosamente' });
    } catch (error) {
        console.error('Error en deleteProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};