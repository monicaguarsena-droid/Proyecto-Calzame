import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/pantallas/compra.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/producto.dart';

// Modelo actualizado para incluir talla y color en los ítems del carrito
class ItemCarrito {
  final String imagen;
  final String titulo;
  final String subtitulo;
  final double precio;
  final String talla;
  final String color;
  int cantidad;

  ItemCarrito({
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
    required this.talla,
    required this.color,
    this.cantidad = 1,
  });
}

// Servicio estático para almacenar y gestionar los ítems del carrito en sesión
class CarritoService {
  static final List<ItemCarrito> itemsCarrito = [];

  static void agregarProducto({
    required String imagen,
    required String titulo,
    required String subtitulo,
    required String precioStr,
    String talla = 'Única',
    String color = 'Único',
  }) {
    // Limpiamos el string del precio
    double precio =
        double.tryParse(precioStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    // Verificamos si ya existe el producto con la misma talla y color para aumentar cantidad
    final index = itemsCarrito.indexWhere(
      (item) =>
          item.titulo == titulo && item.talla == talla && item.color == color,
    );

    if (index >= 0) {
      itemsCarrito[index].cantidad += 1;
    } else {
      itemsCarrito.add(
        ItemCarrito(
          imagen: imagen,
          titulo: titulo,
          subtitulo: subtitulo,
          precio: precio,
          talla: talla,
          color: color,
        ),
      );
    }
  }
}

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final int _tab = 1;
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
                child: CarritoService.itemsCarrito.isEmpty
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
                          return _tarjetaCarritoItem(item, index);
                        },
                      ),
              ),
              if (CarritoService.itemsCarrito.isNotEmpty) ...[
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

  Widget _tarjetaCarritoItem(ItemCarrito item, int index) {
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
                        setState(() {
                          CarritoService.itemsCarrito.removeAt(index);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (item.cantidad > 1) {
                                item.cantidad--;
                              } else {
                                CarritoService.itemsCarrito.removeAt(index);
                              }
                            });
                          },
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
                          onTap: () {
                            setState(() {
                              item.cantidad++;
                            });
                          },
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
                      items: CarritoService.itemsCarrito,
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
