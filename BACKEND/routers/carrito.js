import express from 'express';
import {
    postItemCarrito,
    getCarritoUsuario,
    putItemCarrito,
    deleteItemCarrito,
    deleteCarritoUsuario
} from '../controllers/carrito.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = express.Router();

router.use(verificarToken);
router.get('/', getCarritoUsuario);
router.post('/agregar', postItemCarrito);
router.delete('/vaciar', deleteCarritoUsuario);
router.put('/:id', putItemCarrito);
router.delete('/:id', deleteItemCarrito);

export default router;