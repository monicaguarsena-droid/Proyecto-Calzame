import { supabase } from '../config/supabase.js';


export const crearUsuario = async (cedula,nombre, email, contrasena, rol,codigoVerificacion,codigoVerificacionExpiracion) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({ 
            cedula,
            nombre, 
            email, 
            contrasena, 
            rol: rol || 'usuarios',
            isVerified: false,
            codigoVerificacion,
            codigoVerificacionExpiracion, 
        })
        .select('id, nombre, email, rol,isVerified');
    return { data, error };
};

// Obtener todos los usuarios
export const obtenerUsuarios = async () => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, cedula, nombre, email, rol,isVerified');
    return { data, error };
};

// Obtener un usuario por email para el login
export const obtenerPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .single();
    return { data, error };
};

// Obtener un usuario por id
export const obtenerUsuarioPorId = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, cedula, nombre, email, rol,isVerified')
        .eq('id', id)
        .single();
    return { data, error };
};

// Actualizar un usuario
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select('id, cedula, nombre, email, rol,isVerified');
    return { data, error };
};

// Eliminar un usuario
export const eliminarUsuario = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id', id);
    return { data, error };
};