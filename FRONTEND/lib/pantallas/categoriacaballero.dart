import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/producto.dart';

class CategoriaCaballero extends StatefulWidget {
  const CategoriaCaballero({super.key});

  @override
  State<CategoriaCaballero> createState() => _CategoriaCaballeroState();
}

class _CategoriaCaballeroState extends State<CategoriaCaballero> {
  final int _tab = 0;

  final List<Map<String, dynamic>> _productosCaballero = [
    {
      'imagen': 'assets/img/zapatocaballero.jpg',
      'titulo': 'Zapato formal de cuero',
      'subtitulo': 'Elegante · Oficina',
      'precio': '\$145',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/botincaballero.jpg',
      'titulo': 'Botín casual',
      'subtitulo': 'Cuero resistente · Urbano',
      'precio': '\$160',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/teniscaballero.jpg',
      'titulo': 'Tenis deportivos',
      'subtitulo': 'Máxima amortiguación',
      'precio': '\$115',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/sandaliacaballero.jpg',
      'titulo': 'Sandalia de cuero',
      'subtitulo': 'Frescas · Verano',
      'precio': '\$85',
      'esFavorito': false,
    },
  ];

  void _onItemTapped(int index) {
    if (index == _tab) return;

    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CarritoScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FavoritosScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
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
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: ColoresApp.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CALZADO DE CABALLERO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ColoresApp.primary, letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Explora nuestra colección',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ColoresApp.primary),
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
                  itemCount: _productosCaballero.length,
                  itemBuilder: (context, index) {
                    final item = _productosCaballero[index];
                    return _tarjetaProducto(context, item, index);
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

  Widget _tarjetaProducto(BuildContext context, Map<String, dynamic> item, int index) {
    final asset = item['imagen'] as String;
    final titulo = item['titulo'] as String;
    final subtitulo = item['subtitulo'] as String;
    final precio = item['precio'] as String;
    final bool esFavorito = item['esFavorito'] as bool;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleProductoScreen(imagen: asset, titulo: titulo, subtitulo: subtitulo, precio: precio),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        child: const Icon(Icons.image_not_supported, color: ColoresApp.textSecondary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _productosCaballero[index]['esFavorito'] = !esFavorito;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(!esFavorito ? 'Añadido a favoritos' : 'Eliminado de favoritos'),
                          backgroundColor: ColoresApp.primary,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: ColoresApp.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ColoresApp.primary)),
            const SizedBox(height: 2),
            Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: ColoresApp.textSecondary)),
            const SizedBox(height: 6),
            Text(precio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresApp.primary)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  CarritoService.agregarProducto(imagen: asset, titulo: titulo, subtitulo: subtitulo, precioStr: precio);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Producto agregado al carrito!'), backgroundColor: ColoresApp.success, duration: Duration(seconds: 1)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Agregar al carrito', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
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