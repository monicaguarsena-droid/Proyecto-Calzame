import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:photo_manager/photo_manager.dart';

class AdminImageSelector extends StatefulWidget {
  final File? imagen;
  final String? imagenUrl; // Foto actual del producto (modo edición)
  final bool habilitado;
  final Function(File) onImagenSeleccionada;

  // Permiten arrastrar/hacer zoom a la foto y luego recortar el encuadre visible
  final GlobalKey capturaKey;
  final TransformationController encuadreController;

  const AdminImageSelector({
    super.key,
    required this.imagen,
    required this.onImagenSeleccionada,
    required this.capturaKey,
    required this.encuadreController,
    this.imagenUrl,
    this.habilitado = true,
  });

  // true si el admin movió o hizo zoom a la foto
  static bool encuadreModificado(TransformationController controller) =>
      controller.value != Matrix4.identity();

  // Convierte lo que se ve en el recuadro en un archivo PNG listo para subir
  static Future<File> capturarEncuadre(GlobalKey capturaKey) async {
    final boundary =
        capturaKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image imagen = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
    final archivo = File(
      '${Directory.systemTemp.path}/producto_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await archivo.writeAsBytes(bytes!.buffer.asUint8List());
    return archivo;
  }

  @override
  State<AdminImageSelector> createState() => _AdminImageSelectorState();
}

class _AdminImageSelectorState extends State<AdminImageSelector> {
  static const _extensionesImagen = ['jpg', 'jpeg', 'png', 'webp', 'avif'];

  bool _arrastrando = false; // true mientras hay un archivo encima del recuadro

  // Emulador Android: al soltar una foto sobre el emulador, este la copia a Descargas.
  // La app detecta esa foto nueva y la pone sola en el recuadro (solo en modo debug).
  static const _canalMedia = MethodChannel('mimos/media');
  bool _vigilando = false;
  Timer?
  _esperaAviso; // agrupa los varios avisos que Android manda por una sola foto

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid && kDebugMode) _iniciarVigilancia();
  }

  @override
  void dispose() {
    _esperaAviso?.cancel();
    if (_vigilando) {
      PhotoManager.removeChangeCallback(_alCambiarGaleria);
      PhotoManager.stopChangeNotify();
    }
    super.dispose();
  }

  Future<void> _iniciarVigilancia() async {
    const opcion = PermissionRequestOption(
      androidPermission: AndroidPermission(
        type: RequestType.image,
        mediaLocation: false,
      ),
    );
    // Primero se consulta; solo se pide si aún no está concedido
    var permiso = await PhotoManager.getPermissionState(requestOption: opcion);
    if (!permiso.hasAccess) {
      permiso =
          await PhotoManager.requestPermissionExtend(
            requestOption: opcion,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => PermissionState.denied,
          );
    }
    if (!permiso.hasAccess || !mounted) return;

    // El permiso ya se verificó arriba; evita que el plugin lo vuelva a pedir en cada consulta
    await PhotoManager.setIgnorePermissionCheck(true);
    PhotoManager.addChangeCallback(_alCambiarGaleria);
    await PhotoManager.startChangeNotify();
    _vigilando = true;
  }

  // Al soltar una foto, el emulador borra y vuelve a crear el archivo en Descargas
  // (si ya existía uno con el mismo nombre conserva el mismo id). Android avisa en medio
  // de ese proceso, a veces como "delete", así que se espera un momento y se revisa el id.
  void _alCambiarGaleria(MethodCall llamada) {
    final datos = llamada.arguments as Map?;
    final id = datos?['id']?.toString();
    if (id == null || datos?['mediaType'] != 1) return; // 1 = imagen

    _esperaAviso?.cancel();
    _esperaAviso = Timer(
      const Duration(milliseconds: 1200),
      () => _cargarFotoArrastrada(id),
    );
  }

  Future<void> _cargarFotoArrastrada(String id) async {
    if (!mounted || !habilitado) return;

    // En el emulador la foto queda "pendiente" hasta que Android la escanea
    try {
      await _canalMedia.invokeMethod('escanearDescargas');
    } catch (_) {}
    if (!mounted) return;

    final foto = await AssetEntity.fromId(id);
    if (foto == null || foto.type != AssetType.image)
      return; // se borró de verdad

    // Leer los bytes directamente (sin caché) y guardarlos con un nombre único
    final bytes = await foto.originBytes;
    if (bytes == null || !mounted) return;
    final archivo = File(
      '${Directory.systemTemp.path}/arrastrada_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await archivo.writeAsBytes(bytes);
    if (!mounted) return;

    _usarImagen(archivo);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto recibida desde el escritorio'),
        backgroundColor: Colors.green,
      ),
    );
  }

  File? get imagen => widget.imagen;
  String? get imagenUrl => widget.imagenUrl;
  bool get habilitado => widget.habilitado;
  TransformationController get encuadreController => widget.encuadreController;

  void _usarImagen(File archivo) {
    encuadreController.value =
        Matrix4.identity(); // Foto nueva: encuadre desde cero
    widget.onImagenSeleccionada(archivo);
  }

  // Archivo soltado desde el escritorio (macOS / Windows / Linux)
  void _alSoltarArchivo(DropDoneDetails detalles) {
    setState(() => _arrastrando = false);
    if (!habilitado) return;

    final imagenes = detalles.files.where((f) {
      final nombre = f.name.toLowerCase();
      return _extensionesImagen.any((ext) => nombre.endsWith('.$ext'));
    });

    if (imagenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se permiten imágenes (jpg, png, webp, avif)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _usarImagen(File(imagenes.first.path));
  }

  // Modal inferior para elegir Galería o Cámara
  Future<void> _elegirOrigen(BuildContext context) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar foto del producto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFBF285D),
                ),
                title: const Text('Elegir de la Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFBF285D)),
                title: const Text('Tomar con la Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null) {
      final XFile? foto = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (foto != null) _usarImagen(File(foto.path));
    }
  }

  Widget _botonFlotante({
    required IconData icono,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icono, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      enable: habilitado,
      onDragEntered: (_) => setState(() => _arrastrando = true),
      onDragExited: (_) => setState(() => _arrastrando = false),
      onDragDone: _alSoltarArchivo,
      child: _construirRecuadro(context),
    );
  }

  Widget _construirRecuadro(BuildContext context) {
    final bool tieneFoto =
        imagen != null || (imagenUrl != null && imagenUrl!.isNotEmpty);

    if (!tieneFoto) {
      return GestureDetector(
        onTap: habilitado ? () => _elegirOrigen(context) : null,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: _arrastrando ? const Color(0xFFFCE4EC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _arrastrando
                  ? const Color(0xFFBF285D)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _arrastrando
                    ? Icons.file_download_rounded
                    : Icons.add_a_photo_rounded,
                size: 48,
                color: const Color(0xFFBF285D),
              ),
              const SizedBox(height: 8),
              Text(
                _arrastrando
                    ? 'Suelta la imagen aquí'
                    : 'Toca o arrastra aquí la foto del producto',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final Widget foto = imagen != null
        ? Image.file(imagen!, fit: BoxFit.contain)
        : Image.network(
            imagenUrl!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_rounded,
              size: 40,
              color: Colors.grey,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBF285D),
              width: _arrastrando ? 4 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Solo esta parte se recorta al guardar (sin los botones)
                RepaintBoundary(
                  key: widget.capturaKey,
                  child: Container(
                    color: Colors.white,
                    child: InteractiveViewer(
                      transformationController: encuadreController,
                      panEnabled: habilitado,
                      scaleEnabled: habilitado,
                      minScale: 0.5,
                      maxScale: 4,
                      // Margen infinito: la foto se queda donde el admin la suelte
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: SizedBox.expand(child: foto),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _botonFlotante(
                        icono: Icons.center_focus_strong,
                        onTap: habilitado
                            ? () =>
                                  encuadreController.value = Matrix4.identity()
                            : null,
                      ),
                      const SizedBox(width: 6),
                      _botonFlotante(
                        icono: Icons.photo_camera,
                        onTap: habilitado ? () => _elegirOrigen(context) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Arrastra la foto para acomodarla · pellizca para hacer zoom',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
