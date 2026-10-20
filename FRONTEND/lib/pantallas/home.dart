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

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tab = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _header(),
            const SizedBox(height: 14),
            const _BannerAnimadoElegante(),
            _seccion(
              'Explora por persona',
              _fila(context, const [
                _Cat(Icons.woman_outlined, 'Dama', 'Zapatos y sandalias'),
                _Cat(Icons.child_care_outlined, 'Niña', 'Colecciones infantiles'),
                _Cat(Icons.man_outlined, 'Caballero', 'Estilo urbano y formal'),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoriaDama()),
                        );
                      },
                      child: const _CatConPlaya(
                        'Sandalias',
                        'Verano y playa',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoriaCaballero()),
                        );
                      },
                      child: const _CatConInvierno(
                        'Botas',
                        'Invierno y noche',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoriaInfantil()),
                        );
                      },
                      child: const _CatConZapato(
                        'Zapatillas',
                        'Deporte y diario',
                      ),
                    ),
                  ),
                ],
              ),
              verTodoOnTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodosProductosScreen()),
                );
              },
            ),
            _seccion(
              'Colecciones destacadas',
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetalleProductoScreen(
                              imagen: 'assets/img/botas.jpg',
                              titulo: 'Botas de cuero',
                              subtitulo: 'Diseño elegante para invierno',
                              precio: r'Desde $129',
                            ),
                          ),
                        );
                      },
                      child: const _Destacada(
                        'assets/img/botas.jpg',
                        'Botas de cuero',
                        'Diseño elegante para invierno',
                        r'Desde $129',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetalleProductoScreen(
                              imagen: 'assets/img/tacon.jpg',
                              titulo: 'Zapatillas urbanas',
                              subtitulo: 'Estilo cómodo para diario',
                              precio: r'Desde $89',
                            ),
                          ),
                        );
                      },
                      child: const _Destacada(
                        'assets/img/tacon.jpg',
                        'Zapatillas urbanas',
                        'Estilo cómodo para diario',
                        r'Desde $89',
                      ),
                    ),
                  ),
                ],
              ),
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
      bottomNavigationBar: _nav(),
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
              'CalzaMe',
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriaDama()));
              } else if (i == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriaInfantil()));
              } else if (i == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriaCaballero()));
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
                          fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w400,
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
  const _BannerAnimadoElegante();

  @override
  State<_BannerAnimadoElegante> createState() => _BannerAnimadoEleganteState();
}

class _BannerAnimadoEleganteState extends State<_BannerAnimadoElegante> {
  late PageController _pageController;
  int _paginaActual = 0;
  Timer? _timer;

  final List<Map<String, String>> _promociones = [
    {
      'tag': 'NUEVA COLECCIÓN',
      'titulo': 'Verano con estilo',
      'subtitulo': 'Hasta 30% de descuento',
      'detalle': 'En calzado de verano',
      'imagen': 'assets/img/verano.jpg',
    },
    {
      'tag': 'TENDENCIA DE NOCHE',
      'titulo': 'Elegancia & Confort',
      'subtitulo': 'Nuevos estilos de cuero',
      'detalle': 'Ideal para ocasiones especiales',
      'imagen': 'assets/img/invierno.jpg',
    },
    {
      'tag': 'URBANO & CASUAL',
      'titulo': 'Zapatillas Urbanas',
      'subtitulo': 'Diseño moderno para diario',
      'detalle': 'Máxima comodidad a cada paso',
      'imagen': 'assets/img/deporte.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _iniciarTimerAutomatico();
  }

  void _iniciarTimerAutomatico() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_paginaActual < _promociones.length - 1) {
        _paginaActual++;
      } else {
        _paginaActual = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _paginaActual,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 135,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _paginaActual = index;
                });
              },
              itemCount: _promociones.length,
              itemBuilder: (context, index) {
                final promo = _promociones[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      promo['imagen']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
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
                            promo['tag']!,
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            promo['titulo']!,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['subtitulo']!,
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                              Text(
                                promo['detalle']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
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
  }
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

class _CatConPlaya extends StatelessWidget {
  final String titulo, subtitulo;
  const _CatConPlaya(this.titulo, this.subtitulo);

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: const DecorationImage(
        image: AssetImage('assets/img/playa.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.90),
            Colors.black.withOpacity(0.40),
            Colors.transparent,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
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
            child: const Icon(Icons.sunny, size: 16, color: Colors.white),
          ),
          const Spacer(),
          Text(
            titulo,
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
  );
}

class _CatConInvierno extends StatelessWidget {
  final String titulo, subtitulo;
  const _CatConInvierno(this.titulo, this.subtitulo);

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: const DecorationImage(
        image: AssetImage('assets/img/invierno.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.90),
            Colors.black.withOpacity(0.40),
            Colors.transparent,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
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
            child: const Icon(Icons.ac_unit, size: 16, color: Colors.white),
          ),
          const Spacer(),
          Text(
            titulo,
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
  );
}

class _CatConZapato extends StatelessWidget {
  final String titulo, subtitulo;
  const _CatConZapato(this.titulo, this.subtitulo);

  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: const DecorationImage(
        image: AssetImage('assets/img/deporte.jpg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.90),
            Colors.black.withOpacity(0.40),
            Colors.transparent,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
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
            child: const Icon(Icons.sports_basketball_outlined, size: 16, color: Colors.white),
          ),
          const Spacer(),
          Text(
            titulo,
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
  );
}

class _Destacada extends StatelessWidget {
  final String asset, titulo, subtitulo, precio;
  const _Destacada(this.asset, this.titulo, this.subtitulo, this.precio);

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: 170,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColoresApp.primaryLight, ColoresApp.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
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