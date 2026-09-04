import { Router } from "express";
import { chatearConMimos, obtenerHistorialMimos } from "../controllers/chatBot.js";

const router = Router();

router.post("/", chatearConMimos);
router.get("/historial/:sesionId", obtenerHistorialMimos);

export default router;