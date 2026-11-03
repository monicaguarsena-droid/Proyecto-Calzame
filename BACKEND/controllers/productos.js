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
        const { Nombre, Categoria, TipoCalzado, Precio, Stock, Descripcion, Tallas } = req.body;
        const imagenUrl = req.file ? req.file.path : null; 

        const nuevoProducto = await Producto.create({
            nombre: Nombre,
            categoria: Categoria,
            tipo_calzado: TipoCalzado,
            precio: parseFloat(Precio),
            stock: parseInt(Stock),
            descripcion: Descripcion,
            tallas: JSON.parse(Tallas || '[]'),
            imagen_url: imagenUrl
        });

        res.status(201).json({
            mensaje: "Producto creado con éxito",
            data: nuevoProducto
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

//actualizar un zapato
export const putProducto = async (req, res) => {
    try {
        const { id } = req.params;
        const productoData = req.body;
        const { data, error } = await actualizarProducto(id, productoData);
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        return res.status(200).json({ mensaje: 'Producto actualizado exitosamente', producto: data ? data[0] : null });
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