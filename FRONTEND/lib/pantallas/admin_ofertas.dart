import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/catalogo_visual_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminOfertasScreen extends StatelessWidget {
  const AdminOfertasScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColoresApp.background,
    appBar: AppBar(
      title: const Text('Ofertas y banners'),
      foregroundColor: ColoresApp.primary,
      backgroundColor: ColoresApp.background,
    ),
    body: const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: AdminOfertasPage(),
      ),
    ),
  );
}

class AdminOfertasPage extends StatefulWidget {
  const AdminOfertasPage({super.key});

  @override
  State<AdminOfertasPage> createState() => _AdminOfertasPageState();
}

class _AdminOfertasPageState extends State<AdminOfertasPage> {
  late Future<List<Map<String, dynamic>>> _ofertasFuture;

  @override
  void initState() {
    super.initState();
    _cargarOfertas();
  }

  void _cargarOfertas() {
    _ofertasFuture = CatalogoVisualService.listar('ofertas');
  }

  Future<void> _editarOferta({Map<String, dynamic>? oferta}) async {
    final titulo = TextEditingController(text: oferta?['titulo']?.toString());
    final descuento = TextEditingController(
      text: oferta?['descuento']?.toString(),
    );
    final descripcion = TextEditingController(
      text: oferta?['descripcion']?.toString(),
    );
    final tag = TextEditingController(text: oferta?['tag']?.toString());
    File? imagen;
    bool guardando = false;
    final formKey = GlobalKey<FormState>();

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
                    oferta == null ? 'Nueva oferta' : 'Editar oferta',
                    style: const TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _selectorImagen(
                    context,
                    imagen: imagen,
                    imagenActual: oferta?['imagen_url']?.toString(),
                    alSeleccionar: (archivo) =>
                        setModalState(() => imagen = archivo),
                  ),
                  if (oferta == null && imagen == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Selecciona la foto de la oferta.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 14),
                  _campo(titulo, 'Título de la oferta', obligatorio: true),
                  const SizedBox(height: 10),
                  _campo(descuento, 'Descuento (ej. 20% OFF)'),
                  const SizedBox(height: 10),
                  _campo(tag, 'Etiqueta del banner (ej. NUEVA COLECCIÓN)'),
                  const SizedBox(height: 10),
                  _campo(descripcion, 'Descripción', maxLines: 2),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardando
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              if (oferta == null && imagen == null) {
                                setModalState(() {});
                                return;
                              }
                              setModalState(() => guardando = true);
                              try {
                                await CatalogoVisualService.guardar(
                                  recurso: 'ofertas',
                                  id: oferta?['id']?.toString(),
                                  imagen: imagen,
                                  campos: {
                                    'titulo': titulo.text.trim(),
                                    'descuento': descuento.text.trim(),
                                    'tag': tag.text.trim().isEmpty
                                        ? 'OFERTA'
                                        : tag.text.trim(),
                                    'descripcion': descripcion.text.trim(),
                                  },
                                );
                                if (!mounted || !sheetContext.mounted) return;
                                setState(_cargarOfertas);
                                Navigator.pop(sheetContext);
                                _mostrarMensaje(
                                  oferta == null
                                      ? 'Oferta guardada.'
                                      : 'Oferta actualizada.',
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
                              oferta == null
                                  ? 'Guardar oferta'
                                  : 'Guardar cambios',
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
    titulo.dispose();
    descuento.dispose();
    descripcion.dispose();
    tag.dispose();
  }

  Widget _selectorImagen(
    BuildContext context, {
    required File? imagen,
    required String? imagenActual,
    required ValueChanged<File> alSeleccionar,
  }) {
    return InkWell(
      onTap: () async {
        final origen = await showModalBottomSheet<ImageSource>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Seleccionar foto de la oferta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: ColoresApp.primary,
                  ),
                  title: const Text('Elegir de la galería'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: ColoresApp.primary,
                  ),
                  title: const Text('Tomar con la cámara'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
        if (origen == null || !context.mounted) return;

        try {
          final seleccion = await ImagePicker().pickImage(
            source: origen,
            imageQuality: 85,
          );
          if (seleccion != null && context.mounted) {
            alSeleccionar(File(seleccion.path));
          }
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo seleccionar la imagen: $error'),
              backgroundColor: Colors.red,
            ),
          );
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
            ? Image.file(imagen, fit: BoxFit.cover)
            : imagenActual != null && imagenActual.isNotEmpty
            ? Image.network(
                imagenActual,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholderImagen(),
              )
            : _placeholderImagen(),
      ),
    );
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
        Text('Seleccionar foto de la oferta'),
      ],
    ),
  );

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    bool obligatorio = false,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: etiqueta,
      border: const OutlineInputBorder(),
    ),
    validator: obligatorio
        ? (value) => value == null || value.trim().isEmpty
              ? 'Este campo es obligatorio'
              : null
        : null,
  );

  Future<void> _eliminarOferta(Map<String, dynamic> oferta) async {
    try {
      await CatalogoVisualService.eliminar(
        recurso: 'ofertas',
        id: oferta['id'].toString(),
      );
      if (!mounted) return;
      setState(_cargarOfertas);
      _mostrarMensaje('Oferta eliminada.');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ofertas activas',
              style: TextStyle(
                color: ColoresApp.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _editarOferta(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _ofertasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text(
                'No se pudieron cargar las ofertas: ${snapshot.error}',
              );
            }
            final ofertas = snapshot.data ?? [];
            if (ofertas.isEmpty) {
              return const Text('Aún no hay ofertas publicadas.');
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ofertas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final oferta = ofertas[index];
                final imagen = oferta['imagen_url']?.toString() ?? '';
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColoresApp.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: ColoresApp.background,
                        child: imagen.isEmpty
                            ? _placeholderImagen()
                            : Image.network(
                                imagen,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _placeholderImagen(),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              oferta['descuento']?.toString() ?? '',
                              style: const TextStyle(
                                color: ColoresApp.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              oferta['titulo']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(oferta['descripcion']?.toString() ?? ''),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _editarOferta(oferta: oferta),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Editar'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _eliminarOferta(oferta),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
