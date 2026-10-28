class ProductoModel {
  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;
  final String? imagenUrl; // Puede ser URL de red o ruta local (File path)

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    this.imagenUrl,
  });

  // Mapear la respuesta que viene del backend/BD
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    final precio = json['precio'] ?? json['Precio'];
    final imagen =
        json['imagenUrl'] ??
        json['imagen_url'] ??
        json['Imagen_url'] ??
        json['Imagen'] ??
        json['imagen'];
    return ProductoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: (json['nombre'] ?? json['Nombre'] ?? '').toString(),
      categoria: (json['categoria'] ?? json['Categoria'] ?? '').toString(),
      precio: precio is num
          ? precio.toDouble()
          : double.tryParse(precio?.toString() ?? '') ?? 0.0,
      descripcion: (json['descripcion'] ?? json['Descripcion'] ?? '')
          .toString(),
      imagenUrl: imagen?.toString(),
    );
  }

  // Convertir a Map para enviar datos al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'descripcion': descripcion,
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
    };
  }
}
