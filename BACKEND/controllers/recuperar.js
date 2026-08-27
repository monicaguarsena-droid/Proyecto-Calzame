import {crearCodigoRecuperar, obtenerCodigoValido,marcarCodigoUsado} from "../modelos/recuperar.js";
import {obtenerPorEmail, actualizarUsuario} from "../modelos/user.js";
import bcrypt from "bcrypt";
import nodemailer from "nodemailer";

//configuramos el transporte de nodemailer
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});
//configurar la logica para enviar el correo de recuperación
export const forgotPassword = async (req, res) => {
    try{
        const {email}=req.body;

        if(!email){
            return res.status(400).json({message: "El correo es requerido"});
        }
        //verificamos si el usuario existe
        const {data: usuario, error: errorUsuario} = await obtenerPorEmail(email);

        if(errorUsuario || !usuario){
            return res.status(404).json({message: "Usuario no encontrado"});
        }
        //generamos los codigos de recuperación
        const codigo=Math.floor(100000+Math.random()*900000).toString();

        // guadar los cogidos a la base de datos
        const{error: errorCodigo} = await crearCodigoRecuperar(usuario.id, codigo);

        if(errorCodigo){
            return res.status(500).json({message: "Error al generar el código de recuperación"});
        }
        //creamos  el email del codigo 
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to:email,
            subject:`Tu codigo de recuperación es: ${codigo}`,
            html:`
            <h2>Recuperación de Contraseña</h2>
            <p>Hola ${usuario.nombre || 'usuario'},</p>
            <p>Tu codigo de recuperación es: </p>
            <h1 style="color #39a900; font-size: 36px;">${codigo}</h1>
            <p> Este codigo es valido por 15 minutos. Si no solicitaste este código, por favor ignora este correo.</p>
            <p>Gracias</p>
            <p>El equipo de soporte</p>
            <p>No compartas este codigo con nadie</p>
            `
        });
        return res.status(200).json({message: "Codigo de recuperación enviado al correo"});

    } catch (error) {
        console.error("Error en forgotPassword:", error);
        return res.status(500).json({message: "Error al enviar el codigo de recuperación"});
    }
}

//cambiar la contraseña y verificar el codigo de recuperación

export const verifyCode = async (req, res) => {
    try {
        const { email, codigo, newPassword } = req.body;
        //verificamos la entrada 
        if (!email || !codigo || !newPassword) {
            return res.status(400).json({ message: "Todos los campos son requeridos" });
        }
        //verificamos si el usuario esta en la base de datos

        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(404).json({ error: "Usuario no encontrado" });
        }
        //verificamos el codigo de recuperacion 

        const { data: codigoRecord } = await obtenerCodigoValido (usuario.id, codigo);
        if (!codigoRecord) {
            return res.status(400).json({ error: "Código de recuperación inválido o expirado" });
        }
        //encriptamos la nueva contraseña
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        //actualizamos la contraseña del usuario en la base de datos
        const {error: updateError} = await actualizarUsuario(usuario.id, { contrasena: hashedPassword });
        if (updateError) throw updateError;
        //marcamos el codigo como usado
        await marcarCodigoUsado(codigoRecord.id);
        // respondemos al cliente que la contraseña se ha cambiado exitosamente
        await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: email,
            subject: "Contraseña cambiada exitosamente",
            html: `
            <div style="font-family: sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;>
            <h2 style="color: #333;">Notificación de Cambio de Contraseña</h2>
            <p>Hola ${usuario.nombre || 'usuario'},</p>
            <p>Te informamos que tu contraseña ha sido cambiada exitosamente.</p>
            <div style="background-color: #f9f9f9; padding: 15px; border-left: 4px solid #39a900; margin: 20px 0;">
            <p style="margin: 0;"; font-size: 14px color: #555;">Si no realizaste este cambio, te recomendamos que cambies tu contraseña inmediatamente y contactes a nuestro soporte.</p>
            </div>
            <p style = color #555; font-size: 14px; margin-top 30px";
            >Gracias,</p>
            </div>

            `
        });
        return res.status(200).json({ message: "Contraseña cambiada exitosamente" });

    } catch (error) {
        console.error("Error en verifyCode:", error);
        return res.status(500).json({ message: "Error al cambiar la contraseña" });
    }
}