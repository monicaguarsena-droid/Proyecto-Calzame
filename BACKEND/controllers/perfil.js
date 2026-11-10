import { supabase } from '../config/supabase.js';

const soloDigitos = (valor) => String(valor ?? '').replace(/\D/g, '');

// Datos que la app puede ver (nunca la contraseña)
const formatoUsuario = (data) => ({
    id: data.id,
    nombre: data.nombre ?? '',
    cedula: data.cedula ?? '',
    email: data.email ?? '',
    telefono: data.telefono ?? data.celular ?? '',
});

// GET /perfil  → datos del usuario que inició sesión
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

        return res.status(200).json({ usuario: formatoUsuario(data) });
    } catch (error) {
        console.error('❌ Perfil: error inesperado', error);
        return res.status(500).json({ error: error.message });
    }
};

// PUT /perfil  { nombre, telefono, cedula }
//  - El correo no se puede cambiar desde aquí.
//  - La cédula solo se puede guardar si todavía no tiene una (los pedidos dependen de ella).
export const putPerfil = async (req, res) => {
    try {
        const id = req.usuario?.id;
        if (!id) {
            return res.status(401).json({ error: 'No se pudo identificar al usuario desde el token' });
        }

        const { data: actual, error: errorActual } = await supabase
            .from('usuarios')
            .select('*')
            .eq('id', id)
            .maybeSingle();
        if (errorActual) {
            console.error('❌ Perfil: error leyendo el usuario', errorActual);
            return res.status(500).json({ error: 'Error al leer tu perfil', detalle: errorActual.message });
        }
        if (!actual) {
            return res.status(404).json({ error: 'No se encontró el usuario' });
        }

        const cambios = {};

        if (req.body.nombre !== undefined) {
            const nombre = String(req.body.nombre).trim();
            if (nombre.length < 2) {
                return res.status(400).json({ error: 'El nombre es obligatorio' });
            }
            cambios.nombre = nombre;
        }

        if (req.body.telefono !== undefined) {
            const telefono = String(req.body.telefono).trim();
            if (telefono && soloDigitos(telefono).length < 7) {
                return res.status(400).json({ error: 'Escribe un teléfono válido' });
            }
            cambios.telefono = telefono;
        }

        const tieneCedula =
            actual.cedula !== null && actual.cedula !== undefined && String(actual.cedula).trim() !== '';
        if (req.body.cedula !== undefined && !tieneCedula) {
            const cedula = soloDigitos(req.body.cedula);
            if (cedula) {
                if (cedula.length < 5) {
                    return res.status(400).json({ error: 'Escribe una cédula válida' });
                }
                cambios.cedula = cedula;
            }
        }

        if (Object.keys(cambios).length === 0) {
            return res.status(200).json({ message: 'No había cambios', usuario: formatoUsuario(actual) });
        }

        const { data, error } = await supabase
            .from('usuarios')
            .update(cambios)
            .eq('id', id)
            .select('*')
            .maybeSingle();

        if (error) {
            console.error('❌ Perfil: error al actualizar', error);
            if (error.code === '23505') {
                return res.status(409).json({ error: 'Esa cédula ya está registrada en otra cuenta' });
            }
            return res.status(500).json({ error: 'Error al actualizar el perfil', detalle: error.message });
        }

        return res.status(200).json({ message: 'Perfil actualizado', usuario: formatoUsuario(data) });
    } catch (error) {
        console.error('❌ Perfil: error inesperado', error);
        return res.status(500).json({ error: error.message });
    }
};