import 'dart:convert';
import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

double _aDouble(dynamic v) => v is num ? v.toDouble() : (double.tryParse('$v') ?? 0);
int _aInt(dynamic v) => v is num ? v.toInt() : (int.tryParse('$v') ?? 0);

/// Una barra del reporte (una hora, un día o un mes según el periodo).
class CubetaReporte {
  final String periodo;
  final String etiqueta;
  final double ventas;
  final int pedidos;

  const CubetaReporte({
    required this.periodo,
    required this.etiqueta,
    required this.ventas,
    required this.pedidos,
  });

  factory CubetaReporte.fromJson(Map<String, dynamic> json) {
    return CubetaReporte(
      periodo: json['periodo']?.toString() ?? '',
      etiqueta: json['etiqueta']?.toString() ?? '',
      ventas: _aDouble(json['ventas']),
      pedidos: _aInt(json['pedidos']),
    );
  }
}

class ReporteVentasData {
  final String periodo;
  final double totalVentas;
  final int cantidadPedidos;
  final double promedioPorPedido;
  final List<CubetaReporte> desglose;

  const ReporteVentasData({
    required this.periodo,
    required this.totalVentas,
    required this.cantidadPedidos,
    required this.promedioPorPedido,
    required this.desglose,
  });

  factory ReporteVentasData.fromJson(Map<String, dynamic> json) {
    final lista = (json['desglose'] as List? ?? [])
        .map((e) => CubetaReporte.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ReporteVentasData(
      periodo: json['periodo']?.toString() ?? '',
      totalVentas: _aDouble(json['totalVentas']),
      cantidadPedidos: _aInt(json['cantidadPedidos']),
      promedioPorPedido: _aDouble(json['promedioPorPedido']),
      desglose: lista,
    );
  }
}

class ReporteService {
  final String baseUrl = ApiConfig.baseUrl;

  /// periodo: 'diario' | 'mensual' | 'trimestral' | 'anual'
  Future<Map<String, dynamic>> obtenerVentas({
    required String periodo,
    required DateTime fecha,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Inicia sesión para continuar'};
      }

      final fechaStr =
          '${fecha.year.toString().padLeft(4, '0')}-'
          '${fecha.month.toString().padLeft(2, '0')}-'
          '${fecha.day.toString().padLeft(2, '0')}';

      final response = await http
          .get(
            Uri.parse('$baseUrl/reportes/ventas/$periodo?fecha=$fechaStr'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 45));

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        return {
          'success': false,
          'message': 'Respuesta inesperada del servidor (${response.statusCode})',
        };
      }

      if (decoded is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Respuesta inesperada del servidor'};
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': ReporteVentasData.fromJson(decoded)};
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'message': decoded['error']?.toString() ??
              'No tienes permisos para ver este reporte',
        };
      }

      return {
        'success': false,
        'message': decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            'No se pudo cargar el reporte',
      };
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor'};
    }
  }
}