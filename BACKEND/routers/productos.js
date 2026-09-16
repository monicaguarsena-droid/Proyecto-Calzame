import { Router } from 'express';
import { getProductos, postProducto, putProducto, deleteProducto } from '../controllers/productos.js';
import upload, { verificarToken, verificarAdmin, } from '../middlewares/authmiddleware.js';

const router = Router();

//obtener todos los productos 
router.get('/', getProductos);

// crea un producto admin
router.post('/crear', verificarToken, verificarAdmin,upload.single('Imagen'), postProducto);

// actualiza producto admin
router.put('/actualizar/:id', verificarToken, verificarAdmin, putProducto);

// eliminar un producto admin
router.delete('/eliminar/:id', verificarToken, verificarAdmin, deleteProducto);

export default router;
