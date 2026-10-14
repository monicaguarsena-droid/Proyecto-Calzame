import 'package:flutter/material.dart';
import 'package:frontend/pantallas/splash.dart'; // Importa el splash (PantallaInicio)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaInicio(), // <-- Aquí llamas al splash como pantalla inicial
    );
  }
}