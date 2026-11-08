import 'package:flutter/material.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/servicios/favoritos_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final ProductoModel producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  late String tallaSeleccionada;
  late String imagenActual;
  int colorSeleccionadoIndex = 0;
  bool _agregandoAlCarrito = false;
  bool _esFavorito = false;

  List<ProductoColorImagen> get _colores => widget.producto.colores;

  List<String> get _tallas => widget.producto.tallas.isNotEmpty
      ? widget.producto.tallas
      : const ['Única'];

  String get _colorSeleccionado =>
      _colores.isNotEmpty ? _colores[colorSeleccionadoIndex].color : 'Único';

  @override
  void initState() {
    super.initState();
    tallaSeleccionada = _tallas.first;
    _cargarFavorito();

    // Si el primer color tiene foto propia la usamos; si no, la imagen principal
    if (_colores.isNotEmpty && _colores.first.imagenUrl.isNotEmpty) {
      imagenActual = _colores.first.imagenUrl;
    } else {
      imagenActual = widget.producto.imagenes.isNotEmpty
          ? widget.producto.imagenes.first
          : '';
    }
  }

  Future<void> _cargarFavorito() async {
    final favorito = await FavoritosService.esFavorito(widget.producto.id);
    if (mounted) setState(() => _esFavorito = favorito);
  }

  Future<void> _alternarFavorito() async {
    final ahoraEsFavorito = await FavoritosService.alternar(widget.producto.id);
    if (!mounted) return;
    setState(() => _esFavorito = ahoraEsFavorito);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ahoraEsFavorito ? 'Agregado a favoritos' : 'Quitado de favoritos',
          ),
          backgroundColor: ColoresApp.primary,
          duration: const Duration(seconds: 5),
          persist: false, // se cierra solo, sin esperar a que el usuario lo toque
        ),
      );
  }

  Future<void> _agregarAlCarrito() async {
    if (_agregandoAlCarrito) return;
    setState(() => _agregandoAlCarrito = true);
    try {
      await CarritoService.agregarProducto(
        productoId: widget.producto.id,
        imagen: imagenActual,
        titulo: widget.producto.nombre,
        subtitulo: widget.producto.descripcion,
        precioStr: widget.producto.precio.toString(),
        talla: tallaSeleccionada,
        color: _colorSeleccionado,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Producto agregado al carrito'),
          backgroundColor: ColoresApp.primary,
          action: SnackBarAction(
            label: 'VER CARRITO',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CarritoScreen()),
              );
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: ColoresApp.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _agregandoAlCarrito = false);
    }
  }

  void _navegar(int indice) {
    final Widget pantalla = switch (indice) {
      0 => const Home(),
      1 => const CarritoScreen(),
      2 => const FavoritosScreen(),
      3 => const PerfilScreen(),
      _ => const Home(),
    };
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  String _formatearPrecio(double valor) {
    final entero = valor.toStringAsFixed(0);
    return entero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
  }

  Color _colorMuestra(String nombre) {
    final normalizado = nombre.toLowerCase();
    const coloresPorNombre = <String, Color>{
      'beige': Color(0xFFC9A982),
      'crema': Color(0xFFE8D6B8),
      'nude': Color(0xFFC99F7A),
      'marron': Color(0xFF795548),
      'marrón': Color(0xFF795548),
      'cafe': Color(0xFF795548),
      'café': Color(0xFF795548),
      'chocolate': Color(0xFF4E342E),
      'negro': Color(0xFF2D2928),
      'blanco': Color(0xFFFFFFFF),
      'rojo': Color(0xFFB63B3B),
      'vino': Color(0xFF741A35),
      'burdeos': Color(0xFF741A35),
      'azul': Color(0xFF3F6695),
      'celeste': Color(0xFF8BBED0),
      'verde': Color(0xFF4D7656),
      'oliva': Color(0xFF7B8050),
      'rosa': Color(0xFFC7858E),
      'rosado': Color(0xFFC7858E),
      'gris': Color(0xFF888888),
      'plata': Color(0xFFBFC2C5),
      'dorado': Color(0xFFC6A04A),
      'amarillo': Color(0xFFE0C34D),
      'naranja': Color(0xFFD68042),
    };
    for (final entry in coloresPorNombre.entries) {
      if (normalizado.contains(entry.key)) return entry.value;
    }
    if (RegExp(r'^#?([0-9a-f]{6})$').hasMatch(normalizado.trim())) {
      return Color(
        int.parse(normalizado.trim().replaceFirst('#', ''), radix: 16) +
            0xFF000000,
      );
    }
    final tono = (normalizado.hashCode & 0x7fffffff) % 360;
    return HSLColor.fromAHSL(1, tono.toDouble(), 0.45, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    // Categoría · Tipo de calzado · Tono del color (como en el mockup)
    final subtitulo = [
      if (producto.categoria.trim().isNotEmpty) producto.categoria.trim(),
      if ((producto.tipoCalzado ?? '').trim().isNotEmpty)
        producto.tipoCalzado!.trim(),
      if (_colores.isNotEmpty) 'Tono $_colorSeleccionado',
    ].join(' · ');

    // Descripción: primera línea como texto y el resto como características
    final lineasDescripcion = producto.descripcion
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Volver',
                          icon: const Icon(
                            Icons.arrow_back,
                            color: ColoresApp.primary,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Text(
                      'PRODUCTOS',
                      style: TextStyle(
                        color: ColoresApp.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto (cambia según el color elegido)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColoresApp.border),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 1.45,
                              child: imagenActual.isNotEmpty
                                  ? Image.network(
                                      imagenActual,
                                      key: ValueKey(imagenActual),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, _, _) =>
                                          imagenCatalogoPlaceholder(
                                              iconSize: 50),
                                    )
                                  : imagenCatalogoPlaceholder(iconSize: 50),
                            ),
                          ),
                          // Corazón de favoritos
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _botonFavorito(),
                          ),
                        ],
                      ),
                    ),
                    // Miniaturas: fotos extra del producto cuando no hay colores
                    if (_colores.isEmpty && producto.imagenes.length > 1) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: producto.imagenes.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final url = producto.imagenes[i];
                            final activa = url == imagenActual;
                            return GestureDetector(
                              onTap: () => setState(() => imagenActual = url),
                              child: Container(
                                width: 64,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: activa
                                        ? ColoresApp.primary
                                        : ColoresApp.border,
                                    width: activa ? 1.5 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        imagenCatalogoPlaceholder(iconSize: 20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Nombre y precio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            producto.nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: ColoresApp.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${_formatearPrecio(producto.precio)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: ColoresApp.primary,
                          ),
                        ),
                      ],
                    ),

                    // Categoría · Tipo de calzado · Tono
                    if (subtitulo.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Tallas
                    const Text(
                      'Tallas disponibles',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: ColoresApp.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tallas.map(_chipTalla).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Color
                    Row(
                      children: [
                        const Text(
                          'Color',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: ColoresApp.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _colorSeleccionado,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColoresApp.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (_colores.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: List.generate(_colores.length, _muestraColor),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Descripción
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: ColoresApp.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (lineasDescripcion.isEmpty)
                      const Text(
                        'Sin descripción',
                        style: TextStyle(
                          fontSize: 13,
                          color: ColoresApp.textSecondary,
                        ),
                      )
                    else ...[
                      Text(
                        lineasDescripcion.first,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                      if (lineasDescripcion.length > 1) ...[
                        const SizedBox(height: 8),
                        Text(
                          lineasDescripcion.skip(1).join(' · '),
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: ColoresApp.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _agregandoAlCarrito ? null : _agregarAlCarrito,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _agregandoAlCarrito
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Agregar al carrito',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            _barraNavegacion(),
          ],
        ),
      ),
    );
  }

  Widget _botonFavorito() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _alternarFavorito,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            _esFavorito ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: ColoresApp.primary,
          ),
        ),
      ),
    );
  }

  Widget _chipTalla(String talla) {
    final seleccionada = tallaSeleccionada == talla;
    return GestureDetector(
      onTap: () => setState(() => tallaSeleccionada = talla),
      child: Container(
        width: 76,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionada ? ColoresApp.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionada ? ColoresApp.primary : ColoresApp.border,
          ),
        ),
        child: Text(
          talla,
          style: TextStyle(
            fontSize: 14,
            color: seleccionada ? Colors.white : ColoresApp.primary,
            fontWeight: seleccionada ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _muestraColor(int index) {
    final colorItem = _colores[index];
    final seleccionado = colorSeleccionadoIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          colorSeleccionadoIndex = index;
          // Cambia la foto al elegir el color
          if (colorItem.imagenUrl.isNotEmpty) {
            imagenActual = colorItem.imagenUrl;
          }
        });
      },
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: seleccionado ? ColoresApp.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _colorMuestra(colorItem.color),
            border: Border.all(
              color: colorItem.color.toLowerCase() == 'blanco'
                  ? ColoresApp.border
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _barraNavegacion() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Inicio'),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Carrito'),
      (Icons.favorite_border, Icons.favorite, 'Favoritos'),
      (Icons.person_outline, Icons.person, 'Cuenta'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresApp.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navegar(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      index == 0 ? items[index].$2 : items[index].$1,
                      size: 21,
                      color: index == 0
                          ? ColoresApp.primary
                          : ColoresApp.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[index].$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            index == 0 ? FontWeight.w700 : FontWeight.w400,
                        color: index == 0
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
    );
  }
}