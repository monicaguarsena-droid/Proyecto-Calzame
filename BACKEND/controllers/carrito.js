import { 
    agregarAlCarrito, 
    obtenerCarritoPorUsuario, 
    eliminarItemCarrito, 
    vaciarCarritoUsuario 
} from '../modelos/carrito.js';

export const agregarProductoCarrito = async (req, res) => {
    try {
        const item = await agregarAlCarrito(req.body);
        return res.status(201).json({ mensaje: "Producto agregado al carrito", item });
    } catch (error) {
        return res.status(400).json({ error: error.message });
    }
};

export const getCarritoUsuario = async (req, res) => {
    try {
        
        const usuario_cc = req.params.usuario_cc || req.params.id; 
        const carrito = await obtenerCarritoPorUsuario(usuario_cc);
        return res.status(200).json({ carrito });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const deleteItemCarrito = async (req, res) => {
    try {
        const { id } = req.params;
        await eliminarItemCarrito(id);
        return res.status(200).json({ mensaje: "Item eliminado del carrito" });
    } catch (error) {
        return res.status(400).json({ error: error.message });
    }
};