import { Router } from 'express';
import { getCategorias, getCategoriaPorId, postCategoria, putCategoria, deleteCategoria } from '../controllers/categorias.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import { upload } from '../config/cloudinary.js';

const router = Router();

// Obtener todas las categorías
router.get("/", getCategorias);

// Obtener una categoría por ID
router.get("/:id", getCategoriaPorId);

// Crear una categoría admin (con autenticación, rol de admin y subida a Cloudinary usando 'imagen')
router.post("/", verificarToken, verificarAdmin, upload.single('imagen'), postCategoria);

// Actualizar una categoría admin (con autenticación, rol de admin y soporte opcional para nueva imagen)
router.put("/:id", verificarToken, verificarAdmin, upload.single('imagen'), putCategoria);

// Eliminar una categoría admin
router.delete("/:id", verificarToken, verificarAdmin, deleteCategoria);

export default router;