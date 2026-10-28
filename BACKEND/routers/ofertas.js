import express from 'express';
import { OfertaController } from '../controllers/ofertaController.js';

const router = express.Router();

// GET: /api/ofertas
router.get('/', OfertaController.obtenerOfertas);

// POST: /api/ofertas
router.post('/', OfertaController.crearOferta);

export default router;