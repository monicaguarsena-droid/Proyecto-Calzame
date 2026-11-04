import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/categorias_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminAgregarCategoria extends StatefulWidget {
  final Map<String, dynamic>? categoria;

  const AdminAgregarCategoria({Key? key, this.categoria}) : super(key: key);

  @override
  State<AdminAgregarCategoria> createState() => _AdminAgregarCategoriaState();
}

class _AdminAgregarCategoriaState extends State<AdminAgregarCategoria> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  File? _imagenSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoria != null ? widget.categoria!['nombre'] ?? widget.categoria!['titulo'] ?? '' : '',
    );
    _descripcionController = TextEditingController(
      text: widget.categoria != null ? (widget.categoria!['descripcion'] ?? '') : '',
    );
  }

  // Método auxiliar para construir la URL completa de Cloudinary
  String _obtenerImagenUrl(String? urlParcial) {
    print('🌐 URL PARCIAL RECIBIDA: $urlParcial');
  if (urlParcial == null || urlParcial.isEmpty) return '';
  if (urlParcial.startsWith('http')) return urlParcial;
  
  // Limpiamos si por casualidad trae una barra inicial
  final limpia = urlParcial.startsWith('/') ? urlParcial.substring(1) : urlParcial;
  
  // Si la ruta ya contiene 'upload/', solo anteponemos el dominio base del cloud
  if (limpia.startsWith('upload/')) {
    return 'https://res.cloudinary.com/vicsxzqj/$limpia';
  }
  
  // Si es una ruta totalmente limpia sin 'upload/', la estructuramos completa:
  return 'https://res.cloudinary.com/vicsxzqj/image/upload/$limpia';
}

  // Método para seleccionar imagen desde galería o cámara
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _guardarCategoria() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre de la categoría'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await CategoriaService.guardar(
        id: widget.categoria?['id']?.toString(),
        imagen: _imagenSeleccionada,
        campos: {
          'nombre': _nombreController.text.trim(),
          //'descripcion': _descripcionController.text.trim(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.categoria == null
                ? '¡Categoría agregada exitosamente!'
                : '¡Categoría actualizada exitosamente!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Cerramos la pantalla y retornamos 'true' para avisar al panel administrador que recargue la lista
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // En tu método build de adminagregarcategoria.dart, cámbialo por esto:
    final bool esEdicion = widget.categoria != null;
    final String? imagenActual = widget.categoria?['imagen_url']?.toString() ?? widget.categoria?['imagen']?.toString();

    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esEdicion ? 'Editar Categoría' : 'Nueva Categoría',
                        style: const TextStyle(
                          color: ColoresApp.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        esEdicion ? 'Modifica los datos de la categoría' : 'Agrega una categoría al catálogo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _imagenSeleccionada != null
                      ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                      : (imagenActual != null && imagenActual.isNotEmpty
                          ? Image.network(
                              _obtenerImagenUrl(imagenActual),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                            )
                          : _placeholderImagen()),
                ),
              ),
              const SizedBox(height: 20),

              // Nombre de la categoría
              const Text(
                'Nombre de la categoría',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Ej. Deportivos, Tacones...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _guardarCategoria,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          esEdicion ? 'Actualizar Categoría' : 'Guardar Categoría',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImagen() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              size: 28,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Subir imagen representativa',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColoresApp.primary,
            ),
          ),
        ],
      );
}