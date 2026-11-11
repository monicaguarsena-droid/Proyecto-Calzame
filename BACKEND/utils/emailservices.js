import { BrevoClient } from '@getbrevo/brevo';

const NOMBRE_REMITENTE = () => process.env.EMAIL_FROM_NAME || 'Mar&Paz';

/**
 * Envía un correo con la API de Brevo (HTTPS, funciona en Render gratis).
 * Lanza un error si Brevo lo rechaza, para que quien la llame lo maneje.
 * El remitente (EMAIL_USER) debe estar verificado en Brevo.
 */
export const enviarCorreo = async ({ to, nombre, subject, html }) => {
  // Se crea el cliente aquí para asegurar que ya se leyó el .env / las variables de Render
  const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY
  });

  return brevo.transactionalEmails.sendTransacEmail({
    subject,
    sender: {
      name: NOMBRE_REMITENTE(),
      email: process.env.EMAIL_USER
    },
    to: [
      {
        email: to,
        name: nombre || to
      }
    ],
    htmlContent: html
  });
};

// Correo del código de verificación al registrarse (misma función de antes, HTML corregido)
export const enviarCodigoVerificacion = async (emailDestino, nombreDestino, codigo) => {
  try {
    const result = await enviarCorreo({
      to: emailDestino,
      nombre: nombreDestino,
      subject: 'Codigo de verificacion - Mar&Paz',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #f0e6e6; border-radius: 12px; background-color: #ffffff;">
          <h2 style="color: #d81b60; text-align: center; margin-bottom: 8px;">Calzado Mar&Paz</h2>
          <h3 style="color: #333333; text-align: center; margin-top: 0;">Verifica tu cuenta</h3>

          <p style="color: #555555; font-size: 15px;">Hola <strong>${nombreDestino}</strong>,</p>
          <p style="color: #555555; font-size: 15px;">Gracias por unirte a Calzado Mar&Paz. Usa el siguiente codigo de verificacion de 6 digitos para activar tu cuenta. Este codigo vencera en <strong>15 minutos</strong>:</p>

          <div style="text-align: center; margin: 30px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #d81b60; background: #fdf2f4; padding: 12px 24px; border-radius: 8px; border: 1px dashed #d81b60; display: inline-block;">
              ${codigo}
            </span>
          </div>

          <p style="color: #888888; font-size: 12px; text-align: center; margin-top: 30px;">
            Si no creaste una cuenta en Calzado Mar&Paz, puedes ignorar este correo.
          </p>
        </div>
      `
    });

    console.log('Correo enviado con exito');
    return { exito: true, result };
  } catch (error) {
    console.error('Error enviando correo con Brevo:', error);
    return { exito: false, error };
  }
};