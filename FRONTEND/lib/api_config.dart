import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const bool useRemote =
      true; // Cambia a false para usar el servidor local

  static const String _remoteUrl = 'https://proyecto-mar-y-paz.onrender.com';
  static const int _port = 3000; // Puerto del servidor local
  static const String? _lanIp = null;
  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    if (_lanIp != null) {
      return 'http://$_lanIp:$_port/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port/api';
    }
    return 'http://localhost:$_port/api';
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
}

String get apiUrl => ApiConfig.baseUrl;
