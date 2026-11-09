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

  /// Datos del usuario con sesión iniciada (tabla usuarios).
  static Future<PerfilUsuario> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión para continuar.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/perfil'),
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
    );

    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor no respondió con JSON válido.');
    }

    if (response.statusCode != 200) {
      final mensaje = body is Map<String, dynamic>
          ? (body['error'] ?? body['message'] ?? 'Error del servidor')
          : 'Error del servidor (código ${response.statusCode})';
      throw Exception(mensaje.toString());
    }
    if (body is! Map<String, dynamic> || body['usuario'] is! Map) {
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
}