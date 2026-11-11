import { supabase } from "../config/supabase.js";

// Crear código de recuperación (los códigos anteriores del usuario dejan de valer)
export const crearCodigoRecuperar = async (usuarioId, codigo) => {
    const { error: errorInvalidar } = await supabase
        .from('recovery_code')
        .update({ usado: true })
        .eq('Usuario_Id', usuarioId)
        .eq('usado', false);

    if (errorInvalidar) throw errorInvalidar;

    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // Expira en 15 minutos

    const { data, error } = await supabase
        .from('recovery_code')
        .insert({
            Usuario_Id: usuarioId,
            Codigo: codigo,
            Expires: expiresAt.toISOString(),
            usado: false
        })
        .select();

    if (error) throw error;
    return data;
};

// Obtener código no utilizado y vigente por usuario
export const obtenerCodigoValido = async (usuarioId, codigo) => {
    const { data, error } = await supabase
        .from('recovery_code')
        .select('*')
        .eq('Usuario_Id', usuarioId)
        .eq('Codigo', codigo)
        .eq('usado', false)
        .gt('Expires', new Date().toISOString())
        .maybeSingle();

    if (error) throw error;
    return { data, error };
};

// Marcar código como usado
export const marcarCodigoUsado = async (codigoId) => {
    const { data, error } = await supabase
        .from('recovery_code')
        .update({ usado: true })
        .eq('id', codigoId)
        .select();

    if (error) throw error;
    return data;
};