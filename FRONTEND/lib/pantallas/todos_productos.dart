import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';

class TodosProductosScreen extends StatefulWidget {
  const TodosProductosScreen({super.key});

  @override
  State<TodosProductosScreen> createState() => _TodosProductosScreenState();
}

class _TodosProductosScreenState extends State<TodosProductosScreen> {
  final int _tab = 0;

  // Catálogo completo con 12 productos (Dama, Caballero e Infantil)
  final List<Map<String, String>> _todosLosProductos = const [
    // --- DAMA ---
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Botas altas de cuero',
      'subtitulo': 'Dama · Cuero suave e invierno',
      'precio': '\$129',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Stiletto clásico',
      'subtitulo': 'Dama · Tacón fino y elegante',
      'precio': '\$89',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Sandalia de tacón',
      'subtitulo': 'Dama · Estilo verano y fiesta',
      'precio': '\$110',
    },
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Botines casuales',
      'subtitulo': 'Dama · Confort y estilo diario',
      'precio': '\$135',
    },

    // --- CABALLERO ---
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Bota formal de vestir',
      'subtitulo': 'Caballero · Estilo urbano',
      'precio': '\$149',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Zapatos casuales',
      'subtitulo': 'Caballero · Comodidad diaria',
      'precio': '\$99',
    },
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Bota cazadora',
      'subtitulo': 'Caballero · Todo terreno',
      'precio': '\$159',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Mocasines elegantes',
      'subtitulo': 'Caballero · Cuero genuino',
      'precio': '\$120',
    },

    // --- INFANTIL / NIÑOS ---
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Botines infantiles',
      'subtitulo': 'Niños · Protección y confort',
      'precio': '\$69',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Zapatillas escolares',
      'subtitulo': 'Niños · Alta durabilidad',
      'precio': '\$59',
    },
    {
      'imagen': 'assets/img/tacon.jpg',
      'titulo': 'Sandalias infantiles',
      'subtitulo': 'Niños · Ligeras y frescas',
      'precio': '\$48',
    },
    {
      'imagen': 'assets/img/botas.jpg',
      'titulo': 'Bota acolchada infantil',
      'subtitulo': 'Niños · Térmica para frío',
      'precio': '\$75',
    },
  ];

  void _onItemTapped(int index) {
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FavoritosScreen()),
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
              Row(
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
                    'TODAS LAS CATEGORÍAS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Dama, Caballero e Infantil (12 productos)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: _todosLosProductos.length,
                  itemBuilder: (context, index) {
                    final item = _todosLosProductos[index];
                    return _tarjetaProducto(
                      context,
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

  Widget _tarjetaProducto(
    BuildContext context,
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