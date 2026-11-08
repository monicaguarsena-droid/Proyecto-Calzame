import { Router } from 'express';
import {
    getProductos,
    getProductosPorCategoria,
    postProducto,
    putProducto,
    deleteProducto,
} from '../controllers/productos.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

// Acepta varias fotos tanto en 'imagenes' como en 'Imagen'
const camposImagenes = upload.fields([
    { name: 'Imagen', maxCount: 10 },
    { name: 'imagenes', maxCount: 10 },
]);

router.get('/', getProductos);
router.get('/categoria/:categoria', getProductosPorCategoria);

router.post('/crear', verificarToken, verificarAdmin, camposImagenes, postProducto);
router.put('/actualizar/:id', verificarToken, verificarAdmin, camposImagenes, putProducto);
router.delete('/eliminar/:id', verificarToken, verificarAdmin, deleteProducto);

export default router;