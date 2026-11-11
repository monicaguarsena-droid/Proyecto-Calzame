import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api_config.dart';

// Operaciones del panel administrativo sobre el calzado (requieren token de admin)
class AdminProductService {
  static Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception(
        'Inicia sesión como administrador para guardar productos.',
      );
    }
    return token;
  }

  static String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return (data['message'] ??
              data['error'] ??
              'Error del servidor (código ${response.statusCode})')
          .toString();
    } catch (_) {
      return 'El servidor no respondió con JSON válido (código ${response.statusCode}). '
          'Verifica que el backend esté corriendo y que la URL en api_config.dart sea correcta.';
    }
  }

  static Future<http.MultipartFile> _archivoImagen(File imagen) async {
    final bytes = await imagen.readAsBytes();
    final ext = imagen.path.split('.').last.toLowerCase();
    final subtipo = switch (ext) {
      'png' => 'png',
      'webp' => 'webp',
      'avif' => 'avif',
      _ => 'jpeg',
    };
    return http.MultipartFile.fromBytes(
      'Imagen',
      bytes,
      contentType: MediaType('image', subtipo),
      filename:
          'producto_${DateTime.now().millisecondsSinceEpoch}.${subtipo == 'jpeg' ? 'jpg' : subtipo}',
    );
  }

  static Future<void> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required File imagen,
  }) async {
    final token = await _obtenerToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/productos/crear'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Nombre'] = nombre;
    request.fields['Descripcion'] = descripcion;
    request.fields['Precio'] = precio.toString();
    request.files.add(await _archivoImagen(imagen));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
  }

  static Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    File? imagen,
  }) async {
    final token = await _obtenerToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/productos/actualizar/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    if (imagen != null) {
      request.files.add(await _archivoImagen(imagen));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  static Future<void> eliminarProducto(String id) async {
    final token = await _obtenerToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/productos/eliminar/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
}
