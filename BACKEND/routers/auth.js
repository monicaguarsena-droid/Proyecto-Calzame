import express from 'express';
import { registro, login, verificaCuenta } from '../controllers/auth.js';
import { forgotPassword, verifyCode } from '../controllers/recuperar.js';

const router = express.Router();

// Rutas de autenticación
router.post('/register', registro);
router.post('/login', login);
router.post('/verificar-cuenta', verificaCuenta); // <--- Agrega esta ruta

// Ruta de olvido contraseña
router.post('/forgot-password', forgotPassword);
router.post('/verify-code', verifyCode);

export default router;