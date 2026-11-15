import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/configuracion_tienda_service.dart';

class UbicacionTiendaScreen extends StatefulWidget {
  const UbicacionTiendaScreen({super.key});

  @override
  State<UbicacionTiendaScreen> createState() => _UbicacionTiendaScreenState();
}

class _UbicacionTiendaScreenState extends State<UbicacionTiendaScreen> {
  DatosTienda _datosTienda = DatosTienda.predeterminada;

  @override
  void initState() {
    super.initState();
    _cargarDatosTienda();
  }

  Future<void> _cargarDatosTienda() async {
    try {
      final datos = await ConfiguracionTiendaService.cargar();
      if (!mounted) return;
      setState(() => _datosTienda = datos);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar la información de la tienda: $error'),
          backgroundColor: ColoresApp.error,
        ),
      );
    }
  }

  // Función para abrir Google Maps de forma externa con la ubicación exacta
  Future<void> _abrirGoogleMapsExterno() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent('${_datosTienda.nombre} ${_datosTienda.direccion}')}',
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _datosTienda.nombre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primary,
                              ),
                            ),
                            Text(
                              _textoModalidadEntrega,
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
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: ColoresApp.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _datosTienda.direccion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: ColoresApp.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _datosTienda.horario,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColoresApp.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_datosTienda.telefono.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _filaContacto(Icons.phone_outlined, _datosTienda.telefono),
                  ],
                  if (_datosTienda.correo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _filaContacto(Icons.email_outlined, _datosTienda.correo),
                  ],
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
                            child: Text(
                              _datosTienda.nombre,
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

  String get _textoModalidadEntrega {
    if (_datosTienda.recogidaEnTienda && _datosTienda.domicilios) {
      return 'Recogida en tienda y entregas a domicilio';
    }
    if (_datosTienda.recogidaEnTienda) {
      return 'Punto de recogida en tienda (No hay domicilios)';
    }
    if (_datosTienda.domicilios) return 'Entregas a domicilio disponibles';
    return 'Modalidades de entrega no configuradas';
  }

  Widget _filaContacto(IconData icono, String valor) {
    return Row(
      children: [
        Icon(icono, color: ColoresApp.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}