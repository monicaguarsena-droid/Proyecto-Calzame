import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/configuracion_tienda_service.dart';

class ConfiguracionTiendaScreen extends StatefulWidget {
  const ConfiguracionTiendaScreen({super.key});

  @override
  State<ConfiguracionTiendaScreen> createState() =>
      _ConfiguracionTiendaScreenState();
}

class _ConfiguracionTiendaScreenState extends State<ConfiguracionTiendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _horarioController = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _recogidaEnTienda = true;
  bool _domicilios = false;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final datos = await ConfiguracionTiendaService.cargar();
      if (!mounted) return;

      setState(() {
        _nombreController.text = datos.nombre;
        _direccionController.text = datos.direccion;
        _telefonoController.text = datos.telefono;
        _correoController.text = datos.correo;
        _horarioController.text = datos.horario;
        _recogidaEnTienda = datos.recogidaEnTienda;
        _domicilios = datos.domicilios;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _mostrarMensaje(
        'No se pudo cargar la configuración: $error',
        esError: true,
      );
    }
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await ConfiguracionTiendaService.guardar(
        DatosTienda(
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          correo: _correoController.text.trim(),
          horario: _horarioController.text.trim(),
          recogidaEnTienda: _recogidaEnTienda,
          domicilios: _domicilios,
        ),
      );

      if (!mounted) return;
      _mostrarMensaje('Configuración de tienda guardada.');
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(
        'No se pudo guardar la configuración: $error',
        esError: true,
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? ColoresApp.error : ColoresApp.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        title: const Text('Configuración de tienda'),
        foregroundColor: ColoresApp.primary,
        backgroundColor: ColoresApp.background,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: ColoresApp.primary),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _cargarConfiguracion,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                    _encabezado(),
                    const SizedBox(height: 24),
                    _tituloSeccion('Información del negocio'),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _nombreController,
                      label: 'Nombre de la tienda',
                      icon: Icons.storefront_outlined,
                      obligatorio: true,
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _direccionController,
                      label: 'Dirección',
                      icon: Icons.location_on_outlined,
                      obligatorio: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    _tituloSeccion('Contacto y atención'),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _correoController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (valor) {
                        final correo = valor?.trim() ?? '';
                        if (correo.isNotEmpty &&
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(correo)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _campo(
                      controller: _horarioController,
                      label: 'Horario de atención',
                      icon: Icons.access_time_outlined,
                      obligatorio: true,
                    ),
                    const SizedBox(height: 24),
                    _tituloSeccion('Modalidad de entrega'),
                    const SizedBox(height: 12),
                    _opcionesEntrega(),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardarConfiguracion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColoresApp.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Guardar cambios',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresApp.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.store_mall_directory_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu tienda, a tu manera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Actualiza la información que verán tus clientes.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: ColoresApp.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obligatorio = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColoresApp.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
        ),
      ),
      validator:
          validator ??
          (valor) {
            if (obligatorio && (valor == null || valor.trim().isEmpty)) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
    );
  }

  Widget _opcionesEntrega() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _recogidaEnTienda,
            onChanged: (valor) => setState(() => _recogidaEnTienda = valor),
            activeThumbColor: ColoresApp.primary,
            secondary: const Icon(
              Icons.store_outlined,
              color: ColoresApp.primary,
            ),
            title: const Text(
              'Recogida en tienda',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('El cliente recoge su pedido en el local.'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(
            value: _domicilios,
            onChanged: (valor) => setState(() => _domicilios = valor),
            activeThumbColor: ColoresApp.primary,
            secondary: const Icon(
              Icons.delivery_dining_outlined,
              color: ColoresApp.primary,
            ),
            title: const Text(
              'Entregas a domicilio',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Habilita pedidos con entrega a domicilio.'),
          ),
        ],
      ),
    );
  }
}
