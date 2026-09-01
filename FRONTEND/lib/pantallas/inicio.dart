import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F2), // Fondo 
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen del tacón.jpg
              Image.asset(
                'assets/img/tacon.jpg', 
                height: 180,
              ),
              const SizedBox(height: 20),

              // Título CALZAME
              const Text(
                'CALZAME',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE57373), 
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),

              //  flecha boton
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF4A148C),
                onPressed: () {
                  // Acción al presionar la flechita
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}