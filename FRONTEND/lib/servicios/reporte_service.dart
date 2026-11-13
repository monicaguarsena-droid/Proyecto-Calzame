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

class ProductoReporteData {
  final String nombre;
  final int cantidadVendida;
  final double ventas;
  final int pedidos;

  const ProductoReporteData({
    required this.nombre,
    required this.cantidadVendida,
    required this.ventas,
    required this.pedidos,
  });

  factory ProductoReporteData.fromJson(Map<String, dynamic> json) {
    return ProductoReporteData(
      nombre: json['nombre']?.toString() ?? 'Producto',
      cantidadVendida: _aInt(json['cantidadVendida']),
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
  final List<ProductoReporteData> productos;

  const ReporteVentasData({
    required this.periodo,
    required this.totalVentas,
    required this.cantidadPedidos,
    required this.promedioPorPedido,
    required this.desglose,
    required this.productos,
  });

  factory ReporteVentasData.fromJson(Map<String, dynamic> json) {
    final lista = (json['desglose'] as List? ?? [])
        .map((e) => CubetaReporte.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final productos = (json['productos'] as List? ?? [])
        .map(
          (e) =>
              ProductoReporteData.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return ReporteVentasData(
      periodo: json['periodo']?.toString() ?? '',
      totalVentas: _aDouble(json['totalVentas']),
      cantidadPedidos: _aInt(json['cantidadPedidos']),
      promedioPorPedido: _aDouble(json['promedioPorPedido']),
      desglose: lista,
      productos: productos,
    );
  }
}

class ResumenAdminData {
  final double ventasMesActual;
  final double ventasMesAnterior;
  final double? variacionPorcentual;
  final int pedidosPendientes;
  final int productosActivos;
  final List<CubetaReporte> ventasPorDia;

  const ResumenAdminData({
    required this.ventasMesActual,
    required this.ventasMesAnterior,
    required this.variacionPorcentual,
    required this.pedidosPendientes,
    required this.productosActivos,
    required this.ventasPorDia,
  });

  factory ResumenAdminData.fromJson(Map<String, dynamic> json) {
    final ventasPorDia = (json['ventasPorDia'] as List? ?? [])
        .map((e) => CubetaReporte.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final variacion = json['variacionPorcentual'];

    return ResumenAdminData(
      ventasMesActual: _aDouble(json['ventasMesActual']),
      ventasMesAnterior: _aDouble(json['ventasMesAnterior']),
      variacionPorcentual: variacion is num ? variacion.toDouble() : null,
      pedidosPendientes: _aInt(json['pedidosPendientes']),
      productosActivos: _aInt(json['productosActivos']),
      ventasPorDia: ventasPorDia,
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
      final token = prefs.getString('token') ?? prefs.getString('jwt_token');

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

  Future<ResumenAdminData> obtenerResumen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión como administrador para continuar.');
    }

    final response = await http
        .get(
          Uri.parse('$baseUrl/reportes/resumen'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 45));

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Respuesta inesperada del servidor (${response.statusCode}).',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Respuesta inesperada del servidor.');
    }
    if (response.statusCode != 200) {
      throw Exception(
        decoded['error']?.toString() ?? 'No se pudo cargar el resumen.',
      );
    }

    return ResumenAdminData.fromJson(decoded);
  }
}
