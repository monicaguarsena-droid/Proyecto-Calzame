import express from 'express';
import { 
    obtenerEstadisticasAdmin, 
    crearProductoAdmin, 
    actualizarProductoAdmin, 
    obtenerClientesAdmin,
    obtenerPedidosAdmin,
    actualizarEstadoPedidoAdmin 
} from '../controllers/admin.js';

const router = express.Router();

router.get('/estadisticas', obtenerEstadisticasAdmin);
router.post('/productos', crearProductoAdmin);
router.put('/productos/:id', actualizarProductoAdmin);
router.get('/clientes', obtenerClientesAdmin);
router.get('/pedidos', obtenerPedidosAdmin);
router.put('/pedidos/:id/estado', actualizarEstadoPedidoAdmin);

export default router;