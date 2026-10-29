import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/categoriacaballero.dart';
import 'package:frontend/pantallas/categoriadama.dart';
import 'package:frontend/pantallas/categoriainfantil.dart';
import 'package:frontend/pantallas/todos_productos.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/catalogo_visual_service.dart';
import 'package:frontend/servicios/producto_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tab = 0;
  final ProductoService _productoService = ProductoService();
  late Future<List<Map<String, dynamic>>> _ofertasFuture;
  late Future<List<Map<String, dynamic>>> _tiposCalzadoFuture;
  late Future<List<ProductoModel>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _ofertasFuture = CatalogoVisualService.listar('ofertas');
    _tiposCalzadoFuture = CatalogoVisualService.listar('tipos-calzado');
    _productosFuture = _productoService.obtenerProductos();
  }

  void _onItemTapped(int index) {
    if (index == _tab) return;

    if (index == 1) {
      Navigator.push(
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

  Future<void> _actualizarCatalogo() async {
    setState(() {
      _ofertasFuture = CatalogoVisualService.listar('ofertas');
      _tiposCalzadoFuture = CatalogoVisualService.listar('tipos-calzado');
      _productosFuture = _productoService.obtenerProductos();
    });
    try {
      await Future.wait([
        _ofertasFuture,
        _tiposCalzadoFuture,
        _productosFuture,
      ]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el catálogo: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _actualizarCatalogo,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _header(),
              const SizedBox(height: 14),
              _BannerAnimadoElegante(ofertasFuture: _ofertasFuture),
              _seccion(
                'Escoge tu Categoría',
                _fila(context, const [
                  _Cat(Icons.woman_outlined, 'Damas', 'Zapatos y sandalias'),
                  _Cat(
                    Icons.man_outlined,
                    'Caballeros',
                    'Estilo urbano y formal',
                  ),
                  _Cat(
                    Icons.child_care_outlined,
                    'Niñas',
                    'Colecciones infantiles',
                  ),
                ]),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodosProductosScreen(),
                    ),
                  );
                },
              ),
              _seccion(
                'Tipos de calzado',
                _tiposCalzado(),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodosProductosScreen(),
                    ),
                  );
                },
              ),
              _seccion(
                'Colecciones destacadas',
                _coleccionesDestacadas(),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodosProductosScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _tiposCalzado() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tiposCalzadoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 104,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            height: 104,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColoresApp.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColoresApp.border),
            ),
            child: const Text('No se pudieron cargar los tipos de calzado.'),
          );
        }
        final tipos = snapshot.data ?? [];
        final mostrados = tipos.isEmpty
            ? [
                {'nombre': 'Sandalias', 'descripcion': 'Verano y playa'},
                {'nombre': 'Botas', 'descripcion': 'Invierno y noche'},
                {'nombre': 'Zapatillas', 'descripcion': 'Deporte y diario'},
              ]
            : tipos;
        if (mostrados.length <= 3) {
          return Row(
            children: [
              for (var i = 0; i < mostrados.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _tipoCalzadoCard(mostrados[i])),
              ],
            ],
          );
        }
        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mostrados.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.39,
              child: _tipoCalzadoCard(mostrados[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _tipoCalzadoCard(Map<String, dynamic> tipo) {
    final nombre = tipo['nombre']?.toString() ?? '';
    final descripcion = tipo['descripcion']?.toString() ?? '';
    final imagen = tipo['imagen_url']?.toString() ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TodosProductosScreen()),
      ),
      child: _TipoCalzadoCard(
        titulo: nombre,
        subtitulo: descripcion,
        imagenUrl: imagen,
      ),
    );
  }

  Widget _coleccionesDestacadas() {
    return FutureBuilder<List<ProductoModel>>(
      future: _productosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('No se pudieron cargar los productos: ${snapshot.error}');
        }
        final productos = (snapshot.data ?? []).take(2).toList();
        if (productos.isEmpty) {
          return const Row(
            children: [
              Expanded(
                child: _Destacada(
                  '',
                  'Aún no hay productos',
                  'Las nuevas colecciones aparecerán aquí',
                  '',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _Destacada(
                  '',
                  'Explora el catálogo',
                  'Consulta los productos por categoría',
                  '',
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < productos.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final producto = productos[i];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleProductoScreen(
                          productoId: producto.id,
                          imagen: producto.imagenUrl ?? '',
                          titulo: producto.nombre,
                          subtitulo: producto.descripcion,
                          precio: '\$${producto.precio.toStringAsFixed(0)}',
                        ),
                      ),
                    );
                  },
                  child: _Destacada(
                    productos[i].imagenUrl ?? '',
                    productos[i].nombre,
                    productos[i].descripcion,
                    '\$${productos[i].precio.toStringAsFixed(0)}',
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mar&Paz',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: ColoresApp.primary,
              ),
            ),
            Text(
              'Colecciones para toda la familia',
              style: TextStyle(fontSize: 12, color: ColoresApp.textSecondary),
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritosScreen()),
          );
        },
        child: const _Circ(Icons.favorite_border, size: 40),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CarritoScreen()),
          );
        },
        child: const _Circ(Icons.shopping_bag_outlined, size: 40),
      ),
    ],
  );

  Widget _seccion(
    String titulo,
    Widget hijo, {
    required VoidCallback verTodoOnTap,
  }) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                ),
              ),
            ),
            GestureDetector(
              onTap: verTodoOnTap,
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        hijo,
      ],
    ),
  );

  Widget _fila(BuildContext context, List<Widget> items) => Row(
    children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (i == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriaDama(),
                  ),
                );
              } else if (i == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriaCaballero()),
                );
              } else if (i == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriaInfantil()),
                );
              }
            },
            child: items[i],
          ),
        ),
      ],
    ],
  );

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

class _BannerAnimadoElegante extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ofertasFuture;

  const _BannerAnimadoElegante({required this.ofertasFuture});

  @override
  State<_BannerAnimadoElegante> createState() => _BannerAnimadoEleganteState();
}

class _BannerAnimadoEleganteState extends State<_BannerAnimadoElegante> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _promociones = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_promociones.length < 2 || !_pageController.hasClients) return;
      _paginaActual = (_paginaActual + 1) % _promociones.length;
      _pageController.animateToPage(
        _paginaActual,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.ofertasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _bannerVacio('Cargando ofertas...');
        }
        if (snapshot.hasError) {
          return _bannerVacio('No se pudieron cargar las ofertas');
        }
        _promociones = snapshot.data ?? [];
        if (_promociones.isEmpty) {
          return _bannerVacio('Las nuevas ofertas aparecerán aquí');
        }
        if (_paginaActual >= _promociones.length) {
          _paginaActual = 0;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 165,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _paginaActual = index),
                  itemCount: _promociones.length,
                  itemBuilder: (context, index) {
                    final promo = _promociones[index];
                    final imagen = promo['imagen_url']?.toString() ?? '';
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imagen.isNotEmpty)
                          Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fondoBanner(),
                          )
                        else
                          _fondoBanner(),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black54,
                                Colors.black26,
                                Colors.black45,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['tag']?.toString() ?? 'OFERTA',
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                promo['titulo']?.toString() ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                promo['descuento']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                promo['descripcion']?.toString() ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_promociones.length > 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(
                        _promociones.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(left: 5),
                          height: 6,
                          width: _paginaActual == index ? 18 : 6,
                          decoration: BoxDecoration(
                            color: _paginaActual == index
                                ? Colors.white
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bannerVacio(String mensaje) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Container(
      height: 165,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        mensaje,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _fondoBanner() => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );
}

class _Circ extends StatelessWidget {
  final IconData icono;
  final double size;
  final Color bg, fg;
  const _Circ(
    this.icono, {
    required this.size,
    this.bg = ColoresApp.surface,
    this.fg = ColoresApp.primary,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: Icon(icono, size: size * 0.5, color: fg),
  );
}

class _Cat extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  const _Cat(this.icono, this.titulo, this.subtitulo);

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ColoresApp.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ColoresApp.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ColoresApp.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, size: 18, color: ColoresApp.primary),
        ),
        const Spacer(),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ColoresApp.primary,
          ),
        ),
        Text(
          subtitulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            height: 1.2,
            color: ColoresApp.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _TipoCalzadoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String imagenUrl;

  const _TipoCalzadoCard({
    required this.titulo,
    required this.subtitulo,
    required this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 104,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagenUrl.isNotEmpty)
            Image.network(
              imagenUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.black38, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Destacada extends StatelessWidget {
  final String imagenUrl, titulo, subtitulo, precio;
  const _Destacada(this.imagenUrl, this.titulo, this.subtitulo, this.precio);

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (imagenUrl.isNotEmpty)
            Image.network(
              imagenUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.black26, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        precio,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const _Circ(
                      Icons.arrow_forward,
                      size: 28,
                      bg: Colors.white24,
                      fg: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
