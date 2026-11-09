import { supabase } from '../config/supabase.js';

// Devuelve los datos del usuario que inició sesión (nunca la contraseña)
export const getPerfil = async (req, res) => {
    try {
        const id = req.usuario?.id;
        const email = req.usuario?.email ?? req.usuario?.correo;

        if (!id && !email) {
            console.error('❌ Perfil: el token no trae id ni email. req.usuario =', req.usuario);
            return res.status(401).json({ error: 'No se pudo identificar al usuario desde el token' });
        }

        let consulta = supabase.from('usuarios').select('*');
        consulta = id ? consulta.eq('id', id) : consulta.eq('email', email);
        const { data, error } = await consulta.maybeSingle();

        if (error) {
            console.error('❌ Perfil: error de Supabase', error);
            return res.status(500).json({ error: 'Error al obtener el perfil', detalle: error.message });
        }
        if (!data) {
            return res.status(404).json({ error: 'No se encontró el usuario' });
        }

        return res.status(200).json({
            usuario: {
                id: data.id,
                nombre: data.nombre ?? '',
                cedula: data.cedula ?? '',
                email: data.email ?? '',
                telefono: data.telefono ?? data.celular ?? '',
            },
        });
    } catch (error) {
        console.error('❌ Perfil: error inesperado', error);
        return res.status(500).json({ error: error.message });
    }
};