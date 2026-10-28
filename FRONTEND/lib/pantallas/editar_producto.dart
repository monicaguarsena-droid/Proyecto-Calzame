import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api_config.dart';

class EditarProductoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const EditarProductoScreen({Key? key, required this.producto}) : super(key: key);

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _descripcionController;
  
  // Categoría seleccionada por defecto (conviene tener las opciones estándar)
  String _categoriaSeleccionada = 'Dama';
  final List<String> _categoriasDisponibles = ['Dama', 'Caballero', 'Infantil'];

  // Controladores y lista para gestionar las tallas de forma interactiva
  final TextEditingController _nuevaTallaController = TextEditingController();
  List<String> _tallasList = [];

  bool _isLoading = false;
  final String baseUrl = "${ApiConfig.baseUrl}/productos"; // URL de tu backend en Node.js

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto['nombre'] ?? widget.producto['Nombre'] ?? '');
    
    // Cargar la categoría actual de forma segura validando que exista en las opciones
    String catActual = widget.producto['categoria'] ?? widget.producto['Categoria'] ?? 'Dama';
    // Capitalizamos la primera letra para que coincida con el Dropdown si es necesario
    if (_categoriasDisponibles.contains(catActual)) {
      _categoriaSeleccionada = catActual;
    } else {
      _categoriaSeleccionada = 'Dama'; // Valor por defecto si viene diferente
    }

    _precioController = TextEditingController(text: (widget.producto['precio'] ?? widget.producto['Precio'] ?? '').toString());
    _stockController = TextEditingController(text: (widget.producto['stock'] ?? widget.producto['Stock'] ?? '').toString());
    _descripcionController = TextEditingController(text: widget.producto['descripcion'] ?? widget.producto['Descripcion'] ?? '');

    // Parsear las tallas existentes de forma segura
    var tallasRaw = widget.producto['tallas'] ?? widget.producto['Tallas'];
    if (tallasRaw is List) {
      _tallasList = tallasRaw.map((t) => t.toString()).toList();
    } else if (tallasRaw is String && tallasRaw.isNotEmpty) {
      try {
        var decoded = json.decode(tallasRaw);
        if (decoded is List) {
          _tallasList = decoded.map((t) => t.toString()).toList();
        } else {
          _tallasList = tallasRaw.split(',').map((t) => t.trim()).toList();
        }
      } catch (_) {
        _tallasList = tallasRaw.split(',').map((t) => t.trim()).toList();
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _nuevaTallaController.dispose();
    super.dispose();
  }

  void _agregarTalla() {
    final nueva = _nuevaTallaController.text.trim();
    if (nueva.isNotEmpty && !_tallasList.contains(nueva)) {
      setState(() {
        _tallasList.add(nueva);
        _nuevaTallaController.clear();
      });
    }
  }

  void _eliminarTalla(String talla) {
    setState(() {
      _tallasList.remove(talla);
    });
  }

  Future<void> _actualizarProducto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final productoId = widget.producto['id'] ?? widget.producto['_id'];
      final url = Uri.parse('$baseUrl/api/productos/actualizar/$productoId');

      final bodyData = {
        'nombre': _nombreController.text.trim(),
        'categoria': _categoriaSeleccionada, // Enviamos la categoría seleccionada del menú
        'precio': double.tryParse(_precioController.text.trim()) ?? 0.0,
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'descripcion': _descripcionController.text.trim(),
        'tallas': _tallasList,
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final errorData = json.decode(response.body);
        _mostrarAlerta(errorData['error'] ?? 'Error al actualizar el producto');
      }
    } catch (e) {
      _mostrarAlerta('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarAlerta(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: ColoresApp.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        title: const Text(
          'Editar Producto', 
          style: TextStyle(color: ColoresApp.textOnPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColoresApp.primary,
        iconTheme: const IconThemeData(color: ColoresApp.textOnPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modifica los datos y existencias del calzado.',
              style: TextStyle(fontSize: 14, color: ColoresApp.textSecondary),
            ),
            const SizedBox(height: 24),
            
            // Nombre
            _crearCampo('Nombre del producto', _nombreController),
            const SizedBox(height: 20),

            // Selector de Categoría (Menú desplegable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: ColoresApp.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.border),
              ),
              child: DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                dropdownColor: ColoresApp.surface,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
                items: _categoriasDisponibles.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria, style: const TextStyle(color: ColoresApp.textPrimary)),
                  );
                }).toList(),
                onChanged: (String? nuevaCategoria) {
                  if (nuevaCategoria != null) {
                    setState(() {
                      _categoriaSeleccionada = nuevaCategoria;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Precio
            _crearCampo('Precio', _precioController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            // Stock
            _crearCampo('Stock (Existencias)', _stockController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            // Descripción
            _crearCampo('Descripción', _descripcionController, maxLines: 3),
            const SizedBox(height: 24),
            
            // Sección de Tallas interactiva
            const Text(
              'Tallas disponibles',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColoresApp.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColoresApp.border),
                    ),
                    child: TextField(
                      controller: _nuevaTallaController,
                      decoration: const InputDecoration(
                        hintText: 'Ej. 38, 39, 7.5',
                        hintStyle: TextStyle(color: ColoresApp.hint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _agregarTalla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Agregar', style: TextStyle(color: ColoresApp.textOnPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Chips de tallas
            _tallasList.isEmpty
                ? const Text('No hay tallas agregadas', style: TextStyle(color: ColoresApp.hint, fontSize: 13))
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _tallasList.map((talla) {
                      return Chip(
                        label: Text(talla, style: const TextStyle(color: ColoresApp.textPrimary, fontWeight: FontWeight.w600)),
                        backgroundColor: ColoresApp.surfaceVariant,
                        deleteIcon: const Icon(Icons.close, size: 18, color: ColoresApp.primary),
                        onDeleted: () => _eliminarTalla(talla),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: ColoresApp.border),
                        ),
                      );
                    }).toList(),
                  ),
            
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _actualizarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: ColoresApp.textOnPrimary)
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(color: ColoresApp.textOnPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _crearCampo(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: ColoresApp.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.w500),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}