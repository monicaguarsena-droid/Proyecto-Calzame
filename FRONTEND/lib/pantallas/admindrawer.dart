import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/admininventario.dart';
import 'package:frontend/pantallas/adminpedido.dart';
import 'package:frontend/pantallas/admin_ofertas.dart';
import 'package:frontend/pantallas/admin_tipos_calzado.dart';
import 'package:frontend/pantallas/inicio_sesion.dart'; // Asegúrate de que apunte a tu archivo de login correcto
import 'package:frontend/pantallas/paneldeusuarios.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AdminDrawer - menú lateral del panel administrativo adaptado a CalzaMe
class AdminDrawer extends StatelessWidget {
  // Color principal de CalzaMe
  static const Color _colorPrincipal = ColoresApp.primary; // 0xFF6B1229

  final String adminName;
  final String adminEmail;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.adminEmail,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    // 1. Limpiar datos de sesión guardados en el dispositivo
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    // 2. Ir al Login y eliminar todo el historial de navegación anterior
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  void_proximamente(BuildContext context, String seccion) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$seccion: próximamente'),
        backgroundColor: _colorPrincipal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String inicial = adminName.isNotEmpty
        ? adminName[0].toUpperCase()
        : 'M';

    return Drawer(
      backgroundColor: ColoresApp.background,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header con nombre y correo del administrador usando los colores de CalzaMe
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: _colorPrincipal),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _colorPrincipal,
                      ),
                    ),
                  ),
                  accountName: Text(
                    adminName.isNotEmpty ? adminName : 'Mónica Molina',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    adminEmail.isNotEmpty
                        ? adminEmail
                        : 'monicaguarsena@gmail.com',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Opción Productos / Inventario
                _drawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventario de Productos',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventarioAdminPage(),
                    ),
                  ),
                ),

                // Opción Usuarios
                _drawerItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Usuarios y Clientes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientesAdminPage(),
                    ),
                  ),
                ),

                // Opción Pedidos
                _drawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos de Clientes',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PedidosAdmin()),
                  ),
                ),

                _drawerItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Ofertas y Banners',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminOfertasScreen(),
                    ),
                  ),
                ),

                _drawerItem(
                  icon: Icons.category_outlined,
                  title: 'Tipos de Calzado',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminTiposCalzadoPage(),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Divider(),
                ),
              ],
            ),
          ),

          // Separador visual inferior
          const Divider(height: 1),

          // Botón Cerrar Sesión en la parte inferior con estilo rojo de alerta
          SafeArea(
            top: false,
            child: _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar Sesión',
              color: Colors.red.shade700,
              onTap: () => _cerrarSesion(context),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? _colorPrincipal),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? ColoresApp.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
