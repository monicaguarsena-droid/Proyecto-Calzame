import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/api_config.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/adminagregarcategoria.dart'; // AJUSTA la ruta
import 'package:frontend/servicios/categorias_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mismo baseUrl que usa CategoriaService
String get _baseUrl => '${ApiConfig.baseUrl}/productos';

class _FotoColor {
  File? archivo;
  String color = '';
}

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  static const _categorias = ['Dama', 'Niña', 'Caballero'];
  static const _todasTallas = ['36', '37', '38', '39', '40', '41'];

  final _picker = ImagePicker();
  final _fotos = List.generate(4, (_) => _FotoColor());
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  String _categoria = _categorias.first;
  final Set<String> _tallas = {};
  bool _guardando = false;

  // Tipos de calzado cargados desde la base de datos
  List<String> _tipos = [];
  String? _tipoCalzado;
  bool _cargandoTipos = true;
  String? _errorTipos;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  // ---------- Tipos de calzado ----------

  Future<void> _cargarTipos() async {
    setState(() {
      _cargandoTipos = true;
      _errorTipos = null;
    });
    try {
      final lista = await CategoriaService.listar();

      final nombres = <String>[];
      for (final item in lista) {
        final map = Map<String, dynamic>.from(item as Map);
        final nombre =
            (map['nombre'] ?? map['Nombre'] ?? map['titulo'] ?? '')
                .toString()
                .trim();
        if (nombre.isNotEmpty) nombres.add(nombre);
      }

      if (!mounted) return;
      setState(() {
        _tipos = nombres;
        if (!_tipos.contains(_tipoCalzado)) {
          _tipoCalzado = _tipos.isNotEmpty ? _tipos.first : null;
        }
        _cargandoTipos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorTipos = 'No se pudieron cargar los tipos de calzado';
        _cargandoTipos = false;
      });
    }
  }

  Future<void> _agregarNuevoTipo() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminAgregarCategoria()),
    );
    if (creado == true) _cargarTipos();
  }

  // ---------- Fotos ----------

  Future<void> _elegirFoto(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _fotos[index].archivo = File(picked.path));
    if (_fotos[index].color.isEmpty) await _pedirColor(index);
  }

  Future<void> _pedirColor(int index) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoColor(inicial: _fotos[index].color),
    );
    if (nombre != null && nombre.trim().isNotEmpty && mounted) {
      setState(() => _fotos[index].color = nombre.trim());
    }
  }

  void _quitarFoto(int index) {
    setState(() {
      _fotos[index].archivo = null;
      _fotos[index].color = '';
    });
  }

  // ---------- Guardar ----------

  void _mostrar(String mensaje, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? ColoresApp.error : ColoresApp.primary,
      ),
    );
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final fotos = _fotos.where((f) => f.archivo != null).toList();
    final precio = double.tryParse(_precioCtrl.text.trim().replaceAll(',', '.'));
    final stock = int.tryParse(_stockCtrl.text.trim());

    if (fotos.isEmpty) return _mostrar('Agrega al menos una fotografía');
    if (fotos.any((f) => f.color.isEmpty)) {
      return _mostrar('Cada foto necesita un nombre de color');
    }
    if (_nombreCtrl.text.trim().isEmpty) return _mostrar('Escribe el nombre');
    if (_tipoCalzado == null) return _mostrar('Selecciona un tipo de calzado');
    if (precio == null || precio <= 0) return _mostrar('Precio no válido');
    if (stock == null || stock < 0) return _mostrar('Stock no válido');
    if (_tallas.isEmpty) return _mostrar('Selecciona al menos una talla');

    setState(() => _guardando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('jwt_token');
      if (token == null || token.isEmpty) {
        setState(() => _guardando = false);
        return _mostrar('Inicia sesión como administrador para continuar.');
      }

      final tallas = _tallas.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/crear'))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['Nombre'] = _nombreCtrl.text.trim()
        ..fields['Categoria'] = _categoria
        ..fields['TipoCalzado'] = _tipoCalzado!
        ..fields['Precio'] = precio.toString()
        ..fields['Stock'] = stock.toString()
        ..fields['Descripcion'] = _descripcionCtrl.text.trim()
        ..fields['Tallas'] = jsonEncode(tallas)
        // indexImagen = posición de la foto dentro de los archivos enviados
        ..fields['coloresData'] = jsonEncode([
          for (var i = 0; i < fotos.length; i++)
            {'color': fotos[i].color, 'indexImagen': i},
        ]);

      for (final foto in fotos) {
        request.files.add(
          await http.MultipartFile.fromPath('imagenes', foto.archivo!.path),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        if (!mounted) return;
        _mostrar('Producto guardado con éxito', error: false);
        Navigator.pop(context, true);
      } else {
        String mensaje = 'Error al guardar (${response.statusCode})';
        try {
          mensaje = (jsonDecode(response.body)['error'] ?? mensaje).toString();
        } catch (_) {}
        if (mounted) _mostrar(mensaje);
      }
    } catch (e) {
      if (mounted) _mostrar('No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: ColoresApp.primary, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    const Text(
                      'AGREGAR PRODUCTO',
                      style: TextStyle(
                        color: ColoresApp.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titulo('Fotografías del producto', grande: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (var i = 0; i < _fotos.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: _slotFoto(i)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    _titulo('Nombre del producto'),
                    const SizedBox(height: 6),
                    _campo(_nombreCtrl, 'Ej. Sandalia de tiras beige'),
                    const SizedBox(height: 14),
                    _titulo('Categoría'),
                    const SizedBox(height: 6),
                    _opciones(_categorias, _categoria,
                        (v) => setState(() => _categoria = v)),
                    const SizedBox(height: 12),
                    _titulo('Tipo de calzado'),
                    const SizedBox(height: 6),
                    _selectorTipos(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _titulo('Precio'),
                              const SizedBox(height: 6),
                              _campo(_precioCtrl, 'Ej. \$129',
                                  teclado: const TextInputType.numberWithOptions(
                                      decimal: true)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _titulo('Stock / unidades'),
                              const SizedBox(height: 6),
                              _campo(_stockCtrl, 'Ej. 24',
                                  teclado: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _titulo('Descripción del calzado'),
                    const SizedBox(height: 6),
                    _campo(
                      _descripcionCtrl,
                      'Ej. Diseño elegante con tiras delicadas, tacón estable y acabado suave para uso diario.',
                      lineas: 3,
                    ),
                    const SizedBox(height: 14),
                    _titulo('Tallas de calzado'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        for (final talla in _todasTallas)
                          _chip(
                            talla,
                            _tallas.contains(talla),
                            () => setState(() {
                              _tallas.contains(talla)
                                  ? _tallas.remove(talla)
                                  : _tallas.add(talla);
                            }),
                            ancho: 50,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar producto',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorTipos() {
    if (_cargandoTipos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_errorTipos != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _errorTipos!,
              style: const TextStyle(
                  fontSize: 12, color: ColoresApp.textSecondary),
            ),
          ),
          TextButton(onPressed: _cargarTipos, child: const Text('Reintentar')),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tipo in _tipos)
          _chip(tipo, tipo == _tipoCalzado,
              () => setState(() => _tipoCalzado = tipo)),
        GestureDetector(
          onTap: _agregarNuevoTipo,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresApp.primary),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: ColoresApp.primary),
                SizedBox(width: 4),
                Text(
                  'Nuevo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _slotFoto(int index) {
    final foto = _fotos[index];
    final tieneFoto = foto.archivo != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _elegirFoto(index),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: tieneFoto
                        ? Image.file(foto.archivo!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF1E8E2),
                            child: const Icon(Icons.add,
                                color: ColoresApp.primary, size: 26),
                          ),
                  ),
                  if (tieneFoto)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _quitarFoto(index),
                        child: const CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: tieneFoto ? () => _pedirColor(index) : null,
            child: Text(
              foto.color.isNotEmpty ? foto.color : 'Color ${index + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ColoresApp.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto, {bool grande = false}) => Text(
        texto,
        style: TextStyle(
          fontSize: grande ? 15 : 12,
          fontWeight: FontWeight.w800,
          color: ColoresApp.primary,
        ),
      );

  Widget _campo(
    TextEditingController ctrl,
    String hint, {
    int lineas = 1,
    TextInputType? teclado,
  }) {
    OutlineInputBorder borde(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );
    return TextField(
      controller: ctrl,
      minLines: lineas,
      maxLines: lineas,
      keyboardType: teclado,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: ColoresApp.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: borde(ColoresApp.border),
        focusedBorder: borde(ColoresApp.primary),
        border: borde(ColoresApp.border),
      ),
    );
  }

  Widget _opciones(
      List<String> items, String actual, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items) _chip(item, item == actual, () => onTap(item)),
      ],
    );
  }

  Widget _chip(String texto, bool activo, VoidCallback onTap, {double? ancho}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ancho,
        alignment: ancho != null ? Alignment.center : null,
        padding: EdgeInsets.symmetric(
            horizontal: ancho != null ? 0 : 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? ColoresApp.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: activo ? ColoresApp.primary : ColoresApp.border),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : ColoresApp.primary,
          ),
        ),
      ),
    );
  }
}

class _DialogoColor extends StatefulWidget {
  final String inicial;
  const _DialogoColor({required this.inicial});

  @override
  State<_DialogoColor> createState() => _DialogoColorState();
}

class _DialogoColorState extends State<_DialogoColor> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Qué color es?', style: TextStyle(fontSize: 16)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Ej. Beige, Negro, Rosa'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}