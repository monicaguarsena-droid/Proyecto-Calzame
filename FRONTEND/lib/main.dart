import 'package:flutter/material.dart';
import 'package:frontend/pantallas/confimarcodigo.dart';
import 'package:frontend/pantallas/olvidocontrase%C3%B1a.dart';
import 'package:frontend/pantallas/verificacioncongoogle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: //ConfirmarCodigo()
      
      RecuperarCuenta()
    );
  }
}
