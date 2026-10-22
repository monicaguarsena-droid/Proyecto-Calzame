import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Cambia esta URL por la IP de tu servidor backend o dominio en producción
  final String baseUrl = 'http://10.0.2.2:3000/api'; 

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
    required String cedula,
    required String nombre,
    required String email,
    required String contrasena,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'), // Asegúrate de que esta ruta coincida con la de tu Node.js/Express
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cedula': cedula,
          'nombre': nombre,
          'email': email,
          'contrasena': contrasena,
        }),
      );

      final data = jsonDecode(response.body);

      // Aceptamos 200 o 201 como respuestas exitosas de creación
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Error al registrar el usuario'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor: $e'};
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

  // Iniciar sesión / Registro con Google (Guarda automáticamente en la BD del Backend/Supabase)
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