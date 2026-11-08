import {
    agregarAlCarrito,
    obtenerCarritoPorUsuario,
    actualizarCantidadCarrito,
    eliminarItemCarrito,
    vaciarCarritoUsuario
} from '../modelos/carrito.js';
import { supabase } from '../config/supabase.js';

// usuario_cc es la cédula: probamos los nombres más comunes dentro del token
const usuarioCarritoId = (req) =>
    req.usuario?.cedula ??
    req.usuario?.cc ??
    req.usuario?.usuario_cc ??
    req.usuario?.id;

export const postItemCarrito = async (req, res) => {
    try {
        const { producto_id, cantidad = 1, talla = 'Única', color = 'Único' } = req.body;
        const productoIdNumero = Number(producto_id);
        const cantidadNumero = Number(cantidad);

        if (!Number.isInteger(productoIdNumero) || !Number.isInteger(cantidadNumero) || cantidadNumero < 1) {
            return res.status(400).json({ error: 'El producto y una cantidad válida son obligatorios' });
        }

        const usuarioId = usuarioCarritoId(req);
        if (usuarioId === undefined || usuarioId === null || usuarioId === '') {
            console.error('❌ Carrito: el token no trae la cédula. req.usuario =', req.usuario);
            return res.status(401).json({ error: 'No se pudo identificar al usuario desde el token' });
        }

        const { data: producto, error: errorProducto } = await supabase
            .from('Productos')
            .select('Precio')
            .eq('id', productoIdNumero)
            .single();
        if (errorProducto || !producto) {
            console.error('❌ Carrito: producto no encontrado', productoIdNumero, errorProducto);
            return res.status(404).json({ error: 'No se encontró el producto seleccionado' });
        }

        const { data, error, actualizado } = await agregarAlCarrito({
            usuario_id: usuarioId,
            producto_id: productoIdNumero,
            cantidad: cantidadNumero,
            precio: Number(producto.Precio),
            talla,
            color
        });
        if (error) {
            console.error('❌ Carrito: falló el guardado. usuario_cc =', usuarioId, '| error =', error);
            return res.status(500).json({ error: 'Error al agregar producto al carrito', detalle: error.message });
        }

        // 200 si ya existía el mismo producto/talla/color y se sumó la cantidad; 201 si es nuevo
        return res
            .status(actualizado ? 200 : 201)
            .json({ message: 'Producto agregado al carrito', item: data });
    } catch (error) {
        console.error('❌ Carrito: error inesperado', error);
        return res.status(500).json({ error: error.message });
    }
};

export const getCarritoUsuario = async (req, res) => {
    try {
        const { data, error } = await obtenerCarritoPorUsuario(usuarioCarritoId(req));
        if (error) {
            console.error('❌ Carrito: error al obtener', error);
            return res.status(500).json({ error: 'Error al obtener el carrito', detalle: error.message });
        }
        return res.status(200).json({ carrito: data ?? [] });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const putItemCarrito = async (req, res) => {
    try {
        const cantidad = Number(req.body.cantidad);
        if (!Number.isInteger(cantidad) || cantidad < 1) {
            return res.status(400).json({ error: 'La cantidad debe ser un entero mayor que cero' });
        }
        const { data, error } = await actualizarCantidadCarrito(
            req.params.id,
            usuarioCarritoId(req),
            cantidad
        );
        if (error) {
            return res.status(500).json({ error: 'Error al actualizar la cantidad', detalle: error.message });
        }
        if (!data) return res.status(404).json({ error: 'No se encontró el producto en el carrito' });
        return res.status(200).json({ item: data });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const deleteItemCarrito = async (req, res) => {
    try {
        const { data, error } = await eliminarItemCarrito(
            req.params.id,
            usuarioCarritoId(req)
        );
        if (error) {
            return res.status(500).json({ error: 'Error al eliminar el producto del carrito', detalle: error.message });
        }
        if (!data) return res.status(404).json({ error: 'No se encontró el producto en el carrito' });
        return res.status(200).json({ message: 'Producto eliminado del carrito' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};

export const deleteCarritoUsuario = async (req, res) => {
    try {
        const { error } = await vaciarCarritoUsuario(usuarioCarritoId(req));
        if (error) {
            return res.status(500).json({ error: 'Error al vaciar el carrito', detalle: error.message });
        }
        return res.status(200).json({ message: 'Carrito vaciado' });
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};