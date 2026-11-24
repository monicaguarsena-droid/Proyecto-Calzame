import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/servicios/configuracion_tienda_service.dart';
// Asegúrate de importar tu archivo de configuración donde tengas tu baseUrl (ej: localhost o Render)
import '../api_config.dart'; 

class ChatCalzameService {
  // Mantenemos una variable estática opcional para conservar la sesión activa en memoria durante el uso
  static String? _sesionIdActual;

  static Future<String> enviarMensaje(String mensaje) async {
    try {
      final tienda = await ConfiguracionTiendaService.cargar();
      final url = Uri.parse('${ApiConfig.baseUrl}/chat'); // Endpoint en tu backend Node.js
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mensaje': mensaje,
          'sesionId': _sesionIdActual, // Si es nulo, el backend generará uno nuevo
          'usuarioId': null,           // Opcional: pásalo si manejas ID de usuario autenticado
          'ubicacionTienda': tienda.direccion,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Guardamos el sesionId que retorna el backend para mantener la continuidad
        if (data['sesionId'] != null) {
          _sesionIdActual = data['sesionId'];
        }

        return data['respuesta'] ?? '¡Hola! Bienvenido a Calzado Mar&Paz.';
      } else {
        return 'Lo siento, ocurrió un error al procesar tu consulta en el servidor.';
      }
    } catch (e) {
      return 'Error de conexión con el servidor de CalzaMe. Verifica tu red.';
    }
  }
}