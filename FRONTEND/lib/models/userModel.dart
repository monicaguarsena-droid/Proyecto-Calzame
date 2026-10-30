class UserModel {
  final String? id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? direccion;
  final String rol;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.direccion,
    this.rol = 'usuario',
  });

  bool get esAdmin => rol.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['id_usuario']?.toString(),
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      email: json['email'] ?? json['Email'] ?? json['gmail'] ?? '',
      telefono: json['telefono'] ?? json['Telefono'] ?? '',
      direccion: json['direccion'] ?? json['Direccion'] ?? '',
      rol: json['rol'] ?? json['Rol'] ?? 'usuario',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'rol': rol,
    };
  }
}