import 'dart:convert';

import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerfilUsuario {
  final String nombre;
  final String cedula;
  final String telefono;
  final String email;

  const PerfilUsuario({
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.email,
  });
}

class PerfilService {
  /// Texto limpio: la cédula (numeric) puede llegar como 1077845303 o "1077845303.0"
  static String _texto(dynamic valor) {
    if (valor == null) return '';
    if (valor is num) return valor.toInt().toString();
    final texto = valor.toString().trim();
    final decimal = RegExp(r'^(\d+)\.0+$').firstMatch(texto);
    return decimal != null ? decimal.group(1)! : texto;
  }

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión para continuar.');
    }
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  static PerfilUsuario _leerRespuesta(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor no respondió con JSON válido.');
    }

    if (response.statusCode != 200) {
      if (body is Map) {
        final mensaje =
            (body['error'] ?? body['message'] ?? 'Error del servidor').toString();
        final detalle = (body['detalle'] ?? '').toString();
        throw Exception(detalle.isNotEmpty ? '$mensaje: $detalle' : mensaje);
      }
      throw Exception('Error del servidor (código ${response.statusCode})');
    }
    if (body is! Map || body['usuario'] is! Map) {
      throw Exception('El servidor devolvió un perfil inválido.');
    }

    final u = Map<String, dynamic>.from(body['usuario'] as Map);
    return PerfilUsuario(
      nombre: _texto(u['nombre']),
      cedula: _texto(u['cedula']),
      telefono: _texto(u['telefono']),
      email: _texto(u['email']),
    );
  }

  /// Datos del usuario con sesión iniciada (tabla usuarios).
  static Future<PerfilUsuario> obtener() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/perfil'), headers: await _headers())
        .timeout(const Duration(seconds: 60));
    return _leerRespuesta(response);
  }

  /// Guarda nombre y teléfono. La cédula solo se envía si el usuario aún no tiene una.
  static Future<PerfilUsuario> actualizar({
    required String nombre,
    required String telefono,
    String? cedula,
  }) async {
    final response = await http
        .put(
          Uri.parse('${ApiConfig.baseUrl}/perfil'),
          headers: await _headers(),
          body: jsonEncode({
            'nombre': nombre,
            'telefono': telefono,
            if (cedula != null && cedula.trim().isNotEmpty)
              'cedula': cedula.trim(),
          }),
        )
        .timeout(const Duration(seconds: 60));
    return _leerRespuesta(response);
  }
}