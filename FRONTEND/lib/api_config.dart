import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  
  static const bool useRemote = false;

  static const String _remoteUrl = 'https://calzado-marandpaz.onrender.com/api';
  static const int _port = 3000; // Puerto de tu servidor local
 
  static const String? _lanIp = null;

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    // Detecta primero si estás en el emulador de Android y usa la IP loopback
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port/api';
    }
    if (_lanIp != null) {
      return 'http://$_lanIp:$_port/api';
    }
    return 'http://localhost:$_port/api';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };
}

String get apiUrl => ApiConfig.baseUrl;