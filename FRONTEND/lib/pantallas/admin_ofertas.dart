import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class AdminOfertasPage extends StatefulWidget {
  const AdminOfertasPage({Key? key}) : super(key: key);

  @override
  State<AdminOfertasPage> createState() => _AdminOfertasPageState();
}

class _AdminOfertasPageState extends State<AdminOfertasPage> {
  // Lista vacía para que agreguen las ofertas desde el botón
  final List<Map<String, dynamic>> _ofertas = [];

  // Función para abrir el modal (permite Agregar o Editar una oferta)
  void _mostrarModalFormulario({Map<String, dynamic>? ofertaAEditar, int? index}) {
    final tituloController = TextEditingController(
      text: ofertaAEditar != null ? ofertaAEditar['titulo'] : '',
    );
    final descuentoController = TextEditingController(
      text: ofertaAEditar != null ? ofertaAEditar['descuento'] : '',
    );
    final descripcionController = TextEditingController(
      text: ofertaAEditar != null ? (ofertaAEditar['descripcion'] ?? '') : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ofertaAEditar == null ? 'Nuevo Banner u Oferta' : 'Editar Oferta',
                style: const TextStyle(
                  color: ColoresApp.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Contenedor para simular la subida de imagen del banner
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: ColoresApp.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined, size: 28, color: ColoresApp.primary),
                    const SizedBox(height: 6),
                    const Text(
                      'Subir imagen del banner',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColoresApp.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  hintText: 'Título de la oferta o promoción',
                  filled: true,
                  fillColor: ColoresApp.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descuentoController,
                decoration: InputDecoration(
                  hintText: 'Porcentaje o Texto (Ej. 20% OFF)',
                  filled: true,
                  fillColor: ColoresApp.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descripcionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Descripción o términos de la oferta...',
                  filled: true,
                  fillColor: ColoresApp.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (tituloController.text.trim().isEmpty) return;

                    setState(() {
                      if (ofertaAEditar == null) {
                        // Agrega nueva oferta a la lista
                        _ofertas.add({
                          'titulo': tituloController.text.trim(),
                          'descuento': descuentoController.text.trim().isEmpty ? 'PROMO' : descuentoController.text.trim(),
                          'descripcion': descripcionController.text.trim(),
                          'estado': 'Activo',
                        });
                      } else {
                        // Actualiza la oferta existente
                        _ofertas[index!] = {
                          'titulo': tituloController.text.trim(),
                          'descuento': descuentoController.text.trim(),
                          'descripcion': descripcionController.text.trim(),
                          'estado': ofertaAEditar['estado'],
                        };
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ofertaAEditar == null ? '¡Oferta agregada exitosamente!' : '¡Oferta actualizada exitosamente!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    ofertaAEditar == null ? 'Guardar Oferta' : 'Actualizar Oferta',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera con contador y botón para agregar oferta
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_offer_outlined, color: ColoresApp.primary, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_ofertas.length} ofertas activas',
                  style: const TextStyle(
                    color: ColoresApp.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _mostrarModalFormulario(),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Agregar oferta',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Listado o Mensaje Vacío
        _ofertas.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.local_offer_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No hay ofertas registradas',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Presiona "Agregar oferta" para crear una.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ofertas.length,
                itemBuilder: (context, index) {
                  final oferta = _ofertas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                oferta['descuento'],
                                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          oferta['titulo'],
                          style: const TextStyle(
                            color: ColoresApp.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (oferta['descripcion'] != null && oferta['descripcion'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            oferta['descripcion'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _mostrarModalFormulario(ofertaAEditar: oferta, index: index),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColoresApp.primary,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _ofertas.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColoresApp.primary,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}