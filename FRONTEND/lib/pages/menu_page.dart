import 'package:flutter/material.dart';
import '../componentes/producto_card.dart';
import '../componentes/chat/chat_calzame_modal.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _abrirChatCalzame(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatCalzameModal(),
    );
  }

  void _mostrarModalDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Detalles del Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Próximamente disponible con toda la información cargada desde el panel administrativo.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 246, 244, 1),
      appBar: AppBar(
        title: const Text(
          'Catálogo Calzame',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          children: [
            ProductoCard(
              onVerMas: () => _mostrarModalDetalle(context),
              onComprar: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de compra disponible próximamente'),
                    backgroundColor: Color(0xFFE91E63),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirChatCalzame(context),
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
    );
  }
}