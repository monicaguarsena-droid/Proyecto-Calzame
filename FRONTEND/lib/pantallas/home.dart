import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:frontend/api_config.dart';

/// Las imágenes pueden guardarse como URL completa o como ruta parcial de Cloudinary.
String _urlImagen(String? valor) {
  final url = (valor ?? '').trim();
  if (url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  final limpia = url.startsWith('/') ? url.substring(1) : url;
  if (limpia.startsWith('upload/')) {
    return 'https://res.cloudinary.com/vicsxzqj/$limpia';
  }
  return 'https://res.cloudinary.com/vicsxzqj/image/upload/$limpia';
}

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

    _inicializarNotificacionesFCM();
  }
  // Método para pedir permisos y obtener el token de notificaciones FCM
  Future<void> _inicializarNotificacionesFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      print('Token FCM del dispositivo: $token');

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final emailUsuario = prefs.getString('email');

        if (emailUsuario != null) {
          try {
            final response = await http.post(
              Uri.parse('${ApiConfig.baseUrl}/usuarios/actualizar-token'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': emailUsuario,
                'fcm_token': token,
              }),
            );
            if (response.statusCode == 200) {
              print('Token FCM vinculado al usuario en Supabase con éxito.');
            } else {
              print('Error del servidor al guardar token: ${response.body}');
            }
          } catch (e) {
            print('Excepción de red al enviar el token FCM: $e');
          }
        }
      }
    } else {
      print('El usuario denegó o no otorgó los permisos de notificación.');
    }
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
    _cargarNombreUsuario();
    setState(() {
      _ofertasFuture = OfertasService.listar().then((value) => value.cast());
      _tiposCalzadoFuture = CategoriaService.listar().then((value) => value.cast());
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
        child: const _Circ(Icons.favorite_border, size: 40, bg: Colors.white24, fg: Colors.white),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CarritoScreen()),
          );
        },
        child: const _Circ(Icons.shopping_bag_outlined, size: 40, bg: Colors.white24, fg: Colors.white),
      ),
    ],
  );

  Widget _tiposCalzado() {
    return FutureBuilder<List>(
      future: _tiposCalzadoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 104,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _mensajeCaja('No se pudieron cargar los tipos de calzado.');
        }
        final tipos = snapshot.data ?? [];
        if (tipos.isEmpty) {
          return _mensajeCaja('Aún no hay tipos de calzado registrados.');
        }
        return SizedBox(
          height: 104,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
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

  Widget _mensajeCaja(String texto) => Container(
    height: 104,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ColoresApp.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: ColoresApp.border),
    ),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 12, color: ColoresApp.textSecondary),
    ),
  );

  Widget _tipoCalzadoCard(dynamic item) {
    final tipo = Map<String, dynamic>.from(item as Map);
    final nombre = (tipo['nombre'] ?? tipo['titulo'] ?? '').toString();
    final descripcion = tipo['descripcion']?.toString() ?? '';
    final imagen = (tipo['imagen_url'] ?? tipo['imagen'] ?? '').toString();

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
                    productos[i].imagenPrincipal,
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
                  onPageChanged: (index) => setState(() => _paginaActual = index),
                  itemCount: _promociones.length,
                  itemBuilder: (context, index) {
                    final promo = _promociones[index];
                    final imagen = _urlImagen(promo['imagen_url']?.toString());
                    final tag = promo['tag']?.toString() ?? '';
                    final descuento = promo['descuento']?.toString() ?? '';
                    final descripcion = promo['descripcion']?.toString() ?? '';
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
                              colors: [Colors.black54, Colors.black26, Colors.black45],
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
                                tag.isEmpty ? 'OFERTA' : tag,
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
                              if (descuento.isNotEmpty)
                                Text(
                                  descuento,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              if (descripcion.isNotEmpty)
                                Text(
                                  descripcion,
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
                            color: _paginaActual == index ? Colors.white : Colors.white38,
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
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
  final Color bg, fg;
  final double size;
  const _Circ(this.icono, {required this.size, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: ColoresApp.surface, shape: BoxShape.circle),
    child: Icon(icono, size: size * 0.5, color: ColoresApp.primary),
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
        Icon(icono, size: 18, color: ColoresApp.primary),
        const Spacer(),
        Text(
          titulo,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ColoresApp.primary),
        ),
        Text(
          subtitulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: ColoresApp.textSecondary),
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
  Widget build(BuildContext context) {
    final url = _urlImagen(imagenUrl);
    return ClipRRect(
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
            if (url.isNotEmpty)
              Image.network(
                url,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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