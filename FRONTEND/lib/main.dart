import 'package:flutter/material.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/splash.dart';
// Importa tu pantalla home o la pantalla principal a donde quieras redirigir:
// import 'package:frontend/pantallas/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Inicio(),
        '/home': (context) => const Home(), // Reemplaza const Placeholder() por tu widget/pantalla real de Home (ej: HomeScreen())
      },
    );
  }
}