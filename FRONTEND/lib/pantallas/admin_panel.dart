import 'package:flutter/material.dart';
import 'package:frontend/pantallas/admindrawer.dart';
import 'package:frontend/pantallas/admininventario.dart';
import 'package:frontend/pantallas/adminpedido.dart';
// import 'package:frontend/pantallas/categorias_screen.dart';
// import 'package:frontend/pantallas/usuarios_screen.dart';
// import 'package:frontend/pantallas/reportes_screen.dart';
// import 'package:frontend/pantallas/configuracion_screen.dart';
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key,});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color _primaryColor = const Color(0xFF6B2D3C);
  final Color _backgroundColor = const Color(0xFFF7F4F0);

  late final List<Widget> _paginas = [
    _buildInicioAdmin(),
    const Center(child: Text('Pantalla Inventario', style: TextStyle(fontSize: 18))), // Reemplaza por tu pantalla real
    const Center(child: Text('Pantalla Pedidos', style: TextStyle(fontSize: 18))), // Reemplaza por tu pantalla real
    const Center(child: Text('Pantalla Ajustes', style: TextStyle(fontSize: 18))), // Reemplaza por tu pantalla real
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,

      drawer: AdminDrawer(
        adminName: 'Mónica Molina',
        adminEmail: 'monicaguarsena@gmail.com',
      ),
      
      body: _paginas[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _primaryColor,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Inventario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInicioAdmin() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calzado Mar&Paz',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Panel Administrador',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28),
                  color: _primaryColor,
                  onPressed: () {
                    // Abre el menú lateral izquierdo de forma directa y sin errores
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, const Color(0xFF4A1525)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ventas totales',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '+15.4%',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$12.480',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: LineChartPainter(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'respecto al mes anterior',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: '12',
                    title: 'Pedidos pendientes',
                    icon: Icons.access_time_filled,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    value: '148',
                    title: 'Productos activos',
                    icon: Icons.inventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Gestiona tu tienda',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildMenuCard(
                  icon: Icons.local_offer_outlined,
                  title: 'Inventario de Productos',
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> InventarioAdminPage()));},
                ),
                _buildMenuCard(
                  icon: Icons.local_offer_outlined,
                  title: 'Pedidos de Clientes',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> PedidosAdmin()));
                  },
                ),
                _buildMenuCard(
                  icon: Icons.local_offer_outlined,
                  title: 'Categorías y\nOfertas',
                  onTap: () {},
                ),
                _buildMenuCard(
                  icon: Icons.people_outline,
                  title: 'Usuarios y\nClientes',
                  onTap: () {},
                ),
                _buildMenuCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Reportes de\nVentas',
                  onTap: () {},
                ),
                _buildMenuCard(
                  icon: Icons.tune_outlined,
                  title: 'Configuración\nTienda',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String title,
    //required String subtitle,
    required IconData icon,
  }) {
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