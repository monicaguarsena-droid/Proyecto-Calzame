import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- 1. Importas esto
import '../componentes/producto_card.dart';
import '../componentes/chat/chat_calzame_modal.dart';

class MenuPage extends StatefulWidget { // <--- 2. Cambia a StatefulWidget
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _nombreUsuario = ''; // <--- 3. Variable para guardar el nombre

  @override
  void initState() {
    super.initState();
    _obtenerNombre(); // <--- 4. Lo cargamos al abrir la pantalla
  }

  // Esta función busca el nombre que se guardó al iniciar sesión
  Future<void> _obtenerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreUsuario = prefs.getString('nombre') ?? 'Usuario';
    });
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // <--- 5. AQUÍ MOSTRAMOS EL SALUDO PERSONALIZADO ARRIBA --->
            Text(
              _nombreUsuario.isEmpty ? '¡Hola!' : '¡Hola, $_nombreUsuario!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const Text(
              'Catálogo Calzame',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
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