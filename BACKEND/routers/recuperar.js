import express from "express";
import { forgotPassword, verifyCode } from "../controllers/recuperar.js";

const router = express.Router();

// Ruta para solicitar y enviar el código de recuperación al correo
router.post("/forgot-password", forgotPassword);

// Ruta para verificar el código y actualizar la contraseña
router.post("/verify-code", verifyCode);

export default router;