import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  service: 'email',
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