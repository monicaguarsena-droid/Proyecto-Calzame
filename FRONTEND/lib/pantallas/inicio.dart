import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/tacon.jpg', height: 180),
              const SizedBox(height: 30),
              const Text(
                'CALZAME',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_forward),
                color: ColoresApp.wine,
                onPressed: () {
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