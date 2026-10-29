import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/pantallas/compra.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/servicios/carrito_service.dart';

export 'package:frontend/servicios/carrito_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final int _tab = 1;
  bool _cargando = true;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      await CarritoService.cargarCarrito();
      if (mounted) setState(() => _cargando = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _errorCarga = error.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _eliminarItem(ItemCarrito item) async {
    try {
      await CarritoService.eliminar(item);
      if (mounted) setState(() {});
    } catch (error) {
      _mostrarError(error);
    }
  }

  Future<void> _cambiarCantidad(ItemCarrito item, int cantidad) async {
    if (cantidad < 1) {
      await _eliminarItem(item);
      return;
    }
    try {
      await CarritoService.actualizarCantidad(item, cantidad);
      if (mounted) setState(() {});
    } catch (error) {
      _mostrarError(error);
    }
  }

  void _mostrarError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _tab) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
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

  double get _totalGeneral {
    return CarritoService.itemsCarrito.fold(
      0,
      (sum, item) => sum + (item.precio * item.cantidad),
    );
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
              _header(context),
              const SizedBox(height: 16),
              _subHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _errorCarga != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorCarga!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ColoresApp.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _cargarCarrito,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : CarritoService.itemsCarrito.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: ColoresApp.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tu carrito está vacío',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Agrega productos desde el inicio, categorías o favoritos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: CarritoService.itemsCarrito.length,
                        itemBuilder: (context, index) {
                          final item = CarritoService.itemsCarrito[index];
                          return _tarjetaCarritoItem(item);
                        },
                      ),
              ),
              if (!_cargando &&
                  _errorCarga == null &&
                  CarritoService.itemsCarrito.isNotEmpty) ...[
                const SizedBox(height: 12),
                _seccionResumen(),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
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
          'CARRITO DE COMPRAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ColoresApp.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _subHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Productos agregados',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ColoresApp.primary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ColoresApp.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${CarritoService.itemsCarrito.length} items',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ColoresApp.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaCarritoItem(ItemCarrito item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleProductoScreen(
                  productoId: item.productoId,
                  imagen: item.imagen,
                  titulo: item.titulo,
                  subtitulo: item.subtitulo,
                  precio: '\$${item.precio.toStringAsFixed(0)}',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: item.imagen.startsWith('http')
                      ? Image.network(
                          item.imagen,
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 85,
                            height: 85,
                            color: ColoresApp.surfaceVariant,
                            child: imagenCatalogoPlaceholder(
                              width: 85,
                              height: 85,
                            ),
                          ),
                        )
                      : imagenCatalogoPlaceholder(width: 85, height: 85),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColoresApp.primary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Talla: ${item.talla}  |  Color: ${item.color}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${(item.precio * item.cantidad).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: ColoresApp.error,
                      ),
                      onPressed: () {
                        _eliminarItem(item);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              _cambiarCantidad(item, item.cantidad - 1),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColoresApp.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.remove, size: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.cantidad}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              _cambiarCantidad(item, item.cantidad + 1),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColoresApp.border),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add, size: 13),
                          ),
                        ),
                      ],
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

  Widget _seccionResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColoresApp.textSecondary,
                ),
              ),
              Text(
                '\$${_totalGeneral.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (CarritoService.itemsCarrito.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompraScreen(
                      items: List.of(CarritoService.itemsCarrito),
                      total: _totalGeneral,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceder al pago',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
