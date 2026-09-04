
import express from "express";
import { chatearConMimos, obtenerHistorialMimos } from "../controllers/chatMimosController.js";

const router = express.Router();

router.post("/", chatearConMimos);
router.get("/historial/:sesionId", obtenerHistorialMimos);

export default router;