import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  int _tab = 2; // Pestaña de Favoritos seleccionada

  // Lista de productos favoritos
  final List<Map<String, String>> _favoritos = [
    {
      'imagen': 'assets/img/sandalia.jpg',
      'titulo': 'Sandalia de tiras',
      'subtitulo': 'Cuero suave · Tono beige',
      'precio': '\$129',
    },
    {
      'imagen': 'assets/img/bota.jpg',
      'titulo': 'Bota tobillera',
      'subtitulo': 'Cuero negro · Tacón bajo',
      'precio': '\$149',
    },
    {
      'imagen': 'assets/img/zapatillas.jpg',
      'titulo': 'Zapatillas blancas',
      'subtitulo': 'Suela cómoda · Diario',
      'precio': '\$89',
    },
    {
      'imagen': 'assets/img/mule.jpg',
      'titulo': 'Mule de cuero',
      'subtitulo': 'Marrón claro · Minimalista',
      'precio': '\$119',
    },
  ];

  void _onItemTapped(int index) {
    if (index == _tab) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CarritoScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _header(context),
              const SizedBox(height: 16),
              _subHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62, // Controla la altura de las tarjetas para que no se deformen
                  ),
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    final item = _favoritos[index];
                    return _tarjetaProducto(
                      item['imagen']!,
                      item['titulo']!,
                      item['subtitulo']!,
                      item['precio']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  // Encabezado con botón de volver
  Widget _header(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ColoresApp.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'FAVORITOS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ColoresApp.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // Subencabezado "Tus elegidos" con badge
  Widget _subHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Tus elegidos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ColoresApp.primary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Los que te encantan, en un solo lugar.',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ColoresApp.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '4 productos',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ColoresApp.primary,
            ),
          ),
        ),
      ],
    );
  }

  // Tarjeta de producto con altura ajustada
  Widget _tarjetaProducto(
    String asset,
    String titulo,
    String subtitulo,
    String precio,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con botón de corazón
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ColoresApp.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: ColoresApp.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: ColoresApp.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: ColoresApp.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            precio,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ColoresApp.primary,
            ),
          ),
          const Spacer(),
          // Botón "Agregar al carrito"
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                CarritoService.agregarProducto(
                  imagen: asset,
                  titulo: titulo,
                  subtitulo: subtitulo,
                  precioStr: precio,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Producto agregado al carrito!'),
                    backgroundColor: ColoresApp.success,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Agregar al carrito',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Barra de navegación inferior actualizada con Carrito
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
                      Icon(
                        _tab == i ? items[i].$2 : items[i].$1,
                        size: 22,
                        color: _tab == i
                            ? ColoresApp.primary
                            : ColoresApp.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _tab == i
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _tab == i
                              ? ColoresApp.primary
                              : ColoresApp.textSecondary,
                        ),
                      ),
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