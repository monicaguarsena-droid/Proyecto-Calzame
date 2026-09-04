import { agregarAlCarrito, obtenerCarritoPorUsuario, eliminarItemCarrito, vaciarCarritoUsuario } from '../modelos/carrito.js';

// Agregar producto al carrito
export const postItemCarrito = async (req, res) => {
    try {
        const { usuario_id, producto_id, cantidad, precio } = req.body;

        if (!usuario_id || !producto_id || !cantidad || !precio) {
            return res.status(400).json({ error: 'Faltan datos obligatorios para el carrito' });
        }

        const { data, error } = await agregarAlCarrito({ usuario_id, producto_id, cantidad, precio });

        if (error) {
            console.log("Error detallado de Supabase:", error);
            return res.status(500).json({ error: 'Error al agregar producto al carrito', detalle: error.message });
        }

        return res.status(201).json({
            message: 'Producto agregado al carrito',
            item: data ? data[0] : null
        });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Obtener el carrito de un usuario
export const getCarritoUsuario = async (req, res) => {
    try {
        const { usuario_id } = req.params;

        const { data, error } = await obtenerCarritoPorUsuario(usuario_id);

        if (error) {
            console.log("Error al obtener carrito:", error);
            return res.status(500).json({ error: 'Error al obtener el carrito', detalle: error.message });
        }

        return res.status(200).json({ carrito: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

// Eliminar un item específico del carrito
export const deleteItemCarrito = async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await eliminarItemCarrito(id);

        if (error) {
            console.log("Error al eliminar item del carrito:", error);
            return res.status(500).json({ error: 'Error al eliminar el producto del carrito', detalle: error.message });
        }

        return res.status(200).json({ message: 'Producto eliminado del carrito', data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};