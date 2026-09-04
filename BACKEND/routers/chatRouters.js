import express from 'express';
import { chatearConCalzame, obtenerHistorialCalzame } from '../controllers/chatCalzame.js';

const router = express.Router();

router.post('/',chatearConCalzame);
router.get('/historial/:sesionId', obtenerHistorialCalzame);

export default router;
