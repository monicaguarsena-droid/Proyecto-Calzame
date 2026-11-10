import { Router } from 'express';
import { getPerfil, putPerfil } from '../controllers/perfil.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = Router();

router.get('/', verificarToken, getPerfil);
router.put('/', verificarToken, putPerfil);

export default router;