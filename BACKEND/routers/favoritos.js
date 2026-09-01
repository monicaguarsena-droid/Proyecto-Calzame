import { Router } from 'express';
import { 
    getFavoritosPorUsuario, 
    postAgregarFavorito, 
    deleteFavorito 
} from '../controllers/favoritos.js';

const router = Router();

router.get('/:usuario_id', getFavoritosPorUsuario);
router.post('/', postAgregarFavorito);
router.delete('/', deleteFavorito);

export default router;