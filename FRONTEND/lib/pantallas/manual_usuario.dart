import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:pdfrx/pdfrx.dart';

class ManualUsuarioScreen extends StatelessWidget {
  const ManualUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de usuario'),
        backgroundColor: ColoresApp.primary,
        foregroundColor: Colors.white,
      ),
      body: PdfViewer.asset('assets/manual/manual_usuario.pdf'),
    );
  }
}
