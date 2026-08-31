import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F2), // Fondo rosado suave
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen del tacón
              Image.asset(
                'assets/img/tacon.png', 
                height: 180,
              ),
              const SizedBox(height: 20),

              // Título CALZAME
              const Text(
                'CALZAME',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE57373), // Color rosado del texto
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),

              // Botón de la flecha hacia la derecha
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF4A148C),
                onPressed: () {
                  // Acción al presionar la flecha
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}