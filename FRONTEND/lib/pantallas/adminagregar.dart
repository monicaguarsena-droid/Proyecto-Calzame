import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/cors/colores.dart'; // Ajusta la ruta de tus colores si es necesario
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar el token de autenticación

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _categoriaSeleccionada = 'Dama';
  final List<String> _categorias = ['Dama', 'Caballero', 'Infantil'];
  
  // Tallas disponibles y seleccionadas
  final List<String> _tallasDisponibles = ['30', '31', '36', '37', '38', '39','40', '41', '42', '43', '44', '45'];
  final List<String> _tallasSeleccionadas = [];

  bool _isLoading = false;
  final String baseUrl = 'http://10.0.2.2:3000/api'; // URL de tu backend en Node.js

  Future<void> _guardarProducto() async {
  if (_nombreController.text.isEmpty || _precioController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor llena al menos el nombre y el precio')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // Limpiamos el precio eliminando puntos o comas de miles
    String precioLimpios = _precioController.text.replaceAll('.', '').replaceAll(',', '');
    double precioFinal = double.tryParse(precioLimpios) ?? 0.0;
    int stockFinal = int.tryParse(_stockController.text) ?? 0;

    final bodyData = {
      'Nombre': _nombreController.text.trim(),
      'Categoria': _categoriaSeleccionada,
      'Precio': precioFinal,
      'Stock': stockFinal,
      'Descripcion': _descripcionController.text.trim(),
      'Tallas': _tallasSeleccionadas,
      'Imagen': 'assets/images/default_shoe.png',
    };
    print("Datos que se enviarán: $bodyData");
    print("TOKEN RECUPERADO DE MEMORIA: --> $token <--");

    final response = await http.post(
      Uri.parse('$baseUrl/productos/crear'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(bodyData),
    );

    print("Código de respuesta del servidor: ${response.statusCode}");
    print("Respuesta: ${response.body}");

    if (!mounted) return;

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto agregado con éxito!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error del servidor: ${response.body}'), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    print("Excepción de red: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexión con el backend: $e'), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.background,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary, size: 18),
          label: const Text('Atrás', style: TextStyle(color: ColoresApp.primary)),
        ),
        leadingWidth: 90,
        title: const Text(
          'Agregar Producto',
          style: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caja para subir imagen
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.border),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: ColoresApp.primary),
                  SizedBox(height: 8),
                  Text('Subir imagen del calzado', style: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nombre del producto
            const Text('Nombre del producto', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            TextField(
              controller: _nombreController,
              decoration: _inputDecoration('Sandalia de tiras'),
            ),
            const SizedBox(height: 16),

            // Categoría
            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColoresApp.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoriaSeleccionada,
                  isExpanded: true,
                  items: _categorias.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Precio y Stock
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Precio (\$)', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _precioController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0.00'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock (Unidades)', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción
            const Text('Descripción del calzado', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            TextField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: _inputDecoration('Descripción del calzado'),
            ),
            const SizedBox(height: 16),

            // Tallas
            const Text('Tallas disponibles', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tallasDisponibles.map((talla) {
                final seleccionada = _tallasSeleccionadas.contains(talla);
                return ChoiceChip(
                  label: Text(talla),
                  selected: seleccionada,
                  selectedColor: ColoresApp.primary,
                  labelStyle: TextStyle(color: seleccionada ? Colors.white : ColoresApp.primary),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _tallasSeleccionadas.add(talla);
                      } else {
                        _tallasSeleccionadas.remove(talla);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _guardarProducto,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColoresApp.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColoresApp.border)),
    );
  }
}