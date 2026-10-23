import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/producto.dart';

class CategoriaInfantil extends StatefulWidget {
  const CategoriaInfantil({super.key});

  @override
  State<CategoriaInfantil> createState() => _CategoriaInfantilState();
}

class _CategoriaInfantilState extends State<CategoriaInfantil> {
  final int _tab = 0;

  final List<Map<String, dynamic>> _productosInfantil = [
    {
      'imagen': 'assets/img/tenisinfantil.jpg',
      'titulo': 'Tenis con luces',
      'subtitulo': 'Divertidos · Cómodos',
      'precio': '\$79',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/zapatoinfantil.jpg',
      'titulo': 'Zapato escolar',
      'subtitulo': 'Cuero duradero · Resistente',
      'precio': '\$69',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/sandaliainfantil.jpg',
      'titulo': 'Sandalia playera',
      'subtitulo': 'Suave · Antideslizante',
      'precio': '\$49',
      'esFavorito': false,
    },
    {
      'imagen': 'assets/img/botaoinfantil.jpg',
      'titulo': 'Botín impermeable',
      'subtitulo': 'Ideal para lluvia',
      'precio': '\$89',
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
                    'CALZADO INFANTIL',
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
                    childAspectRatio: 0.56,
                  ),
                  itemCount: _productosInfantil.length,
                  itemBuilder: (context, index) {
                    final item = _productosInfantil[index];
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
                      _productosInfantil[index]['esFavorito'] = !esFavorito;
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
          // Botón Ver producto
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleProductoScreen(
                      imagen: asset,
                      titulo: titulo,
                      subtitulo: subtitulo,
                      precio: precio,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColoresApp.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Ver producto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ColoresApp.primary)),
            ),
          ),
          const SizedBox(height: 6),
          // Botón Agregar al carrito
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {
                CarritoService.agregarProducto(imagen: asset, titulo: titulo, subtitulo: subtitulo, precioStr: precio);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Producto agregado al carrito!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
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