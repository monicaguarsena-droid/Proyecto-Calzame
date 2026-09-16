import { Router } from 'express';
import { 
    agregarProductoCarrito, 
    getCarritoUsuario, 
    deleteItemCarrito 
} from '../controllers/carrito.js';

const router = Router();


router.post('/agregar', agregarProductoCarrito);


router.get('/usuario/:usuario_cc', getCarritoUsuario);


router.delete('/:id', deleteItemCarrito);

export default router;