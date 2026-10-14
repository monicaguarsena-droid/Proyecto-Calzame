import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/carrito.dart';

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

  final List<Color> coloresDisponibles = [
    const Color(0xFFD4B299), // Beige
    const Color(0xFF2C2C2C), // Negro
    const Color(0xFFB87979), // Rosado/Café claro
  ];

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
                  child: Image.asset(
                    widget.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ColoresApp.surfaceVariant,
                      child: const Icon(Icons.image_not_supported, size: 50, color: ColoresApp.textSecondary),
                    ),
                  ),
                ),
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
                        color: esSeleccionada ? ColoresApp.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: esSeleccionada ? ColoresApp.primary : ColoresApp.border,
                        ),
                      ),
                      child: Text(
                        talla,
                        style: TextStyle(
                          color: esSeleccionada ? Colors.white : ColoresApp.primary,
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
                    colorSeleccionado == 0 ? "Beige" : (colorSeleccionado == 1 ? "Negro" : "Rosado"),
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
                          color: colorSeleccionado == index ? ColoresApp.primary : Colors.transparent,
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
                    CarritoService.agregarProducto(
                      imagen: widget.imagen,
                      titulo: widget.titulo,
                      subtitulo: widget.subtitulo,
                      precioStr: widget.precio,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Producto agregado al carrito con éxito!"),
                        backgroundColor: ColoresApp.primary,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}