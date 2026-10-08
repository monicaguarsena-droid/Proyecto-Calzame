import 'package:flutter/material.dart';

class DetalleProductoScreen extends StatefulWidget {
  const DetalleProductoScreen({super.key});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  String tallaSeleccionada = '37';
  int colorSeleccionado = 0; // 0: Beige, 1: Negro, 2: Rosado

  final List<Color> coloresDisponibles = [
    const Color(0xFFD4B299), // Beige
    const Color(0xFF2C2C2C), // Negro
    const Color(0xFFB87979), // Rosado/Café claro
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7), // Fondo crema claro característico
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A1525)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "producto",
          style: TextStyle(
            color: Color(0xFF4A1525),
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
              // Contenedor principal de la imagen del producto
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/img/botas.jpg', // Asegúrate de que la ruta de la imagen sea correcta en tu proyecto
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Fila de Título y Precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Sandalia de tiras",
                        style: TextStyle(
                          color: Color(0xFF4A1525),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Cuero suave - Tono beige",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "\$129",
                    style: TextStyle(
                      color: Color(0xFF4A1525),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Selector de Tallas Disponibles
              const Text(
                "Tallas disponibles",
                style: TextStyle(
                  color: Color(0xFF4A1525),
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
                        color: esSeleccionada ? const Color(0xFF4A1525) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: esSeleccionada ? const Color(0xFF4A1525) : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        talla,
                        style: TextStyle(
                          color: esSeleccionada ? Colors.white : const Color(0xFF4A1525),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Selector de Color
              Row(
                children: [
                  const Text(
                    "Color: ",
                    style: TextStyle(
                      color: Color(0xFF4A1525),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    colorSeleccionado == 0 ? "Beige" : (colorSeleccionado == 1 ? "Negro" : "Rosado"),
                    style: const TextStyle(
                      color: Colors.grey,
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
                          color: colorSeleccionado == index ? const Color(0xFF4A1525) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Descripción del Producto
              const Text(
                "Descripción",
                style: TextStyle(
                  color: Color(0xFF4A1525),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tiras delicadas y un tacón elegante para acompañarte en cada ocasión.\nCuero suave · Plantilla acolchada · Suela sintética",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // Botón de acción (Agregar al carrito)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Producto agregado al carrito con éxito!"),
                        backgroundColor: Color(0xFF4A1525),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A1525),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
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
      // Barra de navegación inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(Icons.home_outlined, "Inicio", false),
            _buildNavIcon(Icons.search, "Buscar", false),
            _buildNavIcon(Icons.favorite_border, "Favoritos", false),
            _buildNavIcon(Icons.person_outline, "Cuenta", false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4A1525) : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4A1525) : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}