import 'package:flutter/material.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/servicios/producto_service.dart';

class TodosProductosScreen extends StatefulWidget {
  /// Tipo de calzado (ej. "Sandalias") o categoría (ej. "Dama") a mostrar.
  /// Si es null o vacío se muestran todos los productos.
  final String? categoriaSeleccionada;

  const TodosProductosScreen({super.key, this.categoriaSeleccionada});

  @override
  State<TodosProductosScreen> createState() => _TodosProductosScreenState();
}

class _TodosProductosScreenState extends State<TodosProductosScreen> {
  final int _tab = 0;

  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _productoService.obtenerProductos();
  }

  Future<void> _refrescar() async {
    setState(() => _productosFuture = _productoService.obtenerProductos());
    try {
      await _productosFuture;
    } catch (_) {
      // el error ya se muestra en el FutureBuilder
    }
  }

  // Compara sin mayúsculas, espacios ni tildes
  static String _normalizar(String texto) {
    const mapa = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    var resultado = texto.trim().toLowerCase();
    mapa.forEach((k, v) => resultado = resultado.replaceAll(k, v));
    return resultado;
  }

  /// Coincidencia exacta con el tipo de calzado o con la categoría del producto.
  List<ProductoModel> _filtrar(List<ProductoModel> productos, String? filtro) {
    if (filtro == null || filtro.trim().isEmpty) return productos;
    final buscado = _normalizar(filtro);
    return productos.where((p) {
      return _normalizar(p.tipoCalzado ?? '') == buscado ||
          _normalizar(p.categoria) == buscado;
    }).toList();
  }

  String _formatearPrecio(double valor) {
    return valor
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  }

  void _onItemTapped(int index) {
    final Widget? pantalla = switch (index) {
      0 => const Home(),
      1 => const CarritoScreen(),
      2 => const FavoritosScreen(),
      3 => const PerfilScreen(),
      _ => null,
    };
    if (pantalla == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  void _abrirDetalle(ProductoModel producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProductoScreen(producto: producto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriaFiltro = widget.categoriaSeleccionada;
    final hayFiltro = categoriaFiltro != null && categoriaFiltro.isNotEmpty;

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
                  Expanded(
                    child: Text(
                      hayFiltro
                          ? categoriaFiltro.toUpperCase()
                          : 'TODAS LAS CATEGORÍAS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                hayFiltro ? categoriaFiltro : 'Dama, Caballero e Infantil',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refrescar,
                  child: FutureBuilder<List<ProductoModel>>(
                    future: _productosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _mensaje(
                          'No se pudieron cargar los productos.\nDesliza hacia abajo para reintentar.',
                        );
                      }

                      final productos = _filtrar(
                        snapshot.data ?? [],
                        categoriaFiltro,
                      );

                      if (productos.isEmpty) {
                        return _mensaje(
                          hayFiltro
                              ? 'No hay productos en "$categoriaFiltro".'
                              : 'Aún no hay productos publicados.',
                        );
                      }

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: productos.length,
                        itemBuilder: (context, index) =>
                            _tarjetaProducto(productos[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  // ListView para que el pull-to-refresh funcione también sin resultados
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

  Widget _tarjetaProducto(ProductoModel producto) {
    final imagen = producto.imagenPrincipal;
    final subtitulo = [
      if (producto.categoria.trim().isNotEmpty) producto.categoria.trim(),
      if ((producto.tipoCalzado ?? '').trim().isNotEmpty)
        producto.tipoCalzado!.trim(),
    ].join(' · ');

    return GestureDetector(
      onTap: () => _abrirDetalle(producto),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1.15,
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
              '\$${_formatearPrecio(producto.precio)}',
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
                // Abre el detalle para elegir talla y color antes de agregar
                onPressed: () => _abrirDetalle(producto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Ver detalle',
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