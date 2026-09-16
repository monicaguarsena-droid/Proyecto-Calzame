import express from 'express';
import { 
    postPedido, 
    getTodosLosPedidos, 
    getPedidosUsuario, 
    getPedidoPorId, 
    actualizarEstado, 
    eliminarPedido 
} from '../controllers/pedidos.js';

const router = express.Router();

//  Obtener todos los pedidos
router.get('/', getTodosLosPedidos);

//  Obtener pedido por ID con detalles
router.get('/:id', getPedidoPorId);

// Obtener pedidos por usuario
router.get('/usuario/:usuario_id', getPedidosUsuario);

//  Crear pedido
router.post('/crear', postPedido);

//  Actualizar estado del pedido
router.put('/actualizar/:id', actualizarEstado);

//  Eliminar pedido
router.delete('/eliminar/:id', eliminarPedido);

export default router;