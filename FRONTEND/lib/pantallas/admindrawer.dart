import 'package:flutter/material.dart';
import 'package:frontend/pages/menupagespro.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';
import 'package:shared_preferences/shared_preferences.dart';


// AdminDrawer - menú lateral del panel administrativo
class AdminDrawer extends StatelessWidget {
  static const Color _colorPrincipal = Color(0xFFBF285D);

  final String adminName;
  final String adminEmail;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.adminEmail,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    // 1. Limpiar datos de sesión guardados en el dispositivo (token, nombre, correo, rol)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    // 2. Ir al login y eliminar el historial de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  // Usuarios y Pedidos aún no tienen pantalla ni endpoint en el backend
  void _proximamente(BuildContext context, String seccion) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$seccion: próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String inicial = adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A';

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header con nombre y correo del administrador
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(color: _colorPrincipal),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      inicial,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _colorPrincipal),
                    ),
                  ),
                  accountName: Text(
                    adminName.isNotEmpty ? adminName : 'Administrador',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  accountEmail: Text(adminEmail.isNotEmpty ? adminEmail : 'Sin correo registrado'),
                  ),
                // Opción Productos (es la pantalla actual del panel)
                _drawerItem(
                  icon: Icons.icecream_outlined,
                  title: 'Productos',
                  onTap: () => Navigator.pop(context),
                ),
                // Opción Usuarios
                _drawerItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Usuarios',
                  onTap: () => _proximamente(context, 'Usuarios'),
                ),
                // Opción Pedidos
                _drawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos',
                  onTap: () => _proximamente(context, 'Pedidos'),
                ),
                const Divider(),
                // Ver la carta tal como la ve el cliente
                _drawerItem(
                  icon: Icons.menu_book_outlined,
                  title: 'Ver carta (cliente)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuPage()));
                  },
                ),
              ],
            ),
          ),
          // Separador visual
          const Divider(height: 1),

          // Botón Cerrar Sesión en la parte inferior
          SafeArea(
            top: false,
            child: _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Cerrar Sesión',
              color: Colors.red,
              onTap: () => _cerrarSesion(context),
            ),
          ),
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
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}