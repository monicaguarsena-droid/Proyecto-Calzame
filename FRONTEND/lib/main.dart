import 'package:flutter/material.dart';
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
      home: VerificacionCorreo(
        email:
            "ejemplo@correo.com", // Reemplaza con el correo que necesites pasar
        onVerificar: (codigo) async {
          // Tu lógica de verificación aquí
        },
        onReenviar: () async {
          // Tu lógica para reenviar código aquí
        },
      ),
    );
  }
}
