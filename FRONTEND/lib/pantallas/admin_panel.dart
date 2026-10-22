import 'package:flutter/material.dart';
// Importa aquí tus pantallas creadas:
// import 'package:frontend/pantallas/inventario_screen.dart';
// import 'package:frontend/pantallas/pedidos_screen.dart';
// import 'package:frontend/pantallas/categorias_screen.dart';
// import 'package:frontend/pantallas/usuarios_screen.dart';
// import 'package:frontend/pantallas/reportes_screen.dart';
// import 'package:frontend/pantallas/configuracion_screen.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  final Color _primaryColor = const Color(0xFF6B2D3C);
  final Color _backgroundColor = const Color(0xFFF7F4F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado superior
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calzado Mar&Paz',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Panel Administrador',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'ML',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjeta de Ventas Totales
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ventas totales',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$12.480',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              painter: LineChartPainter(color: _primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'respecto al mes anterior',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas secundarias (Pedidos pendientes y Productos activos)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Pedidos pendientes',
                      value: '12',
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Productos activos',
                      value: '148',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Título de sección
              Text(
                'Gestiona tu tienda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Cuadrícula con las rutas configuradas en cada tarjeta
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  // 1. Inventario de Productos
                  _buildMenuCard(
                    title: 'Inventario de Productos',
                    icon: Icons.inventory_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Inventario
                      );
                    },
                  ),
                  // 2. Pedidos de Clientes
                  _buildMenuCard(
                    title: 'Pedidos de Clientes',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Pedidos
                      );
                    },
                  ),
                  // 3. Categorías y Ofertas
                  _buildMenuCard(
                    title: 'Categorías y Ofertas',
                    icon: Icons.local_offer_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Categorías
                      );
                    },
                  ),
                  // 4. Usuarios y Clientes
                  _buildMenuCard(
                    title: 'Usuarios y Clientes',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Usuarios
                      );
                    },
                  ),
                  // 5. Reportes de Ventas
                  _buildMenuCard(
                    title: 'Reportes de Ventas',
                    icon: Icons.bar_chart_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Reportes
                      );
                    },
                  ),
                  // 6. Configuración Tienda
                  _buildMenuCard(
                    title: 'Configuración Tienda',
                    icon: Icons.tune_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Placeholder()), // Reemplaza por tu pantalla real de Configuración
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              Icon(icon, color: _primaryColor, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: _primaryColor, size: 24),
                Icon(Icons.arrow_outward, color: Colors.grey.shade400, size: 16),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final Color color;
  LineChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.lineTo(size.width * 0.45, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.65);
    path.lineTo(size.width * 0.75, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}