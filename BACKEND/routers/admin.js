import express from 'express';
import { 
    obtenerEstadisticasAdmin, 
    crearProductoAdmin, 
    actualizarProductoAdmin, 
    obtenerClientesAdmin 
} from '../controllers/admin.js';

const router = express.Router();

router.get('/estadisticas', obtenerEstadisticasAdmin);
router.post('/productos', crearProductoAdmin);
router.put('/productos/:id', actualizarProductoAdmin);
router.get('/clientes', obtenerClientesAdmin);

export default router;