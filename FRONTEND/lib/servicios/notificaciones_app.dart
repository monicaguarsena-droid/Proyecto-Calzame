import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionesApp {
  static final FlutterLocalNotificationsPlugin _locales =
      FlutterLocalNotificationsPlugin();
  static StreamSubscription<RemoteMessage>? _suscripcion;
  static Future<void>? _inicializacion;

  static Future<void> inicializar() =>
      _inicializacion ??= kIsWeb ? Future<void>.value() : _configurarNotificaciones();

  static Future<void> _configurarNotificaciones() async {
    const canal = AndroidNotificationChannel(
      'calzame_notifications',
      'Notificaciones',
      description: 'Notificaciones de pedidos de Calzado Mar&Paz',
      importance: Importance.high,
    );

    await _locales.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _locales
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);

    _suscripcion ??= FirebaseMessaging.onMessage.listen(_mostrar);
  }

  static Future<void> _mostrar(RemoteMessage mensaje) async {
    final notificacion = mensaje.notification;
    if (notificacion == null) return;

    await _locales.show(
      mensaje.hashCode,
      notificacion.title,
      notificacion.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'calzame_notifications',
          'Notificaciones',
          channelDescription: 'Notificaciones de pedidos de Calzado Mar&Paz',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
