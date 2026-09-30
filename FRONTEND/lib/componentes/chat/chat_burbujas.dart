import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({
    super.key,
    required this.texto,
    required this.esUsuario,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          texto,
          style: TextStyle(
            color: esUsuario ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}