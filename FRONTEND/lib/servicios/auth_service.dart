import 'dart:convert';
import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Cambia esta URL por la IP de tu servidor backend o dominio en producción
  final String baseUrl = ApiConfig.baseUrl;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  serverClientId: '742610687711-r2e85bn7109d54s1c54vsa28ltbdifd3.apps.googleusercontent.com',
);
  // Iniciar sesión con Correo y Contraseña
  Future<Map<String, dynamic>> loginWithEmail(String email, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'contrasena': contrasena}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Credenciales incorrectas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor: $e'};
    }
  }
  //Registrarse con Correo, Contraseña, Cédula y Nombre
  Future<Map<String, dynamic>> registerWithEmail({
  required String tipoDocumento,
  required String cedula,
  required String nombre,
  required String email,
  required String contrasena,
}) async {
  try {
final url = Uri.parse('$baseUrl/auth/register');print('POST a: $url');

final response = await http.post(
  url,
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'tipo_documento': tipoDocumento,
    'cedula': cedula,
    'nombre': nombre,
    'email': email,
    'contrasena': contrasena,
  }),
);

print('STATUS: ${response.statusCode}');
print('BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'data': data};
    }
    return {
      'success': false,
      'message': data['error'] ?? data['message'] ?? 'Error al registrar el usuario',
    };
  } catch (e) {
  print('ERROR registerWithEmail: $e');
  return {'success': false, 'message': 'No se pudo conectar con el servidor'};
}
}
  // Verificar el código de 6 dígitos con el backend
  Future<Map<String, dynamic>> verificarCodigo(String email, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-account'), // Asegúrate de que esta ruta coincida con tu Express
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'codigo': codigo, // O 'code', según lo maneje tu backend
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Código incorrecto o expirado'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Reenviar el código de verificación
  Future<Map<String, dynamic>> reenviarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reenviar'), // Asegúrate de que esta ruta coincida con tu Express
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'No se pudo reenviar el código'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Guarda la sesión igual que el login normal (sirve para Google y correo)
Future<void> guardarSesion(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  final usuario = data['usuario'] is Map
      ? Map<String, dynamic>.from(data['usuario'])
      : <String, dynamic>{};

  final token = data['token'];
  if (token is String) await prefs.setString('token', token);

  final email = (usuario['email'] ?? '').toString().trim();
  final nombre = (usuario['nombre'] ??
          (email.isNotEmpty ? email.split('@').first : 'Usuario'))
      .toString();
  final rol = (usuario['rol'] ?? '').toString().trim();

  await prefs.setString('email', email);
  await prefs.setString('nombre', nombre);
  await prefs.setString('user_email', email);
  await prefs.setString('user_name', nombre);
  await prefs.setString('user_role', rol);

  // Datos opcionales: si no vienen, se borran los de una sesión anterior
  Future<void> opcional(String clave, dynamic valor) async {
    if (valor != null && valor.toString().isNotEmpty) {
      await prefs.setString(clave, valor.toString());
    } else {
      await prefs.remove(clave);
    }
  }

  await opcional('cedula', usuario['cedula']);
  await opcional('tipo_documento', usuario['tipo_documento']);
  await opcional('telefono', usuario['telefono']);
  await opcional('avatar', usuario['avatar']);
}

  // Iniciar sesión / Registro con Google (Guarda automáticamente en la BD del Backend/Supabase)
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // 1. Forzar el cierre de sesión previo para limpiar la caché y mostrar el selector de cuentas
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Inicio de sesión cancelado'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'No se pudo obtener el token de Google'};
      }

      // Enviar el token de Google al backend para verificar, registrar en Supabase y autenticar
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
          'tipoDocumento': 'CC',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error en el servidor al autenticar con Google'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Excepción en Google Sign-In: $e'};
    }
  }
}