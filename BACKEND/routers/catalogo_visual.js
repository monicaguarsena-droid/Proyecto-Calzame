import { Router } from "express";
import { upload } from "../config/cloudinary.js";
import { verificarAdmin, verificarToken } from "../middlewares/authmiddleware.js";
import {
    ofertasController,
    tiposCalzadoController
} from "../controllers/catalogo_visual.js";

const router = Router();
const protegerEscritura = [verificarToken, verificarAdmin];

const registrarRutas = (ruta, controlador) => {
    router.get(ruta, controlador.listar);
    router.post(
        ruta,
        ...protegerEscritura,
        upload.single("imagen"),
        controlador.crear
    );
    router.put(
        `${ruta}/:id`,
        ...protegerEscritura,
        upload.single("imagen"),
        controlador.actualizar
    );
    router.delete(`${ruta}/:id`, ...protegerEscritura, controlador.eliminar);
};

registrarRutas("/ofertas", ofertasController);
registrarRutas("/tipos-calzado", tiposCalzadoController);

export default router;
