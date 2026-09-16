import { Router } from 'express';
import { 
    obtenerFavoritosUsuario, 
    obtenerTodosFavoritos, 
    crearFavorito, 
    eliminarFavoritoController 
} from '../controllers/favoritos.js';

const router = Router();

//  Obtener todos
router.get('/', obtenerTodosFavoritos);

//  Obtener por usuario
router.get('/usuario/:usuario_id', obtenerFavoritosUsuario);

//  Agregar
router.post('/', crearFavorito);

// Eliminar
router.delete('/', eliminarFavoritoController);

export default router;