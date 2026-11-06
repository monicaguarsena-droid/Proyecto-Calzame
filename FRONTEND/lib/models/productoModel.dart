  import 'dart:convert';

class ProductoColorImagen {
    final String color;
    final String imagenUrl;

    ProductoColorImagen({required this.color, required this.imagenUrl});

    factory ProductoColorImagen.fromJson(Map<String, dynamic> json) {
      return ProductoColorImagen(
        color: json['color'] ?? '',
        imagenUrl: json['imagenUrl'] ?? '',
      );
    }

    Map<String, dynamic> toJson() => {'color': color, 'imagenUrl': imagenUrl};
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
    final List<String> imagenes; // Soporte para múltiples fotos
    final List<ProductoColorImagen> colores; // Relación Color <-> Foto

    ProductoModel({
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

    factory ProductoModel.fromJson(Map<String, dynamic> json) {
      // Parseo seguro de tallas
      var tallasRaw = json['Tallas'] ?? json['tallas'] ?? [];
      List<String> parsedTallas = [];
      if (tallasRaw is String) {
        try {
          parsedTallas = List<String>.from(jsonDecode(tallasRaw));
        } catch (_) {}
      } else if (tallasRaw is List) {
        parsedTallas = tallasRaw.map((e) => e.toString()).toList();
      }

      // Parseo de múltiples imágenes y colores
      var imagenesRaw = json['Imagenes'] ?? json['imagenes'] ?? [];
      List<String> parsedImagenes = imagenesRaw is List ? imagenesRaw.map((e) => e.toString()).toList() : [];

      var coloresRaw = json['Colores'] ?? json['colores'] ?? [];
      List<ProductoColorImagen> parsedColores = [];
      if (coloresRaw is List) {
        parsedColores = coloresRaw.map((e) => ProductoColorImagen.fromJson(e)).toList();
      }

      return ProductoModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        nombre: (json['Nombre'] ?? json['nombre'] ?? '').toString(),
        categoria: (json['Categoria'] ?? json['categoria'] ?? '').toString(),
        tipoCalzado: (json['TipoCalzado'] ?? json['tipoCalzado'])?.toString(),
        precio: double.tryParse((json['Precio'] ?? json['precio'] ?? 0).toString()) ?? 0.0,
        stock: int.tryParse((json['Stock'] ?? json['stock'] ?? 0).toString()) ?? 0,
        descripcion: (json['Descripcion'] ?? json['descripcion'] ?? '').toString(),
        tallas: parsedTallas,
        imagenes: parsedImagenes,
        colores: parsedColores,
      );
    }
  

  // Convertir a Map para enviar datos al backend
 // Convertir a Map para enviar datos al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'tipoCalzado': tipoCalzado,
      'precio': precio,
      'descripcion': descripcion,
      'tallas': tallas,
      'imagenes': imagenes,
      'colores': colores.map((e) => e.toJson()).toList(),
    };
  }
}