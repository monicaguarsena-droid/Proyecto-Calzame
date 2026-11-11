import {
    obtenerProductos,
    obtenerPorCategoria,
    crearProducto,
    actualizarProducto,
    eliminarProducto,
} from '../modelos/productos.js';

const obtenerArchivosImagen = (req) => {
    if (req.file) return [req.file];
    if (Array.isArray(req.files)) return req.files;
    if (req.files && typeof req.files === 'object') {
        return Object.values(req.files).flat();
    }
    return [];
};

const urlDeArchivo = (file) => file.path || file.secure_url || file.url;

const parsearLista = (valor) => {
    if (Array.isArray(valor)) return valor;
    if (typeof valor !== 'string' || !valor.trim()) return [];
    const parsed = JSON.parse(valor);
    if (!Array.isArray(parsed)) throw new Error('El campo debe contener una lista');
    return parsed;
};

// Convierte [{color, indexImagen}] en [{color, imagenUrl}] usando las URLs de Cloudinary.
// Si un color apunta a una foto que no llegó, devuelve error (antes caía en silencio a la primera).
const construirColores = (mapping, urls) => {
    const colores = [];
    for (const item of mapping) {
        const nombre = String(item.color ?? '').trim();
        if (!nombre) throw new Error('Cada color necesita un nombre');

        const indice = Number(item.indexImagen);
        const imagenUrl =
            item.imagenUrl || (Number.isInteger(indice) ? urls[indice] : undefined);

        if (!imagenUrl) {
            throw new Error(
                `El color "${nombre}" no tiene imagen. Llegaron ${urls.length} archivo(s).`,
            );
        }
        colores.push({ color: nombre, imagenUrl });
    }
    return colores;
};

// trae el catalogo
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
        const urlsImagenes = archivos.map(urlDeArchivo).filter(Boolean);

        // Diagnóstico: debe decir cuántas fotos mandaste desde Flutter
        console.log(
            `📸 Archivos recibidos: ${archivos.length} | campos: ${Object.keys(req.files || {}).join(', ')}`,
        );
        console.log('🎨 coloresData:', coloresData);

        if (urlsImagenes.length === 0) {
            return res.status(400).json({ error: 'Debes subir al menos una imagen' });
        }

        const coloresParsed = coloresData
            ? construirColores(parsearLista(coloresData), urlsImagenes)
            : [];

        const productoData = {
            Nombre: Nombre?.trim() || '',
            Categoria: Categoria?.trim() || '',
            TipoCalzado: TipoCalzado?.trim() || '',
            Precio: parseFloat(Precio) || 0,
            Stock: parseInt(Stock) || 0,
            Descripcion: Descripcion?.trim() || '',
            Tallas: parsearLista(Tallas),
            Imagenes: urlsImagenes, // TODAS las fotos subidas
            Colores: coloresParsed, // cada color con su foto
            Imagen: coloresParsed[0]?.imagenUrl || urlsImagenes[0], // foto principal
        };

        const { data, error } = await crearProducto(productoData);
        if (error) return res.status(400).json({ error: error.message });

        return res.status(201).json({
            mensaje: 'Producto creado con éxito',
            producto: data ? data[0] : null,
        });
    } catch (error) {
        console.error('Error en postProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};

// actualizar un zapato
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

        const urls = obtenerArchivosImagen(req).map(urlDeArchivo).filter(Boolean);
        if (urls.length > 0) {
            productoData.imagenes = urls;
            productoData.imagen = urls[0];
        }

        const coloresData = body.coloresData ?? body.Colores;
        if (coloresData !== undefined) {
            productoData.colores = construirColores(parsearLista(coloresData), urls);
            if (urls.length === 0 && productoData.colores[0]) {
                productoData.imagen = productoData.colores[0].imagenUrl;
            }
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

// eliminar un zapato
export const deleteProducto = async (req, res) => {
    try {
        const { id } = req.params;
        const { error } = await eliminarProducto(id);
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        return res.status(200).json({ mensaje: 'Producto eliminado exitosamente' });
    } catch (error) {
        console.error('Error en deleteProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};