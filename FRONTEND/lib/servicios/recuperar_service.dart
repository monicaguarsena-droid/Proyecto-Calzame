import 'dart:convert';

import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;

/// Llama al backend para recuperar la contraseña con un código por correo.
class RecuperacionService {
  /// Envía un código de 6 dígitos al correo.
  static Future<void> solicitarCodigo(String email) async {
    await _post('/auth/forgot-password', {'email': email});
  }

  /// Cambia la contraseña si el código es correcto y no ha vencido.
  static Future<void> restablecer({
    required String email,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    await _post('/auth/verify-code', {
      'email': email,
      'codigo': codigo,
      'newPassword': nuevaContrasena,
    });
  }

  static Future<void> _post(String ruta, Map<String, dynamic> datos) async {
    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$ruta'),
            headers: ApiConfig.headers,
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      throw Exception('No se pudo conectar con el servidor');
    }

    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final mensaje = body is Map
          ? (body['message'] ?? body['error'])
          : null;
      throw Exception(
        (mensaje ?? 'Error del servidor (código ${response.statusCode})')
            .toString(),
      );
    }
  }
}