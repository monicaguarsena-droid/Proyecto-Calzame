import 'dart:convert';
import 'package:frontend/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

double _numero(dynamic valor) => double.tryParse(valor?.toString() ?? '') ?? 0;

class PedidoDetalleAdmin {
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String talla;
  final String color;
  final String producto;
  final String imagen;

  const PedidoDetalleAdmin({
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.talla,
    required this.color,
    required this.producto,
    required this.imagen,
  });

  factory PedidoDetalleAdmin.fromJson(Map<String, dynamic> json) {
    final producto = json['producto'] is Map
        ? Map<String, dynamic>.from(json['producto'] as Map)
        : <String, dynamic>{};
    return PedidoDetalleAdmin(
      cantidad: _numero(json['cantidad']).toInt(),
      precioUnitario: _numero(json['precioUnitario']),
      subtotal: _numero(json['subtotal']),
      talla: (json['talla'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      producto: (producto['nombre'] ?? 'Producto').toString(),
      imagen: (producto['imagen'] ?? '').toString(),
    );
  }
}

class PedidoAdminModel {
  final int id;
  final String estado;
  final double total;
  final DateTime? fecha;
  final String celular;
  final String metodoPago;
  final String nombreContacto;
  final String cedula;
  final String clienteNombre;
  final String clienteEmail;
  final List<PedidoDetalleAdmin> detalles;

  const PedidoAdminModel({
    required this.id,
    required this.estado,
    required this.total,
    required this.fecha,
    required this.celular,
    required this.metodoPago,
    required this.nombreContacto,
    required this.cedula,
    required this.clienteNombre,
    required this.clienteEmail,
    required this.detalles,
  });

  /// Nombre de quien recoge el pedido (o el del usuario si no hay contacto).
  String get cliente {
    if (nombreContacto.trim().isNotEmpty) return nombreContacto.trim();
    if (clienteNombre.trim().isNotEmpty) return clienteNombre.trim();
    return 'Cliente desconocido';
  }

  int get articulos => detalles.fold(0, (suma, d) => suma + d.cantidad);

  factory PedidoAdminModel.fromJson(Map<String, dynamic> json) {
    final cliente = json['cliente'] is Map
        ? Map<String, dynamic>.from(json['cliente'] as Map)
        : <String, dynamic>{};
    final detalles = json['detalles'] is List ? json['detalles'] as List : [];

    return PedidoAdminModel(
      id: _numero(json['id']).toInt(),
      estado: (json['estado'] ?? 'Pendiente').toString(),
      total: _numero(json['total']),
      fecha: DateTime.tryParse((json['fecha'] ?? '').toString())?.toLocal(),
      celular: (json['celular'] ?? '').toString(),
      metodoPago: (json['metodoPago'] ?? '').toString(),
      nombreContacto: (json['nombreContacto'] ?? '').toString(),
      cedula: (json['cedula'] ?? '').toString(),
      clienteNombre: (cliente['nombre'] ?? '').toString(),
      clienteEmail: (cliente['email'] ?? '').toString(),
      detalles: detalles
          .whereType<Map>()
          .map((d) => PedidoDetalleAdmin.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }
}

class PedidosService {
  /// Estados que el administrador puede asignar (la tienda solo entrega en el local).
  static const List<String> estados = [
    'Pendiente',
    'Listo para recoger',
    'Entregado',
    'Cancelado',
  ];

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión para continuar.');
    }
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  static Future<dynamic> _enviar(
    String metodo,
    String ruta, {
    Map<String, dynamic>? cuerpo,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/pedidos$ruta');
    final headers = await _headers();

    late http.Response response;
    try {
      // 60 s: en Render gratis el servidor puede tardar en despertar
      switch (metodo) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(cuerpo))
              .timeout(const Duration(seconds: 60));
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(cuerpo))
              .timeout(const Duration(seconds: 60));
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 60));
        default:
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 60));
      }
    } catch (_) {
      throw Exception(
        'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.',
      );
    }

    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (body is Map) {
        final mensaje = (body['error'] ?? body['message'] ?? 'Error del servidor')
            .toString();
        final detalle = (body['detalle'] ?? '').toString();
        throw Exception(detalle.isNotEmpty ? '$mensaje: $detalle' : mensaje);
      }
      throw Exception('Error del servidor (código ${response.statusCode}).');
    }
    return body;
  }

  /// Crea el pedido con el carrito guardado en el servidor. Devuelve el id del pedido.
  static Future<int> crearPedido({
    required String nombre,
    required String cedula,
    required String telefono,
    required String metodoPago,
  }) async {
    final body = await _enviar(
      'POST',
      '/crear',
      cuerpo: {
        'nombre': nombre,
        'cedula': cedula,
        'telefono': telefono,
        'metodo_pago': metodoPago,
      },
    );
    final pedido = body is Map ? body['pedido'] : null;
    final id = pedido is Map ? int.tryParse(pedido['id'].toString()) : null;
    if (id == null) {
      throw Exception('El servidor no confirmó el pedido.');
    }
    return id;
  }

  /// Todos los pedidos (solo administrador).
  static Future<List<PedidoAdminModel>> listarAdmin() async {
    final body = await _enviar('GET', '/admin');
    final lista = body is Map && body['pedidos'] is List
        ? body['pedidos'] as List
        : <dynamic>[];
    return lista
        .whereType<Map>()
        .map((p) => PedidoAdminModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }

  /// Pedidos del usuario con sesión iniciada (los que no ha quitado de su historial).
  static Future<List<PedidoAdminModel>> listarMios() async {
    final body = await _enviar('GET', '/mis-pedidos');
    final lista = body is Map && body['pedidos'] is List
        ? body['pedidos'] as List
        : <dynamic>[];
    return lista
        .whereType<Map>()
        .map((p) => PedidoAdminModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
  }

  /// Quita un pedido del historial del cliente (la tienda conserva el registro).
  static Future<void> ocultar(int id) async {
    await _enviar('PUT', '/$id/ocultar', cuerpo: {});
  }

  static Future<void> actualizarEstado(int id, String estado) async {
    await _enviar('PUT', '/$id/estado', cuerpo: {'estado': estado});
  }

  static Future<void> eliminar(int id) async {
    await _enviar('DELETE', '/$id');
  }
}