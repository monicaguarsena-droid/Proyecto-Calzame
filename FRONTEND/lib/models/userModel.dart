class UserModel {
  final String? id; // Nulo al crear, asignado por la BD al responder
  final String nombre;
  final String email;
  final String contrasena;
  final String rol;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.contrasena,
    this.rol = 'usuario', // Por defecto 'usuario'
  });

  // Getter útil para verificar si tiene permisos de administrador
  bool get esAdmin => rol.toLowerCase() == 'admin';

  // Mapear la respuesta de la base de datos (con el ID ya autocompletado)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(), // Lee el ID retornado por Supabase/Backend
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      contrasena: json['contrasena'] ?? '',
      rol: json['rol'] ?? 'usuario',
    );
  }

  // Convertir a Map para enviar en el POST
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'contrasena': contrasena,
      'rol': rol,
    };
  }
}