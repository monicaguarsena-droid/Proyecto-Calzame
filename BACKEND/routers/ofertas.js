import express from 'express';
import { OfertaController } from '../controllers/ofertas.js';
import { verificarAdmin, verificarToken } from '../middlewares/authmiddleware.js';
import { upload } from '../config/cloudinary.js';

const router = express.Router();

router.get('/', OfertaController.obtenerOfertas);
router.post(
    '/',
    verificarToken,
    verificarAdmin,
    upload.single('imagen'),
    OfertaController.crearOferta
);
router.put(
    '/:id',
    verificarToken,
    verificarAdmin,
    upload.single('imagen'),
    OfertaController.actualizarOferta
);
router.delete('/:id', verificarToken, verificarAdmin, OfertaController.eliminarOferta);

export default router;