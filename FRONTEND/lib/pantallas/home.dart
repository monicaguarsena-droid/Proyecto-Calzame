import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tab = 0;

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
            _banner(),
            _seccion(
              'Explora por persona',
              _fila(const [
                _Cat(Icons.person_outline, 'Dama', 'Zapatos y sandalias'),
                _Cat(Icons.person_outline, 'Niña', 'Colecciones infantiles'),
                _Cat(
                  Icons.person_outline,
                  'Caballero',
                  'Estilo urbano y formal',
                ),
              ]),
            ),
            _seccion(
              'Tipos de calzado',
              _fila(const [
                _Cat(Icons.directions_walk, 'Sandalias', 'Verano y playa'),
                _Cat(Icons.directions_walk, 'Botas', 'Invierno y noche'),
                _Cat(Icons.directions_walk, 'Zapatillas', 'Deporte y diario'),
              ]),
            ),
            _seccion(
              'Colecciones destacadas',
              _fila(const [
                _Destacada(
                  'assets/img/botas.jpg',
                  'Botas de cuero',
                  'Diseño elegante para invierno',
                  r'Desde $129',
                ),
                _Destacada(
                  'assets/img/tacon.jpg',
                  'Zapatillas urbanas',
                  'Estilo cómodo para diario',
                  r'Desde $89',
                ),
              ]),
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
      const _Circ(Icons.search, size: 40),
      const SizedBox(width: 8),
      const _Circ(Icons.shopping_bag_outlined, size: 40),
    ],
  );

  Widget _banner() => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      height: 130,
      child: _Foto(
        'assets/img/banner.jpg',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NUEVA COLECCIÓN',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Verano con estilo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasta 30% de descuento',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        Text(
                          'En calzado de verano',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Circ(
                    Icons.chevron_left,
                    size: 26,
                    bg: Colors.white24,
                    fg: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  _Circ(
                    Icons.chevron_right,
                    size: 26,
                    bg: Colors.white24,
                    fg: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _seccion(String titulo, Widget hijo) => Padding(
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
            const Text(
              'Ver todo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ColoresApp.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        hijo,
      ],
    ),
  );

  Widget _fila(List<Widget> items) => Row(
    children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(child: items[i]),
      ],
    ],
  );

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
                  onTap: () => setState(() => _tab = i),
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

/// Imagen de fondo con degradado oscuro; si no existe el asset, muestra un degradado vino.
class _Foto extends StatelessWidget {
  final String asset;
  final Widget child;
  const _Foto(this.asset, {required this.child});

  @override
  Widget build(BuildContext context) => Stack(
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
      child,
    ],
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
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: ColoresApp.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icono, size: 17, color: ColoresApp.primary),
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

/// Tarjeta de colección destacada.
class _Destacada extends StatelessWidget {
  final String asset, titulo, subtitulo, precio;
  const _Destacada(this.asset, this.titulo, this.subtitulo, this.precio);

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      height: 170,
      child: _Foto(
        asset,
        child: Padding(
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
      ),
    ),
  );
}
