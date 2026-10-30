import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/cors/colores.dart';

class UbicacionTiendaScreen extends StatelessWidget {
  const UbicacionTiendaScreen({super.key});

  // Función para abrir Google Maps de forma externa con la ubicación exacta
  Future<void> _abrirGoogleMapsExterno() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=Calzado+Mar+and+Paz+Garzon+Huila',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir el mapa externo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ubicación del Local',
          style: TextStyle(
            color: ColoresApp.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta Informativa del Local
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresApp.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColoresApp.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: ColoresApp.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calzado Mar & Paz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primary,
                              ),
                            ),
                            Text(
                              'Punto de recogida en tienda (No hay domicilios)',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColoresApp.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: ColoresApp.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cra. 11 #5-55 Local 3, Garzón, Huila',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time_filled, color: ColoresApp.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lunes a Sábado: 8:00 AM - 7:00 PM',
                        style: TextStyle(
                          fontSize: 13,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Título de la sección del mini mapa
            const Text(
              'Mini Mapa de Ubicación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
            const SizedBox(height: 10),

            // Mini Mapa Estilizado con Relieve y Pin del Local (Interactivo)
            GestureDetector(
              onTap: _abrirGoogleMapsExterno,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE6EE),
                    border: Border.all(color: ColoresApp.border, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black45,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pin y etiqueta central con relieve
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColoresApp.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Calzado Mar & Paz • Garzón, Huila',
                              style: TextStyle(
                                color: ColoresApp.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Etiqueta flotante superior derecha
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Ver ubicación',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón principal ubicado debajo del mapa
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _abrirGoogleMapsExterno,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Ver ubicación en Google Maps',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}