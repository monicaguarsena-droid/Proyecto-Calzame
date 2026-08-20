import express from 'express';
import { getProductos, postProducto } from '../controllers/productos.js';

const router = express.Router();

// Ruta para ver el catalogo de zapatos
router.get('/', getProductos);

// Ruta para guardar un zapato nuevo
router.post('/crear', postProducto);

export default router;