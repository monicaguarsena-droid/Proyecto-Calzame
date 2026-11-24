import 'dart:async';
import 'dart:convert';

import 'package:frontend/api_config.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/ofertas_service.dart';
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
  final double precioOriginal;
  final int descuentoPorcentaje;

  /// Producto completo (si se pudo encontrar) para abrir su detalle real.
  final ProductoModel? producto;

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
    this.producto,
    double? precioOriginal,
    this.descuentoPorcentaje = 0,
  }) : precioOriginal = precioOriginal ?? precio;
}

class _ItemInvitadoSincronizado {
  final String id;
  final int cantidadBase;

  const _ItemInvitadoSincronizado({
    required this.id,
    required this.cantidadBase,
  });
}

class CarritoService {
  static final List<ItemCarrito> itemsCarrito = [];
  static int get cantidadTotal =>
      itemsCarrito.fold(0, (total, item) => total + item.cantidad);
  static bool _carritoInvitado = false;
  static int _siguienteIdInvitado = 0;
  static final Map<String, _ItemInvitadoSincronizado>
      _itemsInvitadosSincronizados = {};

  static void _iniciarCarritoInvitado() {
    if (_carritoInvitado) return;
    itemsCarrito.clear();
    _itemsInvitadosSincronizados.clear();
    _carritoInvitado = true;
  }

  static bool _mismaVariante(ItemCarrito a, ItemCarrito b) =>
      a.productoId == b.productoId && a.talla == b.talla && a.color == b.color;

  /// Foto del color que el cliente eligió; si no existe, la principal.
  static String _imagenParaColor(ProductoModel? producto, String color) {
    if (producto == null) return '';
    final buscado = color.trim().toLowerCase();
    for (final c in producto.colores) {
      if (c.color.trim().toLowerCase() == buscado && c.imagenUrl.isNotEmpty) {
        return c.imagenUrl;
      }
    }
    return producto.imagenPrincipal;
  }

  /// "Dama · Sandalias" (o la descripción si no hay categoría ni tipo).
  static String _subtituloDe(ProductoModel producto) {
    final partes = [
      if (producto.categoria.trim().isNotEmpty) producto.categoria.trim(),
      if ((producto.tipoCalzado ?? '').trim().isNotEmpty)
        producto.tipoCalzado!.trim(),
    ];
    return partes.isNotEmpty ? partes.join(' · ') : producto.descripcion;
  }

  static Future<List<ItemCarrito>> cargarCarrito() async {
    final headers = await _headersSiSesion();
    if (headers == null) {
      _iniciarCarritoInvitado();
      return List.of(itemsCarrito);
    }

    if (_carritoInvitado) {
      await _sincronizarCarritoInvitado(headers);
      return List.of(itemsCarrito);
    }

    return _cargarCarritoServidor(headers);
  }

  static Future<List<ItemCarrito>> _cargarCarritoServidor(
    Map<String, String> headers,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/carrito'),
      headers: headers,
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! Map<String, dynamic> || body['carrito'] is! List) {
      throw Exception('El servidor devolvió un carrito inválido.');
    }

    final productos = await ProductoService().obtenerProductos();
    final ofertas = await OfertasService.listar();
    final productosPorId = {
      for (final producto in productos) producto.id.toString(): producto,
    };

    final items = (body['carrito'] as List).map((registro) {
      if (registro is! Map<String, dynamic>) {
        throw Exception(
          'El servidor devolvió un producto inválido en el carrito.',
        );
      }
      final productoId =
          (registro['producto_id'] ?? registro['productoId'])?.toString() ?? '';
      final producto = productosPorId[productoId];
      final color = registro['color']?.toString() ?? 'Único';
      final precioOriginal = _aDouble(producto?.precio ?? registro['precio']);
      final descuento = _descuentoActivo(productoId, ofertas);
      final precio = descuento == 0
          ? precioOriginal
          : (precioOriginal * (100 - descuento) / 100).roundToDouble();
      return ItemCarrito(
        id: registro['id']?.toString() ?? '',
        productoId: productoId,
        imagen: _imagenParaColor(producto, color),
        titulo: producto?.nombre ?? 'Producto',
        subtitulo: producto != null ? _subtituloDe(producto) : '',
        precio: precio,
        precioOriginal: precioOriginal,
        descuentoPorcentaje: descuento,
        talla: registro['talla']?.toString() ?? 'Única',
        color: color,
        cantidad: int.tryParse(registro['cantidad']?.toString() ?? '') ?? 1,
        producto: producto,
      );
    }).toList();

    itemsCarrito
      ..clear()
      ..addAll(items);
    return items;
  }

  static Future<void> _sincronizarCarritoInvitado(
    Map<String, String> headers,
  ) async {
    for (final item in List<ItemCarrito>.of(itemsCarrito)) {
      final productoId = int.tryParse(item.productoId);
      if (productoId == null) {
        throw Exception('No se pudo identificar un producto del carrito.');
      }

      final sincronizado = _itemsInvitadosSincronizados[item.id];
      if (sincronizado != null) {
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/carrito/${sincronizado.id}'),
          headers: headers,
          body: jsonEncode({
            'cantidad': sincronizado.cantidadBase + item.cantidad,
          }),
        );
        final body = _decode(response);
        if (response.statusCode != 200) {
          throw Exception(_mensajeError(body, response.statusCode));
        }
        continue;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/carrito/agregar'),
        headers: headers,
        body: jsonEncode({
          'producto_id': productoId,
          'cantidad': item.cantidad,
          'talla': item.talla,
          'color': item.color,
        }),
      );
      final body = _decode(response);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_mensajeError(body, response.statusCode));
      }
      if (body is! Map<String, dynamic> ||
          body['item'] is! Map<String, dynamic>) {
        throw Exception('El servidor no confirmó el producto sincronizado.');
      }

      final registro = body['item'] as Map<String, dynamic>;
      final id = registro['id']?.toString() ?? '';
      final cantidadServidor = int.tryParse(
        registro['cantidad']?.toString() ?? '',
      );
      if (id.isEmpty || cantidadServidor == null) {
        throw Exception('El servidor devolvió un producto inválido.');
      }
      _itemsInvitadosSincronizados[item.id] = _ItemInvitadoSincronizado(
        id: id,
        cantidadBase: cantidadServidor - item.cantidad,
      );
    }

    _carritoInvitado = false;
    _itemsInvitadosSincronizados.clear();
    await _cargarCarritoServidor(headers);
  }

  static double _aDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static int _descuentoActivo(String productoId, List ofertas) {
    var mayorDescuento = 0;
    for (final oferta in ofertas) {
      if (oferta['estado']?.toString().toLowerCase() != 'activo' ||
          oferta['producto_id']?.toString() != productoId) {
        continue;
      }

      final texto = oferta['descuento']?.toString().replaceAll('%', '').trim();
      final descuento = int.tryParse(texto ?? '');
      if (descuento != null &&
          descuento >= 1 &&
          descuento <= 100 &&
          descuento > mayorDescuento) {
        mayorDescuento = descuento;
      }
    }
    return mayorDescuento;
  }

  // 2. Agregar un producto al carrito
  static Future<void> agregarProducto({
    required String productoId,
    required String imagen,
    required String titulo,
    required String subtitulo,
    required String precioStr,
    String talla = 'Única',
    String color = 'Único',
    ProductoModel? producto,
  }) async {
    final precio = double.tryParse(
      precioStr.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (productoId.isEmpty || precio == null) {
      throw Exception('No se pudo identificar el producto o su precio.');
    }

    final int? parsedProductoId = int.tryParse(productoId);
    final sessionHeaders = await _headersSiSesion();
    if (sessionHeaders == null) {
      _iniciarCarritoInvitado();
      final existente = itemsCarrito.where(
        (item) =>
            item.productoId == productoId &&
            item.talla == talla &&
            item.color == color,
      );
      if (existente.isNotEmpty) {
        existente.first.cantidad++;
        return;
      }

      itemsCarrito.add(
        ItemCarrito(
          id: 'invitado-${_siguienteIdInvitado++}',
          productoId: productoId,
          imagen: imagen,
          titulo: titulo,
          subtitulo: producto != null ? _subtituloDe(producto) : subtitulo,
          precio: precio,
          precioOriginal: precio,
          talla: talla,
          color: color,
          cantidad: 1,
          producto: producto,
        ),
      );
      return;
    }

    if (_carritoInvitado) {
      await _sincronizarCarritoInvitado(sessionHeaders);
    }
    final headers = await _headers();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/carrito/agregar'),
      headers: headers,
      body: jsonEncode({
        'producto_id': parsedProductoId ?? productoId,
        'cantidad': 1,
        'talla': talla,
        'color': color,
      }),
    );

    final body = _decode(response);
    // 201 = creado; 200 = el backend sumó la cantidad a un registro existente
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    if (body is! Map<String, dynamic> ||
        body['item'] is! Map<String, dynamic>) {
      throw Exception('El servidor no confirmó el producto agregado.');
    }

    final registro = body['item'] as Map<String, dynamic>;
    final idRegistro = registro['id']?.toString() ?? '';
    final cantidadServidor = int.tryParse(
      registro['cantidad']?.toString() ?? '',
    );

    // Si el backend sumó a un registro que ya teníamos, actualizamos la cantidad
    final indice = idRegistro.isEmpty
        ? -1
        : itemsCarrito.indexWhere((item) => item.id == idRegistro);
    if (indice >= 0) {
      itemsCarrito[indice].cantidad =
          cantidadServidor ?? itemsCarrito[indice].cantidad + 1;
      return;
    }

    itemsCarrito.add(
      ItemCarrito(
        id: idRegistro,
        productoId: productoId,
        imagen: imagen,
        titulo: titulo,
        subtitulo: producto != null ? _subtituloDe(producto) : subtitulo,
        precio: (registro['precio'] as num?)?.toDouble() ?? precio,
        talla: talla,
        color: color,
        cantidad: cantidadServidor ?? 1,
        producto: producto,
      ),
    );
  }

  // 3. Actualizar la cantidad de un ítem
  static Future<void> actualizarCantidad(ItemCarrito item, int cantidad) async {
    final headers = await _headersSiSesion();
    if (headers == null) {
      _iniciarCarritoInvitado();
      item.cantidad = cantidad;
      return;
    }

    if (_carritoInvitado) {
      await _sincronizarCarritoInvitado(headers);
      final indice = itemsCarrito.indexWhere(
        (actual) => _mismaVariante(actual, item),
      );
      if (indice < 0) {
        throw Exception('No se encontró el producto en el carrito.');
      }
      item = itemsCarrito[indice];
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/carrito/${item.id}'),
      headers: headers,
      body: jsonEncode({'cantidad': cantidad}),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    item.cantidad = cantidad;
  }

  // 4. Eliminar un ítem individual
  static Future<void> eliminar(ItemCarrito item) async {
    final headers = await _headersSiSesion();
    if (headers == null) {
      _iniciarCarritoInvitado();
      itemsCarrito.removeWhere((registro) => registro.id == item.id);
      return;
    }

    if (_carritoInvitado) {
      await _sincronizarCarritoInvitado(headers);
      final indice = itemsCarrito.indexWhere(
        (actual) => _mismaVariante(actual, item),
      );
      if (indice < 0) {
        throw Exception('No se encontró el producto en el carrito.');
      }
      item = itemsCarrito[indice];
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/carrito/${item.id}'),
      headers: headers,
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    itemsCarrito.removeWhere((registro) => registro.id == item.id);
  }

  // 5. Vaciar todo el carrito
  static Future<void> vaciar() async {
    final headers = await _headersSiSesion();
    if (headers == null) {
      _iniciarCarritoInvitado();
      itemsCarrito.clear();
      return;
    }

    if (_carritoInvitado) {
      await _sincronizarCarritoInvitado(headers);
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/carrito/vaciar'),
      headers: headers,
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(body, response.statusCode));
    }
    itemsCarrito.clear();
    _carritoInvitado = false;
    _itemsInvitadosSincronizados.clear();
  }

  static Future<Map<String, String>?> _headersSiSesion() async {
    final preferences = await SharedPreferences.getInstance();
    final token =
        preferences.getString('token') ?? preferences.getString('jwt_token');
    if (token == null || token.trim().isEmpty) return null;
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, String>> _headers() async {
    final headers = await _headersSiSesion();
    if (headers == null) {
      throw Exception('Inicia sesión para consultar y guardar tu carrito.');
    }
    return headers;
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
      final mensaje =
          (body['error'] ?? body['message'] ?? 'Error del servidor')
              .toString();
      final detalle = body['detalle']?.toString() ?? '';
      return detalle.isNotEmpty ? '$mensaje: $detalle' : mensaje;
    }
    return 'Error del servidor (código $statusCode).';
  }
}