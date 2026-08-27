import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { crearUsuario,obtenerPorEmail} from '../modelos/user.js';

//registro
export const registro = async (req,res)=>{
    try{
        const {nombre,email,contrasena}=req.body;
        //validar datos
    
    if(!nombre||!email||!contrasena){
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
     //guardarmos la base de datos
    const {data,error} = await crearUsuario(nombre,email,hashedPassword,rolpordefecto);
    
    if(error){
        return res.status(500).json({
            error: 'Error al registrar el usuario'
        });
    }
    return res.status(201).json({
        mensaje: 'Usuario registrado exitosamente',
        usuario: {
            id: data[0].id,
            nombre: data[0].nombre,
            email: data[0].email,
            rol: data[0].rol    
        }
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
        //generar el token jwt
        const token = jwt.sign(
            {
                id: usuario.id,
                nombre: usuario.nombre,
                email: usuario.email,
                rol: usuario.rol
            },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
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
}