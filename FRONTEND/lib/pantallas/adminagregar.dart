import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/cors/colores.dart'; // Ajusta la ruta de tus colores si es necesario
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api_config.dart'; // Asegúrate de tener esta importación para usar ApiConfig

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

  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ColoresApp.hint),
      filled: true,
      fillColor: ColoresApp.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ColoresApp.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ColoresApp.border),
      ),
    );
  }

  // Función para abrir el selector (Galería o Cámara)
  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? Imagen = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Comprime un poco la imagen para optimizar la subida
      );

      if (Imagen != null) {
        setState(() {
          _imagenSeleccionada = File(Imagen.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    }
  }

  void _mostrarOpcionesImagen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColoresApp.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: ColoresApp.primary,
                ),
                title: const Text(
                  'Galería',
                  style: TextStyle(color: ColoresApp.textPrimary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: ColoresApp.primary,
                ),
                title: const Text(
                  'Cámara',
                  style: TextStyle(color: ColoresApp.textPrimary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _categoriaSeleccionada = 'Dama';
  final List<String> _categorias = ['Dama', 'Caballero', 'Infantil'];

  // Tallas disponibles y seleccionadas
  final List<String> _tallasDisponibles = [
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
  ];
  final List<String> _tallasSeleccionadas = [];

  bool _isLoading = false;
  final String baseUrl =
      ApiConfig.baseUrl + '/productos'; // URL de tu backend en Node.js

  Future<void> _guardarProductoConImagen() async {
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una foto para el producto.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/crear'));

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Adjuntar los campos de texto
      request.fields['Nombre'] = _nombreController.text.trim();
      request.fields['Categoria'] = _categoriaSeleccionada;
      request.fields['Precio'] = _precioController.text.trim();
      request.fields['Stock'] = _stockController.text.trim();
      request.fields['Descripcion'] = _descripcionController.text.trim();
      request.fields['Tallas'] = json.encode(_tallasSeleccionadas);

      // Adjuntar la imagen si el usuario seleccionó una
      if (_imagenSeleccionada != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Imagen', // El nombre del campo que espera tu backend (ej. Multer en Node.js)
            _imagenSeleccionada!.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); // Regresa al inventario y recarga
      } else {
        final errorData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? 'Error al guardar el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
          icon: const Icon(
            Icons.arrow_back,
            color: ColoresApp.primary,
            size: 18,
          ),
          label: const Text(
            'Atrás',
            style: TextStyle(color: ColoresApp.primary),
          ),
        ),
        leadingWidth: 90,
        title: const Text(
          'Agregar Producto',
          style: TextStyle(
            color: ColoresApp.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caja para subir imagen
            GestureDetector(
              onTap: () => _mostrarOpcionesImagen(context),
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: ColoresApp.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColoresApp.border),
                ),
                child: _imagenSeleccionada != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imagenSeleccionada!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: ColoresApp.primary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Subir imagen del calzado',
                            style: TextStyle(
                              color: ColoresApp.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre del producto
            const Text(
              'Nombre del producto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nombreController,
              decoration: _inputDecoration('Sandalia de tiras'),
            ),
            const SizedBox(height: 16),

            // Categoría
            const Text(
              'Categoría',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
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
                  onChanged: (val) =>
                      setState(() => _categoriaSeleccionada = val!),
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
                      const Text(
                        'Precio (\$)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primary,
                        ),
                      ),
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
                      const Text(
                        'Stock (Unidades)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primary,
                        ),
                      ),
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
            const Text(
              'Descripción del calzado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: _inputDecoration('Descripción del calzado'),
            ),
            const SizedBox(height: 16),

            // Tallas
            const Text(
              'Tallas disponibles',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tallasDisponibles.map((talla) {
                final seleccionada = _tallasSeleccionadas.contains(talla);
                return ChoiceChip(
                  label: Text(talla),
                  selected: seleccionada,
                  selectedColor: ColoresApp.primary,
                  labelStyle: TextStyle(
                    color: seleccionada ? Colors.white : ColoresApp.primary,
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _guardarProductoConImagen,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Producto',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
