import { Router } from 'express';
import { getProductos, postProducto, putProducto, deleteProducto } from '../controllers/productos.js';
import { verificarToken, verificarAdmin, } from '../middlewares/authmiddleware.js';
import { upload} from '../config/cloudinary.js';

const router = Router();

//obtener todos los productos 
router.get('/', getProductos);

// crea un producto admin
router.post(
    '/crear',
    verificarToken,
    verificarAdmin,
    upload.fields([
        { name: 'Imagen', maxCount: 1 },
        { name: 'imagenes', maxCount: 10 },
    ]),
    postProducto,
);

// actualiza producto admin
router.put(
    '/actualizar/:id',
    verificarToken,
    verificarAdmin,
    upload.fields([{ name: 'Imagen', maxCount: 1 }]),
    putProducto,
);

// eliminar un producto admin
router.delete('/eliminar/:id', verificarToken, verificarAdmin, deleteProducto);

export default router;
