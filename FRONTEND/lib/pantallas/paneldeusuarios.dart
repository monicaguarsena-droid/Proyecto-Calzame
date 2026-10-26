import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/admin_panel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientesAdminPage extends StatefulWidget {
  const ClientesAdminPage({Key? key}) : super(key: key);

  @override
  State<ClientesAdminPage> createState() => _ClientesAdminPageState();
}

class _ClientesAdminPageState extends State<ClientesAdminPage> {
  final String baseUrl = "http://10.0.2.2:3000"; // Tu URL base para el emulador
  
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  // Función para obtener los usuarios/clientes registrados desde el backend
  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Ruta de tu backend que lista los usuarios o clientes
      final response = await http.get(
        Uri.parse('$baseUrl/api/usuarios'), // Ajusta la ruta si en tu backend es /api/clientes o /api/users
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          var listaTemporal = decodedData['usuarios'] ?? decodedData['clientes'] ?? decodedData['data'] ?? decodedData;
          if (listaTemporal is List) {
            _usuarios = List<Map<String, dynamic>>.from(listaTemporal);
          }
        });
      }
    } catch (e) {
      print("Error al cargar usuarios: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar usuarios según el buscador por nombre o correo
    final usuariosFiltrados = _usuarios.where((user) {
      final nombre = (user['nombre'] ?? user['Nombre'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? user['Email'] ?? '').toString().toLowerCase();
      final query = _filtroBusqueda.toLowerCase();
      return nombre.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.textOnPrimary),
          onPressed: () => Navigator.pop(context, MaterialPageRoute(builder: (context) => const AdminPanel())),
        ),
        title: Text(
            "Usuarios y Clientes",
            style: TextStyle(
              color: ColoresApp.textOnPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de Búsqueda
              Container(
                decoration: BoxDecoration(
                  color: ColoresApp.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColoresApp.border),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _filtroBusqueda = value;
                    });
                  },
                  style: const TextStyle(color: ColoresApp.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o correo...',
                    hintStyle: TextStyle(color: ColoresApp.hint),
                    prefixIcon: Icon(Icons.search, color: ColoresApp.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Conteo de clientes registrados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${usuariosFiltrados.length} clientes registrados',
                    style: const TextStyle(color: ColoresApp.textSecondary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Listado de Tarjetas de Usuarios/Clientes
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: ColoresApp.primary)))
                  : usuariosFiltrados.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('No hay clientes registrados en la base de datos', style: TextStyle(color: ColoresApp.hint, fontSize: 14)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            final user = usuariosFiltrados[index];
                            final nombre = user['nombre'] ?? user['Nombre'] ?? 'Sin nombre';
                            final email = user['email'] ?? user['Email'] ?? 'Sin correo';
                            final rol = user['rol'] ?? user['Rol'] ?? 'Cliente';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColoresApp.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: ColoresApp.border),
                              ),
                              child: Row(
                                children: [
                                  // Icono de Avatar del cliente
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: ColoresApp.surfaceVariant,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.person, color: ColoresApp.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Información del Cliente
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: const TextStyle(color: ColoresApp.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: const TextStyle(color: ColoresApp.textSecondary, fontSize: 13),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: ColoresApp.surfaceVariant,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            rol,
                                            style: const TextStyle(color: ColoresApp.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}