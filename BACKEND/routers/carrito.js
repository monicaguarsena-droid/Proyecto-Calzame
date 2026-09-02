import express from 'express';
import { postItemCarrito, getCarritoUsuario, deleteItemCarrito } from '../controllers/carrito.js';

const router = express.Router();

// Agregar producto al carrito
router.post('/agregar', postItemCarrito);

// Obtener carrito por ID de usuario
router.get('/usuario/:usuario_id', getCarritoUsuario);

// Eliminar un producto del carrito por su ID de item
router.delete('/:id', deleteItemCarrito);

export default router;