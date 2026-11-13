import { Router } from 'express';
import { getReporteVentas, getResumenAdmin } from '../controllers/reportes.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = Router();

router.use(verificarToken, verificarAdmin);
router.get('/resumen', getResumenAdmin);
router.get('/ventas/:periodo', getReporteVentas);

export default router;
