import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});

export const enviarConfirmacionPedido = async (email, nombreUsuario, pedidoId, total) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: `✅ Pedido Confirmado - Mar&Paz #${pedidoId}`,
        html: `
            <h2>¡Gracias por tu pedido!</h2>
            <p>Hola <strong>${nombreUsuario}</strong>,</p>
            <p>Tu pedido ha sido confirmado exitosamente.</p>
            <p><strong>Número de Pedido:</strong> #${pedidoId}</p>
            <p><strong>Total:</strong> $${total.toLocaleString('es-CO')}</p>
            <p>Pronto nos comunicaremos contigo con los detalles de entrega.</p>
            <p>Saludos,<br>Administracion de Calzame</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true, message: 'Correo enviado' };
    } catch (error) {
        console.error('Error al enviar correo:', error);
        return { success: false, error: error.message };
    }
};


export const enviarCodigoVerificacion = async (emailDestino, nombreDestino, codigo) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: emailDestino,
        subject: 'Código de verificación - Calzame',
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #f0e6e6; border-radius: 12px; background: #ffffff;">
                <h2 style="color: #d81b60; text-align: center; margin-bottom: 8px;">Calzame</h2>
                <h3 style="color: #333333; text-align: center; margin-top: 0;">Verifica tu cuenta</h3>
                
                <p style="color: #555555; font-size: 15px;">Hola <strong>${nombreDestino}</strong>,</p>
                <p style="color: #555555; font-size: 15px;">Gracias por unirte a Calzame. Usa el siguiente código de verificación de 6 dígitos para activar tu cuenta:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #d81b60; background: #fdf2f4; padding: 12px 24px; border-radius: 8px;">
                        ${codigo}
                    </span>
                </div>
                
                <p style="color: #888888; font-size: 12px; text-align: center; margin-top: 30px;">
                    Si no creaste una cuenta en Calzame, puedes ignorar este correo.
                </p>
            </div>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log('Correo de verificación enviado con éxito');
        return { success: true, exito: true };
    } catch (error) {
        console.error('Error al enviar correo de verificación:', error);
        return { success: false, exito: false, error: error.message };
    }
};