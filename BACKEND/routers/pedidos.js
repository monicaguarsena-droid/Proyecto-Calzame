import express from 'express';
import {
    postPedido,
    getMisPedidos,
    putOcultarPedido,
    getPedidosAdmin,
    putEstadoPedido,
    deletePedido
} from '../controllers/pedidos.js';
import { verificarToken, verificarAdmin } from '../middlewares/authmiddleware.js';
import { uploadComprobante } from '../config/cloudinary.js';

const router = express.Router();

// Todas las rutas de pedidos requieren sesión iniciada
router.use(verificarToken);

// Cliente
router.post('/crear', uploadComprobante.single('comprobante'), postPedido);
router.get('/mis-pedidos', getMisPedidos);
router.put('/:id/ocultar', putOcultarPedido);

// Administrador
router.get('/admin', verificarAdmin, getPedidosAdmin);
router.put('/:id/estado', verificarAdmin, putEstadoPedido);
router.delete('/:id', verificarAdmin, deletePedido);

export default router;