import 'dart:convert';

class ProductoColorImagen {
  final String color;
  final String imagenUrl;

  const ProductoColorImagen({required this.color, required this.imagenUrl});

  factory ProductoColorImagen.fromJson(Map<String, dynamic> json) =>
      ProductoColorImagen(
        color: (json['color'] ?? '').toString(),
        imagenUrl: (json['imagenUrl'] ?? json['imagen'] ?? '').toString(),
      );
}

class ProductoModel {
  final String id;
  final String nombre;
  final String categoria;
  final String? tipoCalzado;
  final double precio;
  final int stock;
  final String descripcion;
  final List<String> tallas;
  final List<String> imagenes;
  final List<ProductoColorImagen> colores;

  const ProductoModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.tipoCalzado,
    required this.precio,
    required this.stock,
    required this.descripcion,
    required this.tallas,
    required this.imagenes,
    required this.colores,
  });

  /// Imagen para tarjetas y listas: la del primer color o la principal.
  String get imagenPrincipal {
    if (colores.isNotEmpty && colores.first.imagenUrl.isNotEmpty) {
      return colores.first.imagenUrl;
    }
    return imagenes.isNotEmpty ? imagenes.first : '';
  }

  /// Las columnas Tallas / Colores / Imagenes pueden llegar como lista real
  /// (jsonb) o como texto JSON (columna text). Esto cubre los dos casos.
  static dynamic _decode(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      try {
        return jsonDecode(v);
      } catch (_) {
        return null;
      }
    }
    return v;
  }

  static List<dynamic> _lista(dynamic v) {
    final d = _decode(v);
    return d is List ? d : const [];
  }

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    final imagen = (json['Imagen'] ?? json['imagen'] ?? '').toString();
    final extra = _lista(json['Imagenes'] ?? json['imagenes'])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();

    return ProductoModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['Nombre'] ?? json['nombre'] ?? '').toString(),
      categoria: (json['Categoria'] ?? json['categoria'] ?? '').toString(),
      tipoCalzado: (json['TipoCalzado'] ?? json['tipoCalzado'])?.toString(),
      precio:
          double.tryParse((json['Precio'] ?? json['precio'] ?? 0).toString()) ??
              0,
      stock: int.tryParse(
              (json['Stock'] ?? json['Existencias'] ?? json['stock'] ?? 0)
                  .toString()) ??
          0,
      descripcion:
          (json['Descripcion'] ?? json['descripcion'] ?? '').toString(),
      tallas: _lista(json['Tallas'] ?? json['tallas'])
          .map((e) => e.toString())
          .toList(),
      // Set para no repetir la foto principal si también está en Imagenes
      imagenes: <String>{if (imagen.isNotEmpty) imagen, ...extra}.toList(),
      colores: _lista(json['Colores'] ?? json['colores'])
          .whereType<Map>()
          .map((e) =>
              ProductoColorImagen.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}