import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/categoriacaballero.dart';
import 'package:frontend/pantallas/categoriadama.dart';
import 'package:frontend/pantallas/categoriainfantil.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/pantallas/todos_productos.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/categorias_service.dart';
import 'package:frontend/servicios/producto_service.dart';
import 'package:frontend/servicios/ofertas_service.dart';
import 'package:frontend/componentes/chat/chat_calzame_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _tab = 0;
  String _nombreUsuario = '';
  
  final ProductoService _productoService = ProductoService();
  late Future<List> _ofertasFuture;
  late Future<List> _tiposCalzadoFuture;
  late Future<List<ProductoModel>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
    _ofertasFuture = OfertasService.listar().then((value) => value.cast());
    _tiposCalzadoFuture = CategoriaService.listar().then((value) => value.cast());
    _productosFuture = _productoService.obtenerProductos();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('nombre') ?? 'Cliente';
    });
  }

  void _abrirAsistenteIA(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatCalzameModal(),
    );
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
      _cargarNombreUsuario();
      _ofertasFuture = OfertasService.listar().then((value) => value.cast());
      _tiposCalzadoFuture = CategoriaService.listar().then((value) => value.cast());
      _productosFuture = _productoService.obtenerProductos();
    });
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
                  _Cat(Icons.man_outlined, 'Caballeros', 'Estilo urbano y formal'),
                  _Cat(Icons.child_care_outlined, 'Niñas', 'Colecciones infantiles'),
                ]),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodosProductosScreen()),
                  );
                },
              ),
              _seccion(
                'Tipos de calzado',
                _tiposCalzado(),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodosProductosScreen()),
                  );
                },
              ),
              _seccion(
                'Colecciones destacadas',
                _coleccionesDestacadas(),
                verTodoOnTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodosProductosScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirAsistenteIA(context),
        backgroundColor: ColoresApp.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.support_agent_rounded, size: 22),
        label: const Text(
          'Asistente IA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, $_nombreUsuario!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ColoresApp.primary,
              ),
            ),
            const Text(
              'Mar&Paz - Colecciones para toda la familia',
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

  Widget _tiposCalzado() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tiposCalzadoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 104, child: Center(child: CircularProgressIndicator()));
        }
        final tipos = snapshot.data ?? [];
        final mostrados = tipos.isEmpty ? [] : tipos;
        return SizedBox(
          height: 104,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tipos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 10),
                child: _tipoCalzadoCard(tipos[index]),
              );
            },
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
        MaterialPageRoute(
          builder: (context) => TodosProductosScreen(categoriaSeleccionada: nombre),
        ),
      ),
      child: _TipoCalzadoCard(titulo: nombre, subtitulo: descripcion, imagenUrl: imagen),
    );
  }

  Widget _coleccionesDestacadas() {
    return FutureBuilder<List<ProductoModel>>(
      future: _productosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 170, child: Center(child: CircularProgressIndicator()));
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleProductoScreen(producto: productos[i]),
                      ),
                    );
                  },
                  child: _Destacada(
                    productos[i].imagenes.isNotEmpty ? productos[i].imagenes.first : '', // 📸 Primera imagen de la lista
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

  Widget _seccion(String titulo, Widget hijo, {required VoidCallback verTodoOnTap}) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ColoresApp.primary),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriaDama()));
              } else if (i == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriaCaballero()));
              } else if (i == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriaInfantil()));
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
                        color: _tab == i ? ColoresApp.primary : ColoresApp.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400,
                          color: _tab == i ? ColoresApp.primary : ColoresApp.textSecondary,
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
  final Future<List> ofertasFuture;

  const _BannerAnimadoElegante({required this.ofertasFuture});
  @override
  State<_BannerAnimadoElegante> createState() => _BannerAnimadoEleganteState();
}

class _BannerAnimadoEleganteState extends State<_BannerAnimadoElegante> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  Timer? _timer;
  List _promociones = [];

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
    return FutureBuilder<List>(
      future: widget.ofertasFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || (snapshot.data ?? []).isEmpty) {
          return Container(height: 165, decoration: BoxDecoration(color: ColoresApp.primary, borderRadius: BorderRadius.circular(24)));
        }
        _promociones = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 165,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _promociones.length,
              itemBuilder: (context, index) {
                final promo = _promociones[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(promo['imagen_url'] ?? '', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: ColoresApp.primary)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(promo['titulo'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Circ extends StatelessWidget {
  final IconData icono;
  final double size;
  const _Circ(this.icono, {required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: const BoxDecoration(color: ColoresApp.surface, shape: BoxShape.circle), child: Icon(icono, size: size * 0.5, color: ColoresApp.primary));
}

class _Cat extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  const _Cat(this.icono, this.titulo, this.subtitulo);
  @override
  Widget build(BuildContext context) => Container(
    height: 104, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: ColoresApp.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: ColoresApp.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icono, size: 18, color: ColoresApp.primary),
      const Spacer(),
      Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ColoresApp.primary)),
      Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: ColoresApp.textSecondary)),
    ]),
  );
}

class _TipoCalzadoCard extends StatelessWidget {
  final String titulo, subtitulo, imagenUrl;
  const _TipoCalzadoCard({required this.titulo, required this.subtitulo, required this.imagenUrl});
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: ColoresApp.primary, borderRadius: BorderRadius.circular(16)));
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