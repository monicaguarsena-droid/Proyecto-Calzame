import { supabase } from '../config/supabase.js';
//crear el usuario
export const crearUsuario = async (nombre, email, contrasena,rol) =>{
    const {data,error}=await supabase
    .from('usuarios')
    .insert({nombre,email,contrasena,rol: rol || 'usuarios'})
    .select('id,nombre,email,rol')
    return {data,error}
};