import { supabase } from "../config/supabase.js";

// Crear código de recuperación
export const crearCodigoRecuperar = async (usuarioId, codigo) => {
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

// Obtener código no utilizado por usuario
export const obtenerCodigoValido = async (usuarioId, codigo) => {
    const { data, error } = await supabase
        .from('recovery_code')
        .select('*')
        .eq('Usuario_Id', usuarioId)
        .eq('Codigo', codigo)
        .eq('usado', false)
        .gt('Expires', new Date().toISOString())
        .single();

    if (error) throw error;
    return data;
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