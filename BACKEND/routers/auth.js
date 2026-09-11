import { registro, login,verificarCuenta } from '../controllers/auth.js';
import { forgotPassword,verifyCode } from '../controllers/recuperar.js';
import { Router } from 'express';
import { autenticarConGoogle } from '../controllers/googleauth.js';


const router = Router();
//rutas de autenticacion
router.post('/register', registro);
router.post('/login', login);
router.post('/verify-account',verificarCuenta);

//ruta de olvido contraseña
router.post('/forgot-password', forgotPassword);
router.post('/verify-code', verifyCode);

//ruta la auntentificar con google
router.post('/google', autenticarConGoogle);

export default router;
