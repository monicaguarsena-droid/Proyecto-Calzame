import { obtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario, eliminarUsuario} from "../modelos/user.js";
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