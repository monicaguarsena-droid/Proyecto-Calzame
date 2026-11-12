import { Router } from 'express';
import messaging from '../config/firebase.js';

const router = Router();

router.post('/enviar', async (req, res) => {
  const { userFcmToken, titulo, cuerpo, rutaDestino } = req.body;

  if (!userFcmToken) {
    return res.status(400).json({ success: false, error: 'Falta el token FCM del usuario' });
  }

  const message = {
    notification: {
      title: titulo || '¡Nueva notificación!',
      body: cuerpo || 'Tienes un mensaje nuevo en CalzaMe.'
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      route: rutaDestino || '/home'
    },
    token: userFcmToken
  };

  try {
    const response = await messaging.send(message);
    console.log('Notificación enviada correctamente:', response);
    res.status(200).json({ success: true, messageId: response });
  } catch (error) {
    console.error('Error al enviar la notificación:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;