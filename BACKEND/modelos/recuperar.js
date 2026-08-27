import {supabase} from "../config/supabase.js";

//crear codigo de recuperacion
export const crearCodigoRecuperar = async (usuarioId,codigo)=>{
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); //expira en 15 minutos

    const{data, error} = await supabase
    .from('recovery_codes')
    .insert({
        usuario_id: usuarioId,
        codigo: codigo,
        expires_at: expiresAt.toISOString()
    })
    .select();

    return {data, error};
};
//obtener codigo no utilizado por usuario
export const obtenerCodigoValido = async (usuarioId,codigo) =>{
    const {data, error} = await supabase
    .from('recovery_codes')
    .select('*')
    .eq('usuario_id', usuarioId)
    .eq('codigo', codigo)
    .eq('usado', false)
    .gt('expires_at', new Date().toISOString())
    .single();

    return {data, error};
};
//marcar codigo como usado
export const marcarCodigoUsado = async (codigoId) =>{
    const {data, error} = await supabase
    .from('recovery_codes')
    .update({usado: true})
    .eq('id', codigoId);

    return {data, error};
};