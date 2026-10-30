import 'package:flutter/material.dart';

class GuiaTallas {
  final String categoria;
  final String tipoCalzado;
  final Map<String, String> equivalenciasCm;

  GuiaTallas({
    required this.categoria,
    required this.tipoCalzado,
    required this.equivalenciasCm,
  });
}

class RepositorioGuiaTallas {
  static List<GuiaTallas> obtenerGuias() {
    return [
      // DAMA - Tenis / Deportivos
      GuiaTallas(
        categoria: 'Dama',
        tipoCalzado: 'Tenis y Deportivos',
        equivalenciasCm: {
          '35': '22.5 cm',
          '36': '23.0 cm',
          '37': '24.0 cm',
          '38': '24.5 cm',
          '39': '25.0 cm',
        },
      ),
      // DAMA - Sandalias y Zapatillas
      GuiaTallas(
        categoria: 'Dama',
        tipoCalzado: 'Sandalias, Tacones y Zapatillas',
        equivalenciasCm: {
          '34': '22.0 cm',
          '35': '22.8 cm',
          '36': '23.5 cm',
          '37': '24.2 cm',
          '38': '25.0 cm',
        },
      ),
      // CABALLERO - Tenis y Deportivos
      GuiaTallas(
        categoria: 'Caballero',
        tipoCalzado: 'Tenis y Deportivos',
        equivalenciasCm: {
          '39': '25.0 cm',
          '40': '25.5 cm',
          '41': '26.5 cm',
          '42': '27.0 cm',
          '43': '28.0 cm',
        },
      ),
      // CABALLERO - Casual y Formal
      GuiaTallas(
        categoria: 'Caballero',
        tipoCalzado: 'Casual y Formal',
        equivalenciasCm: {
          '38': '24.5 cm',
          '39': '25.0 cm',
          '40': '25.8 cm',
          '41': '26.8 cm',
          '42': '27.5 cm',
        },
      ),
      // INFANTIL - Calzado Infantil
      GuiaTallas(
        categoria: 'Infantil',
        tipoCalzado: 'Calzado Infantil',
        equivalenciasCm: {
          '28': '17.5 cm',
          '29': '18.0 cm',
          '30': '19.0 cm',
          '31': '19.5 cm',
          '32': '20.5 cm',
        },
      ),
    ];
  }
}

// Función global para mostrar el modal con diseño elegante y logo de calzado
void mostrarGuiaTallasModal(BuildContext context, String categoriaActual) {
  final guias = RepositorioGuiaTallas.obtenerGuias()
      .where((g) => g.categoria.toLowerCase() == categoriaActual.toLowerCase())
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCF9F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador superior de arrastre
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Cabecera con Icono de Calzado / Patín elegante
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B1229),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.roller_skating_rounded, // Logo/icono de calzado
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guía de Tallas',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              categoriaActual.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF6B1229),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Colors.black87),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Encuentra tu medida exacta en centímetros (cm)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Color(0xFFE8DEDC)),
                ),
                // Lista de tipos de calzado
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: guias.length,
                    itemBuilder: (context, index) {
                      final guia = guias[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFEEDFDB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFFBF285D)),
                                const SizedBox(width: 8),
                                Text(
                                  guia.tipoCalzado,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B1229),
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: guia.equivalenciasCm.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Talla ${entry.key}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9F1EE),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFE6D2CD)),
                                        ),
                                        child: Text(
                                          entry.value,
                                          style: TextStyle( // <- Quitamos el "const" de aquí
                                            fontWeight: FontWeight.w800, // <- Asegúrate de que sea punto simple (.w800)
                                            color: const Color(0xFF6B1229),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}