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
    const { Nombre, Categoria, TipoCalzado, Precio, Stock, Descripcion, Tallas, coloresData } = req.body;

    // Si utilizas Multer para múltiples archivos (upload.array('imagenes'))
    const urlsImagenes = req.files ? req.files.map(file => file.path || file.secure_url) : [];

    let coloresParsed = [];
    if (coloresData) {
      const mapping = JSON.parse(coloresData);
      coloresParsed = mapping.map(item => ({
        color: item.color,
        imagenUrl: urlsImagenes[item.indexImagen] || urlsImagenes[0]
      }));
    }

    const productoData = {
      Nombre: Nombre?.trim() || '',
      Categoria: Categoria?.trim() || '',
      TipoCalzado: TipoCalzado?.trim() || '',
      Precio: parseFloat(Precio) || 0,
      Stock: parseInt(Stock) || 0,
      Descripcion: Descripcion?.trim() || '',
      Tallas: Tallas ? (typeof Tallas === 'string' ? JSON.parse(Tallas) : Tallas) : [],
      Imagenes: urlsImagenes,
      Colores: coloresParsed,
      Imagen: urlsImagenes[0] || null // Imagen principal por defecto
    };

    const { data, error } = await crearProducto(productoData);
    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json({ mensaje: "Producto creado con éxito", producto: data ? data[0] : null });
  } catch (error) {
    return res.status(500).json({ error: error.message });
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