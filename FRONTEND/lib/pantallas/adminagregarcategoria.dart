import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart'; 

class AdminAgregarCategoria extends StatefulWidget {
  final Map<String, dynamic>? categoria; // Recibe la categoría si es para editar

  const AdminAgregarCategoria({Key? key, this.categoria}) : super(key: key);

  @override
  State<AdminAgregarCategoria> createState() => _AdminAgregarCategoriaState();
}

class _AdminAgregarCategoriaState extends State<AdminAgregarCategoria> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoria != null ? widget.categoria!['nombre'] : '',
    );
    _descripcionController = TextEditingController(
      text: widget.categoria != null ? (widget.categoria!['descripcion'] ?? '') : '',
    );
  }

  void _guardarCategoria() {
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

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final mensaje = widget.categoria == null
          ? '¡Categoría agregada exitosamente!'
          : '¡Categoría actualizada exitosamente!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Devolvemos los datos limpios sin campos sobrantes
      Navigator.pop(context, {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'productos': widget.categoria != null ? widget.categoria!['productos'] : 0,
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esEdicion = widget.categoria != null;

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

              // Contenedor de Imagen
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
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

              // Descripción
              const Text(
                'Descripción (opcional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe una breve descripción...',
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
              const SizedBox(height: 32),

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
}