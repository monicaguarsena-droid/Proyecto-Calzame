import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/pedido.dart';
import 'package:frontend/pantallas/detalle_pedido.dart';
import 'package:frontend/pantallas/inicio_sesion.dart'; // Asegúrate de tener la ruta correcta al Login

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final int _tab = 3; // Pestaña Cuenta seleccionada

  // Datos de la cuenta (iniciales vacíos o por defecto mientras cargan de la BD)
  String _nombre = '';
  String _email = '';
  String _telefono = 'No registrada';
  String _direccion = 'No registrada';
  bool _notificacionesActivas = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // 1. Cargar datos desde SharedPreferences o el Backend
  Future<void> _cargarDatosUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Intentamos recuperar lo que se guardó localmente al hacer login
      String? emailGuardado = prefs.getString('email');
      String? nombreGuardado = prefs.getString('nombre');
      String? token = prefs.getString('token');

      if (mounted) {
      setState(() {
        if (nombreGuardado != null && nombreGuardado.isNotEmpty) {
          _nombre = nombreGuardado;
        }
        if (emailGuardado != null && emailGuardado.isNotEmpty) {
          _email = emailGuardado;
        }
      });
    }

      // Opcional: Si tienes un endpoint en tu backend Node.js (ej. /api/usuarios/perfil)
      if (emailGuardado != null && emailGuardado.isNotEmpty) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/usuarios/perfil?email=$emailGuardado'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Mapeo flexible según cómo devuelva los datos tu controlador en Node.js
        final usuarioBD = (data is Map && data.containsKey('usuario'))
            ? data['usuario']
            : data;

        if (mounted && usuarioBD != null) {
          setState(() {
            _nombre = usuarioBD['nombre'] ?? usuarioBD['name'] ?? _nombre;
            _email = usuarioBD['email'] ?? usuarioBD['correo'] ?? _email;
            _telefono = usuarioBD['telefono'] ?? usuarioBD['phone'] ?? _telefono;
            _direccion = usuarioBD['direccion'] ?? usuarioBD['address'] ?? _direccion;
          });
        }
      } else {
        print('Error en la petición: ${response.statusCode} - ${response.body}');
      }
    }
  } catch (e) {
    print('Excepción al cargar el perfil desde la BD: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false; // Desactiva el estado de carga
      });
    }
  }
}

  // 2. Función para actualizar los datos en el Backend (Opcional pero recomendado)
  Future<void> _actualizarDatosEnBD(String nuevoNombre, String nuevoEmail, String nuevoTelefono, String nuevaDireccion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/usuarios/actualizar'), // Ajusta tu ruta del backend
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'emailActual': _email, // Para identificar al usuario
          'nombre': nuevoNombre,
          'email': nuevoEmail,
          'telefono': nuevoTelefono,
          'direccion': nuevaDireccion,
        }),
      );

      if (response.statusCode == 200) {
        // Actualizamos SharedPreferences también
        await prefs.setString('nombre', nuevoNombre);
        await prefs.setString('email', nuevoEmail);
      }
    } catch (e) {
      print('Error al actualizar en el servidor: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _tab) return;

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CarritoScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FavoritosScreen()));
    }
  }

  // Modal para ver el historial de pedidos
  void _mostrarHistorialPedidos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Pedidos Realizados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecciona un pedido para ver el detalle completo.',
                style: TextStyle(fontSize: 12, color: ColoresApp.textSecondary),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Expanded(
                child: HistorialPedidosService.listaPedidos.isEmpty
                    ? const Center(
                        child: Text(
                          'Aún no tienes pedidos registrados.',
                          style: TextStyle(color: ColoresApp.textSecondary, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: HistorialPedidosService.listaPedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = HistorialPedidosService.listaPedidos[index];
                          String fecha = '${pedido.fechaHora.day}/${pedido.fechaHora.month}/${pedido.fechaHora.year}';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ColoresApp.border),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColoresApp.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_bag, color: ColoresApp.primary, size: 20),
                              ),
                              title: Text(
                                'Pedido #${pedido.idPedido}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ColoresApp.primary),
                              ),
                              subtitle: Text(
                                'Fecha: $fecha  •  Estado: ${pedido.estado}\nTotal: \$${pedido.total.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: ColoresApp.textSecondary, height: 1.3),
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: ColoresApp.primary),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetallePedidoScreen(pedido: pedido),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal para editar Nombre, Correo, Teléfono y Dirección
  void _mostrarModalEdicion() {
    final nombreCtrl = TextEditingController(text: _nombre);
    final emailCtrl = TextEditingController(text: _email);
    final telefonoCtrl = TextEditingController(text: _telefono);
    final direccionCtrl = TextEditingController(text: _direccion);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editar Información Personal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ColoresApp.primary)),
              const SizedBox(height: 14),
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico (Gmail)')),
              const SizedBox(height: 10),
              TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
              const SizedBox(height: 10),
              TextField(controller: direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección de entrega')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    setState(() {
                      _nombre = nombreCtrl.text;
                      _email = emailCtrl.text;
                      _telefono = telefonoCtrl.text;
                      _direccion = direccionCtrl.text;
                    });

                    // Guardar cambios en el backend y base de datos
                    await _actualizarDatosEnBD(_nombre, _email, _telefono, _direccion);

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Datos actualizados con éxito!'), backgroundColor: ColoresApp.success),
                    );
                  },
                  child: const Text('Guardar cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ColoresApp.primary))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back, color: ColoresApp.primary, size: 20),
                          ),
                        ),
                        const Text('MI CUENTA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ColoresApp.primary)),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avatar y Nombre dinámico
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ColoresApp.primary, width: 2),
                        color: const Color(0xFFEFE6EE),
                      ),
                      child: const Icon(Icons.person, size: 50, color: ColoresApp.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(_nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                    const SizedBox(height: 2),
                    Text(_email, style: const TextStyle(fontSize: 13, color: ColoresApp.textSecondary)),
                    const SizedBox(height: 24),

                    // Tarjetas de Opciones
                    _tarjetaOpcion(
                      icon: Icons.shopping_bag_outlined,
                      titulo: 'Mis pedidos',
                      subtitulo: 'Revisa el estado de tus compras',
                      onTap: _mostrarHistorialPedidos,
                    ),
                    const SizedBox(height: 12),
                    _tarjetaOpcion(
                      icon: Icons.person_outline,
                      titulo: 'Editar información personal',
                      subtitulo: 'Nombre, Gmail, teléfono y dirección',
                      onTap: _mostrarModalEdicion,
                    ),
                    const SizedBox(height: 12),
                    _tarjetaOpcion(
                      icon: Icons.location_on_outlined,
                      titulo: 'Dirección de entrega principal',
                      subtitulo: _direccion,
                      onTap: _mostrarModalEdicion,
                    ),
                    const SizedBox(height: 12),

                    // Configuración con Switch de Notificaciones
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColoresApp.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColoresApp.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_outlined, color: ColoresApp.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Notificaciones push', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                                const SizedBox(height: 2),
                                Text(_notificacionesActivas ? 'Activadas' : 'Desactivadas', style: const TextStyle(fontSize: 12, color: ColoresApp.textSecondary)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notificacionesActivas,
                            activeColor: ColoresApp.primary,
                            onChanged: (value) {
                              setState(() {
                                _notificacionesActivas = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón Cerrar Sesión (Limpia SharedPreferences y regresa al Login o Home)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7A1D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear(); // Limpia los datos de sesión almacenados

                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const Login()), // O pon tu pantalla de Login
                            (route) => false,
                          );
                        },
                        child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('🔒 Tus datos están protegidos y seguros', style: TextStyle(fontSize: 11, color: ColoresApp.textSecondary)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _tarjetaOpcion({required IconData icon, required String titulo, required String subtitulo, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColoresApp.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ColoresApp.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                  const SizedBox(height: 2),
                  Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: ColoresApp.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: ColoresApp.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _nav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Inicio'),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Carrito'),
      (Icons.favorite_border, Icons.favorite, 'Favoritos'),
      (Icons.person_outline, Icons.person, 'Cuenta'),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: ColoresApp.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_tab == i ? items[i].$2 : items[i].$1, size: 22, color: _tab == i ? ColoresApp.primary : ColoresApp.textSecondary),
                      const SizedBox(height: 2),
                      Text(items[i].$3, style: TextStyle(fontSize: 11, fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400, color: _tab == i ? ColoresApp.primary : ColoresApp.textSecondary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}