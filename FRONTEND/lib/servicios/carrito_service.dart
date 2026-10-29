import 'dart:convert';

import 'package:frontend/api_config.dart';
import 'package:frontend/servicios/producto_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ItemCarrito {
  final String id;
  final String productoId;
  final String imagen;
  final String titulo;
  final String subtitulo;
  final double precio;
  final String talla;
  final String color;
  int cantidad;

  ItemCarrito({
    required this.id,
    required this.productoId,
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
    required this.talla,
    required this.color,
    required this.cantidad,
  });
}

class CarritoService {
  static final List<ItemCarrito> itemsCarrito = [];

  static Future<List<ItemCarrito>> cargarCarrito() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/carrito'),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! Map<String, dynamic> || body['carrito'] is! List) {
      throw Exception('El servidor devolvió un carrito inválido.');
    }

    final productos = await ProductoService().obtenerProductos();
    final productosPorId = {
      for (final producto in productos) producto.id: producto,
    };
    final items = (body['carrito'] as List).map((registro) {
      if (registro is! Map<String, dynamic>) {
        throw Exception(
          'El servidor devolvió un producto inválido en el carrito.',
        );
      }
      final productoId = registro['producto_id']?.toString() ?? '';
      final producto = productosPorId[productoId];
      final precio = registro['precio'] ?? producto?.precio ?? 0;
      return ItemCarrito(
        id: registro['id']?.toString() ?? '',
        productoId: productoId,
        imagen: producto?.imagenUrl ?? '',
        titulo: producto?.nombre ?? 'Producto',
        subtitulo: producto?.descripcion ?? '',
        precio: precio is num
            ? precio.toDouble()
            : double.tryParse(precio.toString()) ?? 0,
        talla: registro['talla']?.toString() ?? 'Única',
        color: registro['color']?.toString() ?? 'Único',
        cantidad: int.tryParse(registro['cantidad']?.toString() ?? '') ?? 1,
      );
    }).toList();

    itemsCarrito
      ..clear()
      ..addAll(items);
    return items;
  }

  static Future<void> agregarProducto({
    required String productoId,
    required String imagen,
    required String titulo,
    required String subtitulo,
    required String precioStr,
    String talla = 'Única',
    String color = 'Único',
  }) async {
    final precio = double.tryParse(
      precioStr.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (productoId.isEmpty || precio == null) {
      throw Exception('No se pudo identificar el producto o su precio.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/carrito/agregar'),
      headers: await _headers(),
      body: jsonEncode({
        'producto_id': productoId,
        'cantidad': 1,
        'talla': talla,
        'color': color,
      }),
    );
    final body = _decode(response);
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! Map<String, dynamic> ||
        body['item'] is! Map<String, dynamic>) {
      throw Exception('El servidor no confirmó el producto agregado.');
    }

    final registro = body['item'] as Map<String, dynamic>;
    itemsCarrito.add(
      ItemCarrito(
        id: registro['id']?.toString() ?? '',
        productoId: productoId,
        imagen: imagen,
        titulo: titulo,
        subtitulo: subtitulo,
        precio: (registro['precio'] as num?)?.toDouble() ?? precio,
        talla: talla,
        color: color,
        cantidad: 1,
      ),
    );
  }

  static Future<void> actualizarCantidad(ItemCarrito item, int cantidad) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/carrito/${item.id}'),
      headers: await _headers(),
      body: jsonEncode({'cantidad': cantidad}),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    item.cantidad = cantidad;
  }

  static Future<void> eliminar(ItemCarrito item) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/carrito/${item.id}'),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    itemsCarrito.removeWhere((registro) => registro.id == item.id);
  }

  static Future<void> vaciar() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/carrito/vaciar'),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    itemsCarrito.clear();
  }

  static Future<Map<String, String>> _headers() async {
    final preferences = await SharedPreferences.getInstance();
    final token =
        preferences.getString('token') ?? preferences.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión para consultar y guardar tu carrito.');
    }
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  static dynamic _decode(http.Response response) {
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
      return (body['error'] ?? body['message'] ?? 'Error del servidor')
          .toString();
    }
    return 'Error del servidor (código $statusCode).';
  }
}
