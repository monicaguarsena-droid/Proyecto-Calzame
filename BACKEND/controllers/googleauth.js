import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import { obtenerPorEmail, crearUsuarioGoogle, actualizarUsuario } from "../modelos/user.js";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Solo devolvemos datos seguros (nunca contrasena ni codigos de verificacion)
const armarUsuarioRespuesta = (u, avatarGoogle) => ({
  id: u.id,
  tipo_documento: u.tipo_documento ?? null,
  cedula: u.cedula ?? null,
  nombre: u.nombre,
  email: u.email,
  telefono: u.telefono ?? null, // ajusta el nombre si tu columna se llama distinto
  rol: u.rol,
  avatar: u.avatar || avatarGoogle || null
});

export const autenticarConGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        error: 'El idToken de Google es requerido'
      });
    }

    // 1. Validar el token con Google
    let payload;
    try {
      const ticket = await client.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID
      });
      payload = ticket.getPayload();
    } catch (e) {
      console.error('Token de Google inválido:', e.message);
      return res.status(401).json({
        error: 'Token de Google inválido o expirado'
      });
    }

    if (!payload.email_verified) {
      return res.status(401).json({
        error: 'El correo de Google no está verificado'
      });
    }

    const { sub: googleId, email, name: nombre, picture: avatar } = payload;

    // 2. Comprobar si ya existe en Supabase
    const { data: usuarioExistente } = await obtenerPorEmail(email);

    let usuarioFinal = null;

    if (usuarioExistente) {
      // LOGIN: la cuenta ya existe, usamos sus datos reales de la base de datos
      const camposActualizar = {};
      if (!usuarioExistente.googleId) camposActualizar.googleId = googleId;
      if (!usuarioExistente.avatar && avatar) camposActualizar.avatar = avatar;
      if (!usuarioExistente.isVerified) camposActualizar.isVerified = true;

      if (Object.keys(camposActualizar).length > 0) {
        await actualizarUsuario(usuarioExistente.id, camposActualizar);
      }

      usuarioFinal = { ...usuarioExistente, ...camposActualizar };
    } else {
      // REGISTRO: usuario nuevo (sin documento todavía)
      const { data: nuevoUsuario, error: errorCrear } = await crearUsuarioGoogle({
        nombre,
        email,
        googleId,
        avatar,
        rol: 'usuario'
      });

      if (errorCrear) {
        return res.status(500).json({
          error: 'Error al registrar el usuario en Supabase',
          detalle: errorCrear.message
        });
      }

      usuarioFinal = Array.isArray(nuevoUsuario) ? nuevoUsuario[0] : nuevoUsuario;
    }

    // 3. Generar token de sesión JWT (misma estructura que el login normal)
    const token = jwt.sign(
      { id: usuarioFinal.id, rol: usuarioFinal.rol, cedula: usuarioFinal.cedula },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    return res.status(200).json({
      message: usuarioExistente
        ? 'Inicio de sesión exitoso con Google'
        : 'Registro exitoso con Google',
      nuevo: !usuarioExistente,
      token,
      usuario: armarUsuarioRespuesta(usuarioFinal, avatar)
    });

  } catch (error) {
    console.error('Error en autenticarConGoogle:', error);
    return res.status(500).json({
      error: 'Error interno al autenticar con Google'
    });
  }
};