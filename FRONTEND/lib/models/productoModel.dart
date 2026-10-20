class ProductoModel {
  final String id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String? imagenUrl; // Puede ser URL de red o ruta local (File path)

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    this.imagenUrl,
  });

  // Mapear la respuesta que viene del backend/BD
  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] ?? '',
      imagenUrl: json['imagenUrl'] ?? json['imagen_url'] ?? json['imagen'],
    );
  }

  // Convertir a Map para enviar datos al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      if (imagenUrl != null) 'imagenUrl': imagenUrl,
    };
  }
}