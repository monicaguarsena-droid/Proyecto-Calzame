import multer from 'multer';
import express from "express";
import { obtenerCategorias, obtenerCategoriaPorId, crearCategoria, actualizarCategoria, eliminarCategoria } from "../controllers/categorias.js";

const upload = multer({dest: 'upload/'});
const router = express.Router();

router.get("/", obtenerCategorias);
router.get("/:id", obtenerCategoriaPorId);
router.post("/", upload.single('imagen'), crearCategoria);
router.put("/:id", upload.single('imagen'), actualizarCategoria);
router.delete("/:id", eliminarCategoria);

export default router;