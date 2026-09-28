import 'package:flutter/material.dart';
import '../../servicios/chat_calzame_service.dart';
import 'chat_header.dart';
import 'chat_burbujas.dart';
import 'chat_input_field.dart';

class ChatCalzameModal extends StatefulWidget {
  const ChatCalzameModal({super.key});

  @override
  State<ChatCalzameModal> createState() => _ChatCalzameModalState();
}

class _ChatCalzameModalState extends State<ChatCalzameModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text': '¡Hola! Bienvenido a Calzame. ¿Qué zapatos, estilos o tallas te gustaría conocer hoy?'
    }
  ];

  bool _cargando = false;

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _cargando = true;
    });

    _scrollHaciaAbajo();

    final respuesta = await ChatCalzameService.enviarMensaje(texto);

    if (mounted) {
      setState(() {
        _mensajes.add({'role': 'bot', 'text': respuesta});
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const ChatHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final item = _mensajes[index];
                return ChatBurbuja(
                  texto: item['text']!,
                  esUsuario: item['role'] == 'user',
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE91E63)),
                  ),
                  SizedBox(width: 8),
                  Text('El asesor está respondiendo...', style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
          ChatInputField(
            controller: _controller,
            cargando: _cargando,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }
}