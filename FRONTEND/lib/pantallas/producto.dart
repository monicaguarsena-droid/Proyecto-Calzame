import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/servicios/favoritos_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final String imagen;
  final String titulo;
  final String subtitulo;
  final String precio;

  const DetalleProductoScreen({
    super.key,
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  String tallaSeleccionada = '37';
  int colorSeleccionado = 0;
  int _tab = 0; // Pestaña activa por defecto
  bool esFavorito = false; // Estado para controlar si está en favoritos

  final List<Color> coloresDisponibles = [
    const Color(0xFFD4B299), // Beige
    const Color(0xFF2C2C2C), // Negro
    const Color(0xFFB87979), // Rosado/Café claro
  ];

  final List<String> nombresColores = ['Beige', 'Negro', 'Rosado'];

  @override
  void initState() {
    super.initState();
    // Verificamos si este producto ya está guardado en favoritos al abrir la pantalla
    esFavorito = FavoritosService.esFavorito(widget.titulo);
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
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

  void _toggleFavorito() {
    FavoritosService.toggleFavorito(
      imagen: widget.imagen,
      titulo: widget.titulo,
      subtitulo: widget.subtitulo,
      precio: widget.precio,
    );

    setState(() {
      esFavorito = FavoritosService.esFavorito(widget.titulo);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esFavorito
              ? '¡"${widget.titulo}" se agregó a favoritos!'
              : '¡"${widget.titulo}" se quitó de favoritos!',
        ),
        backgroundColor: esFavorito ? Colors.green : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detalle del producto",
          style: TextStyle(
            color: ColoresApp.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen con el botón de favoritos integrado
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColoresApp.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.imagen.startsWith('http')
                          ? Image.network(
                              widget.imagen,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: ColoresApp.surfaceVariant,
                                child: imagenCatalogoPlaceholder(iconSize: 50),
                              ),
                            )
                          : imagenCatalogoPlaceholder(iconSize: 50),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: _toggleFavorito,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          esFavorito ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            color: ColoresApp.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitulo,
                          style: const TextStyle(
                            color: ColoresApp.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.precio,
                    style: const TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Tallas disponibles",
                style: TextStyle(
                  color: ColoresApp.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['36', '37', '38', '39'].map((talla) {
                  bool esSeleccionada = tallaSeleccionada == talla;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tallaSeleccionada = talla;
                      });
                    },
                    child: Container(
                      width: 70,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: esSeleccionada
                            ? ColoresApp.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: esSeleccionada
                              ? ColoresApp.primary
                              : ColoresApp.border,
                        ),
                      ),
                      child: Text(
                        talla,
                        style: TextStyle(
                          color: esSeleccionada
                              ? Colors.white
                              : ColoresApp.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    "Color: ",
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    colorSeleccionado == 0
                        ? "Beige"
                        : (colorSeleccionado == 1 ? "Negro" : "Rosado"),
                    style: const TextStyle(
                      color: ColoresApp.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(coloresDisponibles.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        colorSeleccionado = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: coloresDisponibles[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorSeleccionado == index
                              ? ColoresApp.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                "Descripción",
                style: TextStyle(
                  color: ColoresApp.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Diseño exclusivo, materiales de alta calidad y máxima comodidad para acompañarte en tu día a día.",
                style: TextStyle(
                  color: ColoresApp.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // AQUÍ ENVIAMOS LA TALLA Y EL COLOR SELECCIONADOS POR EL USUARIO
                    CarritoService.agregarProducto(
                      imagen: widget.imagen,
                      titulo: widget.titulo,
                      subtitulo: widget.subtitulo,
                      precioStr: widget.precio,
                      talla: tallaSeleccionada,
                      color: nombresColores[colorSeleccionado],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "¡Producto agregado al carrito con éxito!",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Agregar al carrito",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(),
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
                    mainAxisSize: MainAxisSize.min, // Correcto: MainAxisSize
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
