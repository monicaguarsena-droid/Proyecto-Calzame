import { obtenerProductos, crearProducto, actualizarProducto, eliminarProducto } from '../modelos/productos.js';

const obtenerArchivosImagen = (req) => {
    if (req.file) return [req.file];
    if (Array.isArray(req.files)) return req.files;
    if (req.files && typeof req.files === 'object') {
        return Object.values(req.files).flat();
    }
    return [];
};

const parsearLista = (valor) => {
    if (Array.isArray(valor)) return valor;
    if (typeof valor !== 'string' || !valor.trim()) return [];
    const parsed = JSON.parse(valor);
    if (!Array.isArray(parsed)) throw new Error('El campo debe contener una lista');
    return parsed;
};

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

    const archivos = obtenerArchivosImagen(req);
    const urlsImagenes = archivos.map(file => file.path || file.secure_url).filter(Boolean);

    let coloresParsed = [];
    if (coloresData) {
      const mapping = parsearLista(coloresData);
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
      Tallas: parsearLista(Tallas),
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
        const body = req.body;
        const productoData = {};
        const copiarCampo = (nombre, ...aliases) => {
            const alias = aliases.find((key) => body[key] !== undefined);
            if (alias !== undefined) productoData[nombre] = body[alias];
        };

        copiarCampo('nombre', 'nombre', 'Nombre');
        copiarCampo('categoria', 'categoria', 'Categoria');
        copiarCampo('tipoCalzado', 'tipoCalzado', 'TipoCalzado', 'tipo_calzado');
        copiarCampo('descripcion', 'descripcion', 'Descripcion');

        const precio = body.precio ?? body.Precio;
        if (precio !== undefined) {
            const precioNumerico = Number(precio);
            if (!Number.isFinite(precioNumerico)) {
                return res.status(400).json({ error: 'El precio debe ser un número válido' });
            }
            productoData.precio = precioNumerico;
        }

        const stock = body.stock ?? body.Stock;
        if (stock !== undefined) {
            const stockNumerico = Number(stock);
            if (!Number.isInteger(stockNumerico)) {
                return res.status(400).json({ error: 'El stock debe ser un número entero válido' });
            }
            productoData.stock = stockNumerico;
        }

        const tallas = body.tallas ?? body.Tallas;
        if (tallas !== undefined) productoData.tallas = parsearLista(tallas);

        const archivo = obtenerArchivosImagen(req)[0];
        if (archivo) {
            productoData.imagen = archivo.path || archivo.secure_url;
            productoData.imagenes = [productoData.imagen];
        }

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