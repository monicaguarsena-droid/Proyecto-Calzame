import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { crearUsuario, obtenerPorEmail } from '../modelos/user.js';
import { enviarCodigoVerificacion } from '../utils/sendEmail.js';
import { supabase } from '../config/supabase.js';

// REGISTRO
export const registro = async (req, res) => {
    try {
        const { nombre, email, password } = req.body;


        if (!nombre || !email || !password) {
            return res.status(400).json({
                error: 'Todos los campos son requeridos: nombre, email y password'
            });
        }

   
        const { data: usuarioExiste } = await obtenerPorEmail(email);
        if (usuarioExiste) {
            return res.status(400).json({
                error: 'El email ya está registrado'
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const rolPorDefecto = 'usuario';

       
        const codigoVerificacion = Math.floor(100000 + Math.random() * 900000).toString();
        const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

       
        const { data, error } = await crearUsuario(
            nombre,
            email,
            hashedPassword,
            rolPorDefecto,
            codigoVerificacion,
            codigoVerificacionExpiracion
        );

        if (error) {
            return res.status(500).json({
                error: 'Error al crear el usuario en la base de datos'
            });
        }

       
        const resultadoEnvio = await enviarCodigoVerificacion(email, nombre, codigoVerificacion);

       
        const usuarioCreado = Array.isArray(data) ? data[0] : data;

        const usuarioRespuesta = {
            id: usuarioCreado.id,
            nombre: usuarioCreado.nombre,
            email: usuarioCreado.email,
            rol: usuarioCreado.rol
        };

        
        if (!resultadoEnvio.exito && !resultadoEnvio.success) {
            return res.status(201).json({
                message: 'Tu cuenta fue creada, pero hubo un problema enviando el código de verificación a tu correo. Intenta registrarte de nuevo en unos minutos.',
                emailEnviado: false,
                usuario: usuarioRespuesta
            });
        }

        return res.status(201).json({
            message: 'Usuario registrado con éxito. Hemos enviado un código de 6 dígitos a tu correo.',
            emailEnviado: true,
            usuario: usuarioRespuesta
        });

    } catch (error) {
        console.error('Error en registro:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};

// LOGIN
export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                error: 'El email y la contraseña son requeridos'
            });
        }

        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });
        }

        const passwordValido = await bcrypt.compare(password, usuario.password || usuario.contrasena);
        if (!passwordValido) {
            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });
        }

       
        if (!usuario.isVerified) {
            return res.status(403).json({
                error: 'Tu cuenta no ha sido verificada. Por favor ingresa el código enviado a tu correo antes de iniciar sesión.'
            });
        }

        const token = jwt.sign(
            { id: usuario.id, rol: usuario.rol },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        return res.status(200).json({
            message: 'Inicio de sesión exitoso',
            token,
            usuario: {
                id: usuario.id,
                nombre: usuario.nombre,
                email: usuario.email,
                rol: usuario.rol
            }
        });

    } catch (error) {
        console.error('Error en login:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};


export const verificaCuenta = async (req, res) => {
    try {
        const { email, codigo } = req.body;

        if (!email || !codigo) {
            return res.status(400).json({
                error: 'El email y el codigo de verificacion son requeridos'
            });
        }

       
        const { data: usuario, error: errorUsuario } = await supabase
            .from('usuarios')
            .select('id, email, isVerified, codigoVerificacion, codigoVerificacionExpiracion')
            .eq('email', email)
            .single();

        if (errorUsuario || !usuario) {
            return res.status(404).json({
                error: 'Usuario no encontrado'
            });
        }

        
        if (usuario.isVerified) {
            return res.status(400).json({
                error: 'La cuenta ya se encuentra verificada'
            });
        }

       
        if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()) {
            return res.status(400).json({
                error: 'El codigo de verificacion es incorrecto'
            });
        }

        
        const ahora = new Date();
        const expiracion = new Date(usuario.codigoVerificacionExpiracion);

        if (ahora > expiracion) {
            return res.status(400).json({
                error: 'El codigo ha expirado. Por favor solicita uno nuevo'
            });
        }

       
        const { error: errorUpdate } = await supabase
            .from('usuarios')
            .update({
                isVerified: true,
                codigoVerificacion: null,
                codigoVerificacionExpiracion: null
            })
            .eq('id', usuario.id);

        if (errorUpdate) {
            return res.status(500).json({
                error: 'Error al actualizar el estado de verificacion'
            });
        }

        return res.status(200).json({
            message: 'Cuenta verificada exitosamente. Ya puedes iniciar sesion en Calzame.'
        });

    } catch (error) {
        console.error('Error en verificaCuenta:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};