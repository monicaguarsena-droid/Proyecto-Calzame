import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/producto_service.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';

class CategoriaDama extends StatefulWidget {
  const CategoriaDama({super.key});

  @override
  State<CategoriaDama> createState() => _CategoriaDamaState();
}

class _CategoriaDamaState extends State<CategoriaDama> {
  final int _tab = 0;

  late Future<List<ProductoModel>> _productosDama;
  final ProductoService _productoService = ProductoService();

  @override
  void initState() {
    super.initState();
    _productosDama = _cargarProductosDama();
  }

  Future<List<ProductoModel>> _cargarProductosDama() async {
    final productos = await _productoService.obtenerProductos();
    return productos
        .where((producto) => producto.categoria.trim().toLowerCase() == 'dama')
        .toList();
  }

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
                    'CALZADO DE DAMA',
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
                'Explora nuestra colección',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<ProductoModel>>(
                  future: _productosDama,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'No se pudieron cargar los productos: ${snapshot.error}',
                        ),
                      );
                    }
                    final productos = snapshot.data ?? [];
                    if (productos.isEmpty) {
                      return const Center(
                        child: Text('Aún no hay productos en esta categoría.'),
                      );
                    }
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.56,
                          ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) =>
                          _tarjetaProducto(context, productos[index], index),
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

  Widget _tarjetaProducto(BuildContext context, ProductoModel item, int index) {
    final imagen = item.imagenUrl ?? '';
    final titulo = item.nombre;
    final subtitulo = item.descripcion;
    final precio = '\$${item.precio.toStringAsFixed(0)}';

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
                  child: imagen.isEmpty
                      ? imagenCatalogoPlaceholder()
                      : Image.network(
                          imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              imagenCatalogoPlaceholder(),
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
                      imagen: imagen,
                      titulo: titulo,
                      subtitulo: subtitulo,
                      precio: precio,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ColoresApp.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Ver producto',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Botón Agregar al carrito
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () {
                CarritoService.agregarProducto(
                  imagen: imagen,
                  titulo: titulo,
                  subtitulo: subtitulo,
                  precioStr: precio,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Producto agregado al carrito!'),
                    backgroundColor: Colors.green,
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
