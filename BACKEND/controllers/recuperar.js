import { crearCodigoRecuperar, obtenerCodigoValido, marcarCodigoUsado } from "../modelos/recuperar.js";
import { obtenerPorEmail, actualizarUsuario } from "../modelos/user.js";
import { enviarCorreo } from "../config/brevo.js";
import bcrypt from "bcrypt";

// Enviar el código de recuperación al correo
export const forgotPassword = async (req, res) => {
    try {
        const email = String(req.body.email ?? '').trim();

        if (!email) {
            return res.status(400).json({ message: "El correo es requerido" });
        }

        // Verificamos si el usuario existe
        const { data: usuario, error: errorUsuario } = await obtenerPorEmail(email);

        if (errorUsuario || !usuario) {
            return res.status(404).json({ message: "Usuario no encontrado" });
        }

        // Generamos el código de recuperación
        const codigo = Math.floor(100000 + Math.random() * 900000).toString();

        // Guardamos el código (esto invalida los códigos anteriores del usuario)
        await crearCodigoRecuperar(usuario.id, codigo);

        // Enviamos el correo con el código
        try {
            await enviarCorreo({
                to: email,
                nombre: usuario.nombre,
                subject: `Tu código de recuperación es: ${codigo}`,
                html: `
                <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px;">
                    <h2>Recuperación de Contraseña</h2>
                    <p>Hola ${usuario.nombre || 'usuario'},</p>
                    <p>Tu código de recuperación es:</p>
                    <h1 style="color: #ff78fb; font-size: 36px;">${codigo}</h1>
                    <p>Este código es válido por 15 minutos. Si no solicitaste este código, por favor ignora este correo.</p>
                    <p>Gracias,</p>
                    <p>El equipo de soporte</p>
                    <p style="color: #888; font-size: 12px;">No compartas este código con nadie</p>
                </div>
                `
            });
        } catch (errorCorreo) {
            console.error("No se pudo enviar el correo de recuperación:", errorCorreo);
            return res.status(500).json({ message: "No se pudo enviar el correo. Intenta de nuevo en unos minutos." });
        }

        return res.status(200).json({ message: "Código de recuperación enviado al correo" });

    } catch (error) {
        console.error("Error en forgotPassword:", error);
        return res.status(500).json({ message: "Error al enviar el código de recuperación" });
    }
};

// Verificar el código y cambiar la contraseña
export const verifyCode = async (req, res) => {
    try {
        const email = String(req.body.email ?? '').trim();
        const codigo = String(req.body.codigo ?? '').trim();
        const newPassword = String(req.body.newPassword ?? '');

        // Verificamos la entrada
        if (!email || !codigo || !newPassword) {
            return res.status(400).json({ message: "Todos los campos son requeridos" });
        }
        if (newPassword.length < 6) {
            return res.status(400).json({ message: "La contraseña debe tener al menos 6 caracteres" });
        }

        // Verificamos si el usuario está en la base de datos
        const { data: usuario } = await obtenerPorEmail(email);
        if (!usuario) {
            return res.status(404).json({ message: "Usuario no encontrado" });
        }

        // Verificamos el código de recuperación
        const { data: codigoRecord } = await obtenerCodigoValido(usuario.id, codigo);
        if (!codigoRecord) {
            return res.status(400).json({ message: "Código de recuperación inválido o expirado" });
        }

        // Encriptamos la nueva contraseña
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Actualizamos la contraseña del usuario en la base de datos
        const { error: updateError } = await actualizarUsuario(usuario.id, { contrasena: hashedPassword });
        if (updateError) throw updateError;

        // Marcamos el código como usado
        await marcarCodigoUsado(codigoRecord.id);

        // Correo de confirmación: si falla, la contraseña ya cambió, así que no es un error para el cliente
        try {
            await enviarCorreo({
                to: email,
                nombre: usuario.nombre,
                subject: "Contraseña cambiada exitosamente",
                html: `
                <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px;">
                    <h2 style="color: #333;">Notificación de Cambio de Contraseña</h2>
                    <p>Hola ${usuario.nombre || 'usuario'},</p>
                    <p>Te informamos que tu contraseña ha sido cambiada exitosamente.</p>
                    <div style="background-color: #f9f9f9; padding: 15px; border-left: 4px solid #f389ff; margin: 20px 0;">
                        <p style="margin: 0; font-size: 14px; color: #555;">Si no realizaste este cambio, te recomendamos que cambies tu contraseña inmediatamente y contactes a nuestro soporte.</p>
                    </div>
                    <p style="color: #555; font-size: 14px; margin-top: 30px;">Gracias,</p>
                </div>
                `
            });
        } catch (errorCorreo) {
            console.error("No se pudo enviar el correo de confirmación:", errorCorreo);
        }

        return res.status(200).json({ message: "Contraseña cambiada exitosamente" });

    } catch (error) {
        console.error("Error en verifyCode:", error);
        return res.status(500).json({ message: "Error al cambiar la contraseña" });
    }
};