import express from 'express';
import { postPedido, getPedidosUsuario } from '../controllers/pedidos.js';

const router = express.Router();

// guardar un pedido nuevbo
router.post('/crear', postPedido);

// ver compras de un cliente que uno quiera buscar 
router.get('/usuario/:usuario_id', getPedidosUsuario);

export default router;