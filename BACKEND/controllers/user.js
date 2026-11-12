import { obtenerUsuarios, obtenerUsuarioPorId, obtenerPorEmail, actualizarUsuario, eliminarUsuario} from "../modelos/user.js";
import bcrypt from 'bcrypt';

//obtener todos los usuarios
export const getUsuarios = async (req,res)=>{
    try{
        const {data,error} = await obtenerUsuarios();
        if(error){
            return res.status(500).json({
                error: 'Error al obtener los usuarios'
            });
        }
        return res.status(200).json({ 
            usuarios: data });
    }catch(error){
        console.error('Error al obtener los usuarios:', error);
        return res.status(500).json({
            error: 'Error al obtener los usuarios'
        });
    }
};
//obtener un usuario por id
export const getUsuarioPorId = async (req,res)=>{
    try{
        const {id} = req.params;
        const {data,error} = await obtenerUsuarioPorId(id);
        if(error){
            return res.status(404).json({
                error: 'Usuario no encontrado'
            });
        }
        return res.status(200).json({ 
            usuario: data });
    }catch(error){
        console.error('Error al obtener el usuario por id:', error);
        return res.status(500).json({
            error: 'Error al obtener el usuario por id'
        });
    }
};
// Obtener perfil del usuario por correo electrónico
export const getPerfilUsuario = async (req, res) => {
    try {
        const { email } = req.query;
        
        if (!email) {
            return res.status(400).json({ error: 'El correo es obligatorio' });
        }

        // Llamas a tu modelo de base de datos (asegúrate de importar la función correspondiente)
        const { data, error } = await obtenerPorEmail(email); // O la función que uses en tu modelo

        if (error || !data) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        return res.status(200).json(data);
    } catch (error) {
        console.error('Error al obtener el perfil:', error);
        return res.status(500).json({ error: 'Error al obtener el perfil del usuario' });
    }
};
//actualizar un usuario con contraseña encriptada
export const updateUsuario = async (req,res)=>{
    try{
        const {id} = req.params;
        const campos = req.body;
        if(campos.contrasena){
            const hashedPassword = await bcrypt.hash(campos.contrasena, 10);
            campos.contrasena = hashedPassword;
        } 
        const {data,error} = await actualizarUsuario(id,campos);
        if(error){
            return res.status(500).json({
                error: 'Error al actualizar el usuario'
            });
        }
        return res.status(200).json({ 
            usuario: data });
    }catch(error){
        console.error('Error al actualizar el usuario:', error);
        return res.status(500).json({
            error: 'Error al actualizar el usuario'
        });
    }
};

//eliminar un usuario
export const deleteUsuario = async (req,res)=>{
    try{
        const {id} = req.params;
        const {data,error} = await eliminarUsuario(id);
        if(error){
            return res.status(500).json({
                error: 'Error al eliminar el usuario'
            });
        }
        return res.status(200).json({ 
            mensaje: 'Usuario eliminado exitosamente' });
    }catch(error){
        console.error('Error al eliminar el usuario:', error);
        return res.status(500).json({
            error: 'Error al eliminar el usuario'
        });
    }
};
// Actualizar el token FCM del usuario
export const actualizarTokenFCM = async (req, res) => {
    try {
        const { email, fcm_token } = req.body;

        if (!email || !fcm_token) {
            return res.status(400).json({ error: 'El email y el fcm_token son obligatorios' });
        }

        // Buscamos primero al usuario por email para obtener su ID
        const { data: usuarioExistente, error: errorBusqueda } = await obtenerPorEmail(email);

        if (errorBusqueda || !usuarioExistente) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Actualizamos únicamente el campo fcm_token
        const { data, error } = await actualizarUsuario(usuarioExistente.id, { fcm_token });

        if (error) {
            return res.status(500).json({ error: 'Error al actualizar el token FCM' });
        }

        return res.status(200).json({ 
            mensaje: 'Token FCM actualizado exitosamente',
            usuario: data 
        });
    } catch (error) {
        console.error('Error al actualizar el token FCM:', error);
        return res.status(500).json({ error: 'Error interno al actualizar el token FCM' });
    }
};