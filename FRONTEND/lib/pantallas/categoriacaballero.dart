import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';

class CategoriaCaballero extends StatefulWidget {
  const CategoriaCaballero({super.key});

  @override
  State<CategoriaCaballero> createState() => _CategoriaCaballeroState();
}

class _CategoriaCaballeroState extends State<CategoriaCaballero> {
  int _tab = 0;

  void _onItemTapped(int index) {
    setState(() {
      _tab = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritosScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _header(context),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Catálogo caballero',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.primary,
                  ),
                ),
                Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _tarjetaProducto(
              imagen: 'assets/img/botascaballero.jpg',
              titulo: 'Botas de vestir',
              subtitulo: 'Cuero marrón · Tacón bajo',
              precio: r'$189',
            ),
            _tarjetaProducto(
              imagen: 'assets/img/mocasines.jpg',
              titulo: 'Mocasines de cuero',
              subtitulo: 'Cuero suave · Estilo clásico',
              precio: r'$159',
            ),
            _tarjetaProducto(
              imagen: 'assets/img/zapatillasnegras.jpg',
              titulo: 'Zapatillas negras',
              subtitulo: 'Suela cómoda · Diario',
              precio: r'$129',
            ),
            _tarjetaProducto(
              imagen: 'assets/img/monkstraps.jpg',
              titulo: 'Monk straps',
              subtitulo: 'Cuero cognac · Minimalista',
              precio: r'$179',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _header(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CalzaMe',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.primary,
                  ),
                ),
                Text(
                  'Calzado para caballero',
                  style: TextStyle(fontSize: 12, color: ColoresApp.textSecondary),
                ),
              ],
            ),
          ),
          const _Circ(Icons.search, size: 40),
          const SizedBox(width: 8),
          const _Circ(Icons.shopping_bag_outlined, size: 40),
        ],
      );

  Widget _tarjetaProducto({
    required String imagen,
    required String titulo,
    required String subtitulo,
    required String precio,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagen,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: ColoresApp.surfaceVariant,
                child: const Icon(Icons.image, color: ColoresApp.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ColoresApp.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  precio,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColoresApp.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Ver',
                  style: TextStyle(
                    color: ColoresApp.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: ColoresApp.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Inicio'),
      (Icons.search, Icons.search, 'Buscar'),
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

class _Circ extends StatelessWidget {
  final IconData icono;
  final double size;
  const _Circ(this.icono, {required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: ColoresApp.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icono, size: size * 0.5, color: ColoresApp.primary),
      );
}