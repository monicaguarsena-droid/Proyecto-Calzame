import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/servicios/categorias_service.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/cors/colores.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/api_config.dart';

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
  final _nuevoColorController = TextEditingController();

  // 📸 NUEVO: Lista de múltiples imágenes y gestión de colores con sus fotos
  List<File> _imagenesSeleccionadas = [];
  final List _coloresConImagen = []; 
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

  // 📸 NUEVO: Método para seleccionar múltiples imágenes a la vez
  Future<void> _seleccionarMultiplesImagenes() async {
    try {
      final List<XFile> imps = await _picker.pickMultiImage(imageQuality: 80);
      if (imps.isNotEmpty) {
        setState(() {
          for (var img in imps) {
            File archivo = File(img.path);
            _imagenesSeleccionadas.add(archivo);
            // Por defecto asignamos un nombre de color temporal editable
            _coloresConImagen.add({
              'color': 'Color ${_coloresConImagen.length + 1}',
              'file': archivo,
            });
          }
        });
      }
    } catch (e) {
      print("Error al seleccionar las imágenes: $e");
    }
  }

  String _categoriaSeleccionada = 'Dama';
  final List<String> _categorias = ['Dama', 'Caballero', 'Infantil'];

  List<String> _tiposCalzado = [];
  String? _tipoCalzadoSeleccionado;
  bool _isLoadingCategorias = true;

  @override
  void initState() {
    super.initState();
    _cargarTiposCalzadoDesdeBD();
  }

  Future<void> _cargarTiposCalzadoDesdeBD() async {
    try {
      final categoriasList = await CategoriaService.listar();
      setState(() {
        _tiposCalzado = categoriasList.map((cat) => cat['nombre'].toString()).toList();
        if (_tiposCalzado.isNotEmpty) {
          if (_tipoCalzadoSeleccionado == null || !_tiposCalzado.contains(_tipoCalzadoSeleccionado)) {
            _tipoCalzadoSeleccionado = _tiposCalzado.first;
          }
        } else {
          _tipoCalzadoSeleccionado = null;
        }
        _isLoadingCategorias = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategorias = false;
      });
      print("Error cargando categorías para productos: $e");
    }
  }

  final List<String> _tallasDisponibles = [
    '16','17','18','19','20','21','22','23','24','25','26',
    '27','28','29','30','31','32','33','34','35','36','37',
    '38','39','40','41','42','43','44','45',
  ];
  final List<String> _tallasSeleccionadas = [];

  bool _isLoading = false;
  final String baseUrl = ApiConfig.baseUrl + '/productos';

  Future<void> _guardarProductoConImagen() async {
    if (_imagenesSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una foto para el producto.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_nombreController.text.trim().isEmpty || 
        _precioController.text.trim().isEmpty || 
        _stockController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos obligatorios (Nombre, Precio, Stock).'),
          backgroundColor: Colors.orange,
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

      // Campos de texto básicos
      request.fields['Nombre'] = _nombreController.text.trim();
      request.fields['Categoria'] = _categoriaSeleccionada;
      request.fields['TipoCalzado'] = _tipoCalzadoSeleccionado ?? '';
      request.fields['Precio'] = _precioController.text.trim();
      request.fields['Stock'] = _stockController.text.trim();
      request.fields['Descripcion'] = _descripcionController.text.trim();
      request.fields['Tallas'] = json.encode(_tallasSeleccionadas);

      // 📸 Adjuntar múltiples archivos de imagen
      for (var imgFile in _imagenesSeleccionadas) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagenes', // Nombre del campo que espera el backend
            imgFile.path,
          ),
        );
      }

      // Enviar mapeo de colores con su respectiva foto
      final coloresMapeados = _coloresConImagen.map((item) => {
        'color': item['color'],
        'indexImagen': _imagenesSeleccionadas.indexOf(item['file']),
      }).toList();

      request.fields['coloresData'] = json.encode(coloresMapeados);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true); 
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
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary, size: 18),
          label: const Text('Atrás', style: TextStyle(color: ColoresApp.primary)),
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
            // 📸 Sección para seleccionar múltiples imágenes y asociarlas a colores
            const Text(
              'Imágenes y Colores Disponibles',
              style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _seleccionarMultiplesImagenes,
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: ColoresApp.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColoresApp.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: ColoresApp.primary),
                    SizedBox(height: 6),
                    Text(
                      'Seleccionar varias fotos de la galería',
                      style: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Vista previa de fotos seleccionadas y asignación de nombre de color
            if (_imagenesSeleccionadas.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _coloresConImagen.length,
                itemBuilder: (context, index) {
                  final item = _coloresConImagen[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColoresApp.border),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            item['file'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: item['color'])
                              ..selection = TextSelection.fromPosition(
                                TextPosition(offset: item['color'].toString().length),
                              ),
                            onChanged: (val) {
                              _coloresConImagen[index]['color'] = val;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Nombre del color (Ej: Beige, Negro)',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _imagenesSeleccionadas.remove(item['file']);
                              _coloresConImagen.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Nombre del producto
            const Text('Nombre del producto', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            TextField(controller: _nombreController, decoration: _inputDecoration('Sandalia de tiras')),
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
                  items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipo de Calzado dinámico
            const Text('Tipo de Calzado', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            _isLoadingCategorias
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColoresApp.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _tipoCalzadoSeleccionado,
                        isExpanded: true,
                        items: _tiposCalzado.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                        onChanged: (val) => setState(() => _tipoCalzadoSeleccionado = val),
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
                      TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: _inputDecoration('0.00')),
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
                      TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: _inputDecoration('0')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción
            const Text('Descripción del calzado', style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
            const SizedBox(height: 6),
            TextField(controller: _descripcionController, maxLines: 2, decoration: _inputDecoration('Descripción del calzado')),
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
                onPressed: _isLoading ? null : _guardarProductoConImagen,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Producto',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}