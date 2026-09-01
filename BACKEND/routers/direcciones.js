import express from "express";
import { 
    obtenerDirecciones, 
    obtenerDireccionesPorUsuario, 
    crearDireccion, 
    actualizarDireccion, 
    eliminarDireccion 
} from "../controllers/direcciones.js";

const router = express.Router();

router.get("/", obtenerDirecciones);
router.get("/usuario/:usuarioId", obtenerDireccionesPorUsuario);
router.post("/", crearDireccion);
router.put("/:id", actualizarDireccion);
router.delete("/:id", eliminarDireccion);

export default router;