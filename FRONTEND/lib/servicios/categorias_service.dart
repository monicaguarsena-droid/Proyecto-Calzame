import 'dart:convert';
import 'dart:io';

import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoriaService {

  static Future<List> listar() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categorias'),
      headers: ApiConfig.headers,
    );
    final body = _decodeResponse(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! List) {
      throw Exception('El servidor no devolvió una lista de categorías');
    }
    return body.map((item) {
      if (item is! Map<String, dynamic>) {
        throw Exception('El servidor devolvió un registro inválido en categorías');
      }
      return item;
    }).toList();
  }

  static Future<void> guardar({
    required Map<String, dynamic> campos, 
    required File? imagen,
    String? id,
  }) async {
    final token = await _token();
    final ruta = '${ApiConfig.baseUrl}/categorias${id == null ? '' : '/$id'}';
    
    print('🌐 URL DE PETICIÓN: $ruta');

    final request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(ruta),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    
    campos.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

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
    required String id,
  }) async {
    final token = await _token();
    final urlEliminar = '${ApiConfig.baseUrl}/categorias/$id';
    
    print('🗑️ URL ELIMINAR: $urlEliminar');

    final response = await http.delete(
      Uri.parse(urlEliminar),
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