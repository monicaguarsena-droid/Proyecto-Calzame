import { obtenerProductos, crearProducto } from '../modelos/productos.js';

// trae el catalogo complet de los zapatos
export const getProductos = async (req, res) => {
    try {
        const { data, error } = await obtenerProductos();

     if (error) {
            return res.status(500).json({ error: 'Error al obtener los productos' });
        }

        return res.status(200).json({ productos: data });
    } catch (error) {
        console.error('Error en getProductos:', error);
        return res.status(500).json({ error: error.message });
    }
};

// guarda un zapato nuevo :>
export const postProducto = async (req, res) => {
    try {
        const { nombre, descripcion, precio, talla, stock, imagen } = req.body;

    if (!nombre || !precio) {
            return res.status(400).json({ error: 'El nombre y el precio son obligatorios' });
        }

        const { data, error } = await crearProducto(nombre, descripcion, precio, talla, stock, imagen);

        if (error) {
            return res.status(500).json({ error: 'Error al crear el producto' });
        }

        return res.status(201).json({
            mensaje: 'Producto registrado exitosamente',
            producto: data[0]
        });
    } catch (error) {
        console.error('Error en postProducto:', error);
        return res.status(500).json({ error: error.message });
    }
};