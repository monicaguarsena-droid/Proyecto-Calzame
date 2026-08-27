import express from 'express';
import { registro, login } from '../controllers/auth.js';
import { forgotPassword,verifyCode } from '../controllers/recuperar.js';

const router = express.Router();

//rutas de autenticacion
router.post('/register', registro);
router.post('/login', login);

//ruta de olvido contraseña
router.post('/forgot-password', forgotPassword);
router.post('/verify-code', verifyCode);

export default router;
