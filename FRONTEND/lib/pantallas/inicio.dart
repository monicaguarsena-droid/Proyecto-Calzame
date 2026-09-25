import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/inicio_sesion.dart'; // <--- 1. Importa tu pantalla de inicio de sesión

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoApp,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen del tacón.jpg
              Image.asset('assets/img/tacon.jpg', height: 180),
              const SizedBox(height: 30),
              // Título CALZAME
              const Text(
                'CALZAME',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.letra,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              // flecha boton
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF4A148C),
                onPressed: () {
                  // <--- 2. Agrega la navegación aquí dentro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InicioSesion(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
