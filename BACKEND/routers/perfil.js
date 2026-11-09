import { Router } from 'express';
import { getPerfil } from '../controllers/perfil.js';
import { verificarToken } from '../middlewares/authmiddleware.js';

const router = Router();

router.get('/', verificarToken, getPerfil);

export default router;