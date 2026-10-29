import 'dart:convert';
import 'dart:io';

import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CatalogoVisualService {
  static String _ruta(String recurso) =>
      recurso == 'ofertas' ? 'ofertas' : 'catalogo/$recurso';

  static Future<List<Map<String, dynamic>>> listar(String recurso) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/${_ruta(recurso)}'),
      headers: ApiConfig.headers,
    );
    final body = _decodeResponse(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! List) {
      throw Exception('El servidor no devolvió una lista de $recurso');
    }
    return body.map((item) {
      if (item is! Map<String, dynamic>) {
        throw Exception(
          'El servidor devolvió un registro inválido en $recurso',
        );
      }
      return item;
    }).toList();
  }

  static Future<void> guardar({
    required String recurso,
    required Map<String, String> campos,
    required File? imagen,
    String? id,
  }) async {
    final token = await _token();
    final ruta =
        '${ApiConfig.baseUrl}/${_ruta(recurso)}${id == null ? '' : '/$id'}';
    final request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(ruta),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(campos);
    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );
    }

    final response = await http.Response.fromStream(await request.send());
    final body = _decodeResponse(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
  }

  static Future<void> eliminar({
    required String recurso,
    required String id,
  }) async {
    final token = await _token();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/${_ruta(recurso)}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = _decodeResponse(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
  }

  static Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión como administrador para continuar.');
    }
    return token;
  }

  static dynamic _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'El servidor no respondió con JSON válido (código ${response.statusCode}).',
      );
    }
  }

  static String _mensajeError(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      return (body['message'] ?? body['error'] ?? 'Error del servidor')
          .toString();
    }
    return 'Error del servidor (código $statusCode).';
  }
}
