import express from 'express';
import {
    postPedido,
    getMisPedidos,
    getPedidosAdmin,
    putEstadoPedido,
    deletePedido
} from '../controllers/pedidos.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';

const router = express.Router();

// Todas las rutas de pedidos requieren sesión iniciada
router.use(verificarToken);

// Cliente
router.post('/crear', postPedido);
router.get('/mis-pedidos', getMisPedidos);

// Administrador
router.get('/admin', verificarAdmin, getPedidosAdmin);
router.put('/:id/estado', verificarAdmin, putEstadoPedido);
router.delete('/:id', verificarAdmin, deletePedido);

export default router;