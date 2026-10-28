import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/catalogo_visual_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminTiposCalzadoPage extends StatefulWidget {
  const AdminTiposCalzadoPage({super.key});

  @override
  State<AdminTiposCalzadoPage> createState() => _AdminTiposCalzadoPageState();
}

class _AdminTiposCalzadoPageState extends State<AdminTiposCalzadoPage> {
  late Future<List<Map<String, dynamic>>> _tiposFuture;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  void _cargarTipos() {
    _tiposFuture = CatalogoVisualService.listar('tipos-calzado');
  }

  Future<void> _editarTipo({Map<String, dynamic>? tipo}) async {
    final nombre = TextEditingController(text: tipo?['nombre']?.toString());
    final descripcion = TextEditingController(
      text: tipo?['descripcion']?.toString(),
    );
    File? imagen;
    final formKey = GlobalKey<FormState>();
    var guardando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo == null
                        ? 'Nuevo tipo de calzado'
                        : 'Editar tipo de calzado',
                    style: const TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final seleccion = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (seleccion != null && sheetContext.mounted) {
                        setModalState(() => imagen = File(seleccion.path));
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 145,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: ColoresApp.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ColoresApp.border),
                      ),
                      child: imagen != null
                          ? Image.file(imagen!, fit: BoxFit.cover)
                          : _imagenGuardada(tipo?['imagen_url']?.toString()),
                    ),
                  ),
                  if (tipo == null && imagen == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Selecciona la foto del tipo de calzado.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escribe el nombre del tipo'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descripcion,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardando
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final imagenGuardada =
                                  tipo?['imagen_url']?.toString() ?? '';
                              if (imagen == null &&
                                  (tipo == null || imagenGuardada.isEmpty)) {
                                setModalState(() {});
                                return;
                              }
                              setModalState(() => guardando = true);
                              try {
                                await CatalogoVisualService.guardar(
                                  recurso: 'tipos-calzado',
                                  id: tipo?['id']?.toString(),
                                  imagen: imagen,
                                  campos: {
                                    'nombre': nombre.text.trim(),
                                    'descripcion': descripcion.text.trim(),
                                  },
                                );
                                if (!mounted || !sheetContext.mounted) return;
                                setState(_cargarTipos);
                                Navigator.pop(sheetContext);
                                _mostrarMensaje(
                                  tipo == null
                                      ? 'Tipo de calzado guardado.'
                                      : 'Tipo de calzado actualizado.',
                                );
                              } catch (error) {
                                if (sheetContext.mounted) {
                                  setModalState(() => guardando = false);
                                }
                                _mostrarMensaje(error.toString(), error: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: guardando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              tipo == null ? 'Guardar tipo' : 'Guardar cambios',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    nombre.dispose();
    descripcion.dispose();
  }

  Widget _imagenGuardada(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderImagen(),
      );
    }
    return _placeholderImagen();
  }

  Widget _placeholderImagen() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 30,
          color: ColoresApp.primary,
        ),
        SizedBox(height: 6),
        Text('Seleccionar foto del tipo'),
      ],
    ),
  );

  Future<void> _eliminarTipo(Map<String, dynamic> tipo) async {
    try {
      await CatalogoVisualService.eliminar(
        recurso: 'tipos-calzado',
        id: tipo['id'].toString(),
      );
      if (!mounted) return;
      setState(_cargarTipos);
      _mostrarMensaje('Tipo de calzado eliminado.');
    } catch (error) {
      _mostrarMensaje(error.toString(), error: true);
    }
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        title: const Text('Tipos de calzado'),
        foregroundColor: ColoresApp.primary,
        backgroundColor: ColoresApp.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editarTipo(),
        backgroundColor: ColoresApp.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar tipo'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tiposFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los tipos: ${snapshot.error}',
                ),
              ),
            );
          }
          final tipos = snapshot.data ?? [];
          if (tipos.isEmpty) {
            return const Center(
              child: Text('Aún no hay tipos de calzado registrados.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: tipos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tipo = tipos[index];
              final imagen = tipo['imagen_url']?.toString() ?? '';
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ColoresApp.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 112,
                      child: imagen.isEmpty
                          ? _placeholderImagen()
                          : Image.network(
                              imagen,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholderImagen(),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tipo['nombre']?.toString() ?? '',
                              style: const TextStyle(
                                color: ColoresApp.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tipo['descripcion']?.toString() ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Wrap(
                              children: [
                                TextButton(
                                  onPressed: () => _editarTipo(tipo: tipo),
                                  child: const Text('Editar'),
                                ),
                                TextButton(
                                  onPressed: () => _eliminarTipo(tipo),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
