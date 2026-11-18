import { Router } from 'express';
import { getPerfil, putPerfil, deletePerfil } from '../controllers/perfil.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = Router();

router.get('/', verificarToken, getPerfil);
router.put('/', verificarToken, putPerfil);
router.delete('/', verificarToken, deletePerfil);

export default router;