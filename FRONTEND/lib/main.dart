import 'package:flutter/material.dart';
import 'package:frontend/pantallas/admin_panel.dart'; // Importa el splash (PantallaInicio)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminPanel(), // <--  splash pantalla iniciual
    );
  }
}