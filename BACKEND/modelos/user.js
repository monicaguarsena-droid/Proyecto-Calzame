import { supabase } from '../config/supabase.js';

export const crearUsuario = async (tipo_documento, cedula, nombre, email, contrasena, rol, codigoVerificacion, codigoVerificacionExpiracion) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            tipo_documento,
            cedula: Number(cedula),
            nombre,
            email,
            contrasena,
            rol: rol || 'usuario',
            isVerified: false,
            codigoVerificacion,
            codigoVerificacionExpiracion
        })
        .select('id, tipo_documento, cedula, nombre, email, rol, isVerified');
    return { data, error };
};

// Obtener todos los usuarios
export const obtenerUsuarios = async () => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, tipo_documento, cedula, nombre, email, rol, isVerified');
    return { data, error };
};

// Obtener un usuario por email para el login
export const obtenerPorEmail = async (email) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .maybeSingle();
    return { data, error };
};
export const obtenerPorDocumento = async (tipo_documento, cedula) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id')
        .eq('tipo_documento', tipo_documento)
        .eq('cedula', Number(cedula))
        .maybeSingle();
    return { data, error };
};
// Obtener un usuario por id
export const obtenerUsuarioPorId = async (id) => {
    const { data, error } = await supabase
        .from('usuarios')
        .select('id, tipo_documento, cedula, nombre, email, rol, isVerified')
        .eq('id', id)
        .single();
    return { data, error };
};

//funcion especifica para los usuarios autenticados con google
export const crearUsuarioGoogle = async ({tipo_documento, cedula, nombre, email, googleId, avatar = null, rol = 'cliente'}) => {
    const {data,error} = await supabase
    .from('usuarios')
    .insert({
        tipo_documento,
        cedula: Number(cedula),
        nombre,
        email,
        contrasena: null, //no requiere contraseña
        rol,
        isVerified: true,
        googleId,
        avatar,
        codigoVerificacion: null,
        codigoVerificacionExpiracion:null
    })
    .select('id, tipo_documento, cedula, nombre, email, rol, isVerified')
    .single();

    return {data,error};
};
 

// Actualizar un usuario
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select()
        .single();

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