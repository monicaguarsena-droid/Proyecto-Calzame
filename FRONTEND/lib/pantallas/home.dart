import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Color colorFondo = const Color(0xFFFBF8F6);
  final Color colorVino = const Color(0xFF60182E);
  final Color colorTextoSecundario = const Color(0xFF8C737B);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CalzaMe',
                        style: TextStyle(
                          color: colorVino,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Colecciones para toda la familia',
                        style: TextStyle(
                          color: colorTextoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconButton(Icons.search),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.shopping_bag_outlined),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner Principal
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: const DecorationImage(
                    image: AssetImage('assets/img/botas.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'NUEVA COLECCIÓN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Verano con estilo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hasta 30% de descuento en calzado de verano',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Explora por persona
              _buildSectionTitle('Explora por persona'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildPersonaCard('Dama', 'Zapatos y sandalias')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPersonaCard('Niña', 'Colecciones infantiles')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPersonaCard('Caballero', 'Estilo urbano y formal')),
                ],
              ),
              const SizedBox(height: 25),

              // Tipos de calzado
              _buildSectionTitle('Tipos de calzado'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTipoCard('Sandalias', 'Verano y playa')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTipoCard('Botas', 'Invierno y noche')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTipoCard('Zapatillas', 'Deporte y diario')),
                ],
              ),
              const SizedBox(height: 25),

              // Colecciones destacadas
              _buildSectionTitle('Colecciones destacadas'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildColeccionCard('Botas de cuero', 'Desde \$129', 'assets/img/botas.jpg')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildColeccionCard('Zapatillas', 'Desde \$89', 'assets/img/zapatillas.jpg')),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: colorVino,
        unselectedItemColor: colorTextoSecundario,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEADAD0)),
      ),
      child: Icon(icon, color: colorVino, size: 18),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: colorVino, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          'Ver todo',
          style: TextStyle(color: colorVino, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPersonaCard(String titulo, String subtitulo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2E6E1)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline, color: colorVino, size: 20),
          const SizedBox(height: 8),
          Text(titulo, style: TextStyle(color: colorVino, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitulo, textAlign: TextAlign.center, style: TextStyle(color: colorTextoSecundario, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTipoCard(String titulo, String subtitulo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2E6E1)),
      ),
      child: Column(
        children: [
          Icon(Icons.snowshoeing, color: colorVino, size: 20),
          const SizedBox(height: 8),
          Text(titulo, style: TextStyle(color: colorVino, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitulo, textAlign: TextAlign.center, style: TextStyle(color: colorTextoSecundario, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildColeccionCard(String titulo, String precio, String imagenPath) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagenPath),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(precio, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}