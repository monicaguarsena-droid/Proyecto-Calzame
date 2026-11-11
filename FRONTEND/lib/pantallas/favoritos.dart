import 'package:flutter/material.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/servicios/favoritos_service.dart';
import 'package:frontend/servicios/producto_service.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final int _tab = 2;
  final ProductoService _productoService = ProductoService();

  List<ProductoModel> _productos = [];
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool mostrarSpinner = true}) async {
    if (mostrarSpinner) {
      setState(() {
        _cargando = true;
        _error = false;
      });
    }
    try {
      final ids = await FavoritosService.obtenerIds();
      var lista = <ProductoModel>[];
      if (ids.isNotEmpty) {
        final todos = await _productoService.obtenerProductos();
        lista = todos.where((p) => ids.contains(p.id)).toList();
        // más recientes primero
        final orden = ids.reversed.toList();
        lista.sort((a, b) => orden.indexOf(a.id).compareTo(orden.indexOf(b.id)));
      }
      if (!mounted) return;
      setState(() {
        _productos = lista;
        _cargando = false;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = true;
      });
    }
  }

  Future<void> _quitar(ProductoModel producto) async {
    await FavoritosService.alternar(producto.id);
    if (!mounted) return;
    setState(() => _productos.removeWhere((p) => p.id == producto.id));
  }

  Future<void> _abrirDetalle(ProductoModel producto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProductoScreen(producto: producto),
      ),
    );
    // por si lo quitó o agregó desde el detalle
    if (mounted) _cargar(mostrarSpinner: false);
  }

  void _onItemTapped(int index) {
    final Widget? pantalla = switch (index) {
      0 => const Home(),
      1 => const CarritoScreen(),
      3 => const PerfilScreen(),
      _ => null,
    };
    if (pantalla == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  String _formatearPrecio(double valor) {
    return valor
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              const Text(
                'FAVORITOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _productos.isEmpty
                    ? 'Tus productos guardados'
                    : '${_productos.length} producto${_productos.length == 1 ? '' : 's'} guardado${_productos.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresApp.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(child: _contenido()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () => _cargar(mostrarSpinner: false),
      child: _error
          ? _mensaje('No se pudieron cargar tus favoritos.\nDesliza hacia abajo para reintentar.')
          : _productos.isEmpty
              ? _mensaje('Aún no tienes favoritos.\nToca el corazón en un producto para guardarlo aquí.')
              : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: _productos.length,
                  itemBuilder: (_, i) => _tarjeta(_productos[i]),
                ),
    );
  }

  Widget _mensaje(String texto) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ColoresApp.textSecondary),
              ),
            ),
          ),
        ],
      );

  Widget _tarjeta(ProductoModel producto) {
    final imagen = producto.imagenPrincipal;
    return GestureDetector(
      onTap: () => _abrirDetalle(producto),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: imagen.isEmpty
                          ? imagenCatalogoPlaceholder(iconSize: 36)
                          : Image.network(
                              imagen,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  imagenCatalogoPlaceholder(iconSize: 36),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 1.5,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _quitar(producto),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.favorite,
                            size: 18,
                            color: ColoresApp.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              producto.nombre,
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
              [
                if (producto.categoria.trim().isNotEmpty) producto.categoria.trim(),
                if ((producto.tipoCalzado ?? '').trim().isNotEmpty)
                  producto.tipoCalzado!.trim(),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: ColoresApp.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${_formatearPrecio(producto.precio)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ColoresApp.primary,
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
                          fontWeight:
                              _tab == i ? FontWeight.w700 : FontWeight.w400,
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