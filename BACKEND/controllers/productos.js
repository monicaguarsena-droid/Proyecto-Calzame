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
    // Extraemos los campos enviando soporte para 'tipoCalzado' en minúscula que envía Flutter
    const { Nombre, Categoria, TipoCalzado, tipoCalzado, Precio, Stock, Descripcion, Tallas } = req.body;

    // Obtenemos la URL de la imagen de Cloudinary / Multer
    const imagenUrl = req.file ? (req.file.path || req.file.secure_url) : null;

    // Preparamos los datos con los tipos correctos
    const productoData = {
      Nombre: Nombre ? Nombre.trim() : '',
      Categoria: Categoria ? Categoria.trim() : '',
      TipoCalzado: (TipoCalzado || tipoCalzado || '').trim(), // Acepta ambas variantes
      Precio: Precio ? parseFloat(Precio) : 0,
      Stock: Stock ? parseInt(Stock) : 0,
      Descripcion: Descripcion ? Descripcion.trim() : '',
      Tallas: Tallas ? (typeof Tallas === 'string' ? JSON.parse(Tallas) : Tallas) : [],
      Imagen: imagenUrl
    };

    // Llamamos a la función del modelo
    const { data, error } = await crearProducto(productoData);

    if (error) {
      console.error('Error de Supabase:', error);
      return res.status(400).json({ error: error.message });
    }

    return res.status(201).json({
      mensaje: "Producto creado con éxito",
      producto: data ? data[0] : null
    });

  } catch (error) {
    console.error('Error en servidor:', error);
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