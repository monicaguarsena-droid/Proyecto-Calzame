import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import {supabase} from '../config/supabase.js';
import { crearUsuario,obtenerPorEmail} from '../modelos/user.js';
import { enviarCodigoVerificacion } from '../utils/emailservices.js';


//registro
export const registro = async (req,res)=>{
    try{
        const {cedula, nombre,email,contrasena}=req.body;
        //validar datos
    
    if(!cedula||!nombre||!email||!contrasena){
        return res.status (400).json({
            error: 'faltan usuarios'
        });
    }
    //verificamos el gmail si ya existe
    const {data: usuarioExiste} = await obtenerPorEmail(email);
    if(usuarioExiste){
        return res.status(400).json({
            error: 'El Email ya esta registrado'
        });
    }
    //encriptar la contraseña
    const hashedPassword = await bcrypt.hash(contrasena, 10);
    //crear la constante  para rol por default
    const rolpordefecto = 'usuario';
    //generar codigo de verificacion
    const codigoVerificacion = Math.floor(100000 + Math.random() * 900000).toString();
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos
     //guardarmos la base de datos
    const {data,error} = await crearUsuario(cedula,nombre,email,hashedPassword,rolpordefecto,codigoVerificacion,codigoVerificacionExpiracion);
    
    if(error){
        return res.status(500).json({
            error: 'Error al registrar el usuario'
        });
    }

    const resultadoEnvio = await enviarCodigoVerificacion(email, nombre, codigoVerificacion);

    const usuarioCreado = Array.isArray(data) ? data[0] : data;

    const  usuarioRespuesta = {
        id: usuarioCreado.id,
        cedula: usuarioCreado.cedula,
        nombre: usuarioCreado.nombre,
        email: usuarioCreado.email,
        rol: usuarioCreado.rol
    }
    if (!resultadoEnvio.exito) {
        return res.status(201).json({
            message:'Tu cuenta fue creada, pero hubo un problema enviando el codigo de verificacion a tu correo. Intenta registrarte de nuevo en unos minutos o contacta soporte.',
            emailEnviado: false,
            usuario: usuarioRespuesta
        });
    }
    return res.status(201).json({
        mensaje: 'Usuario registrado exitosamente. Hemos enviado un codigo de 6 digitos a tu correo.',
        emailEnviado: true,
        usuario: usuarioRespuesta
        });

    }catch(error){
        console.error('Error en el registro:', error);
        return res.status(500).json({
            error: error.message
        });
}
};

//crear el login
export const login = async (req, res) => {
    try{
        const { email, contrasena } = req.body;
        //validar datos
        if (!email || !contrasena) {
            return res.status(400).json({
                error: 'todos los campos son requeridos: email y contraseña'
            });
        }
        //validamos si el correo existe
        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(401).json({
                error: 'el email no esta registrado'
            });
        }

        //validar la contraseña
        const contraseñavalida = await bcrypt.compare(contrasena, usuario.contrasena);
        if (!contraseñavalida) {
            return res.status(400).json({
                error: 'Contraseña incorrecta'
            });
        }
        if (!usuario.isVerified){
            return res.status(403).json({
                error: 'Tu cuenta no ha sido veriificada. Por favor ingresa el codigo enviado a tu correo antes de iniciar sesion.'
            });
        }
        //generar el token jwt
        const token = jwt.sign(
            {
                id: usuario.id,
                rol: usuario.rol
            },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        return res.status(200).json({
            mensaje: 'Login exitoso',
            token,
            usuario:{
                id:usuario.id,
                nombre:usuario.nombre,
                email: usuario.email,
                rol:usuario.rol
            }
        });
   

     } catch(error){
        console.error('Error en el login:', error);
        return res.status(500).json({
            error: error.message
        });
    }
};

//verificar cuenta con codigo de 6 digitos 
export const verificarCuenta = async (req, res) => {
  try {
    const { email, codigo } = req.body;

    if (!email || !codigo) {
      return res.status(400).json({
        error: 'El email y el codigo de verificacion son requeridos'
      });
    }

    // 1. Buscar al usuario en Supabase
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

    // 2. Revisar si ya esta activo
    if (usuario.isVerified) {
      return res.status(400).json({
        error: 'La cuenta ya se encuentra verificada'
      });
    }

    // 3. Comparar el codigo
    if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()) {
      return res.status(400).json({
        error: 'El codigo de verificacion es incorrecto'
      });
    }

    // 4. Validar expiracion (15 minutos)
    const ahora = new Date();
    const expiracion = new Date(usuario.codigoVerificacionExpiracion);

    if (ahora > expiracion) {
      return res.status(400).json({
        error: 'El codigo ha expirado. Por favor solicita uno nuevo'
      });
    }

    // 5. Activar la cuenta
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
      message: 'Cuenta verificada exitosamente. Ya puedes iniciar sesion en Mimos.'
    });

  } catch (error) {
    console.error('Error en verificarCuenta:', error);
    return res.status(500).json({
      error: error.message
    });
  }
};