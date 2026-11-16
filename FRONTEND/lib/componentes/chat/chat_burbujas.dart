import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({super.key, required this.texto, required this.esUsuario});

  List<Widget> _contenido(Color colorTexto) {
    final imagenMarkdown = RegExp(r'^\s*!\[([^\]]*)\]\((https?://\S+)\)\s*$');
    return texto.split('\n').map((linea) {
      final coincidencia = imagenMarkdown.firstMatch(linea);
      if (coincidencia == null) {
        return Text(
          linea,
          style: TextStyle(color: colorTexto, fontSize: 14, height: 1.35),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            coincidencia.group(2)!,
            width: 180,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 180,
              height: 48,
              child: Center(child: Text('Imagen no disponible')),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorTexto = esUsuario ? Colors.white : Colors.black87;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? const Color(0xFFE91E63) : const Color(0xFFFFF1F4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _contenido(colorTexto),
        ),
      ),
    );
  }
}
