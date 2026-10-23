import express from 'express';
import { 
    obtenerEstadisticasAdmin, 
    crearProductoAdmin, 
    actualizarProductoAdmin, 
    eliminarProductoAdmin, 
    obtenerProductosAdmin,
    obtenerClientesAdmin,
    obtenerPedidosAdmin,
    actualizarEstadoPedidoAdmin,
    obtenerCategoriasAdmin,   
    crearCategoriaAdmin,     
    eliminarCategoriaAdmin
} from '../controllers/admin.js';

const router = express.Router();

router.get('/estadisticas', obtenerEstadisticasAdmin);
router.post('/productos', crearProductoAdmin);
router.put('/productos/:id', actualizarProductoAdmin);
router.delete('/productos/:id', eliminarProductoAdmin);
router.get('/clientes', obtenerClientesAdmin);
router.get('/pedidos', obtenerPedidosAdmin);
router.put('/pedidos/:id/estado', actualizarEstadoPedidoAdmin);
router.get('/categorias', obtenerCategoriasAdmin);  
router.post('/categorias', crearCategoriaAdmin);  
router.delete('/categorias/:id', eliminarCategoriaAdmin);

export default router;