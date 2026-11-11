import express from 'express';
import { 
    getUsuarios, 
    getUsuarioPorId, 
    getPerfilUsuario, 
    updateUsuario, 
    deleteUsuario, 
    actualizarTokenFCM
} from '../controllers/user.js';

const router = express.Router();

//ruta para obtener todos los usuarios
router.get('/', getUsuarios);
//ruta para obtener el perfil del usuario por correo electrónico
router.get('/perfil', getPerfilUsuario);
//ruta para actualizar el token de notificaciones FCM (¡NUEVA!)
router.post('/actualizar-token', actualizarTokenFCM); 
//ruta para obtener un usuario por id
router.get('/:id', getUsuarioPorId);
//ruta para actualizar un usuario
router.put('/actualizar/:id', updateUsuario);
//ruta para eliminar un usuario
router.delete('/eliminar/:id', deleteUsuario);

export default router;