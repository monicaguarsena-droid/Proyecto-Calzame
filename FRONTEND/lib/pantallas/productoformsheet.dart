import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/pantallas/adminimageselector.dart';
import 'package:frontend/servicios/admin_product_service.dart';

// Formulario de crear/editar producto; se abre como bottom sheet sobre el panel
class ProductFormSheet extends StatefulWidget {
  final ProductoModel? producto; // null = crear, con valor = editar

  const ProductFormSheet({super.key, this.producto});

  // Abre el formulario y devuelve true si se guardó algo
  static Future<bool> abrir(BuildContext context, {ProductoModel? producto}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(producto: producto),
    );
    return guardado == true;
  }

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  static const Color _colorPrincipal = Color(0xFFBF285D);

  final _formKey = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
  late final _descCtrl = TextEditingController(text: widget.producto?.descripcion ?? '');
  late final _precioCtrl = TextEditingController(text: widget.producto?.precio.toString() ?? '');

  // Encuadre de la foto (arrastrar / zoom)
  final _capturaKey = GlobalKey();
  final _encuadreCtrl = TransformationController();

  File? _imagen;
  bool _guardando = false;
  bool get _esEdicion => widget.producto != null;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _encuadreCtrl.dispose();
    super.dispose();
  }

  // Si el admin movió la foto, se sube el recorte tal como lo dejó en el recuadro
  Future<File?> _imagenParaSubir() async {
    final bool hayFoto = _imagen != null || (widget.producto?.imagenUrl?.isNotEmpty ?? false);
    if (hayFoto && AdminImageSelector.encuadreModificado(_encuadreCtrl)) {
      return AdminImageSelector.capturarEncuadre(_capturaKey);
    }
    return _imagen;
  }
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_esEdicion && _imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final precio = double.parse(_precioCtrl.text.trim());
      final imagen = await _imagenParaSubir();

      if (_esEdicion) {
        await AdminProductService.actualizarProducto(
          id: widget.producto!.id,
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          precio: precio,
          imagen: imagen, // null = conserva la foto actual
        );
      } else {
        await AdminProductService.crearProducto(
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          precio: precio,
          imagen: imagen!,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo(TextEditingController ctrl, String etiqueta, {int maxLines = 1, bool esNumero = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: esNumero ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixText: esNumero ? '\$ ' : null,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
          if (esNumero && double.tryParse(v.trim()) == null) return 'Ingresa un número válido';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sube el formulario cuando aparece el teclado
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F4F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barrita para indicar que se puede deslizar hacia abajo
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(
                  _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _colorPrincipal),
                ),
                const SizedBox(height: 16),
                AdminImageSelector(
                  imagen: _imagen,
                  imagenUrl: widget.producto?.imagenUrl,
                  habilitado: !_guardando,
                  capturaKey: _capturaKey,
                  encuadreController: _encuadreCtrl,
                  onImagenSeleccionada: (file) => setState(() => _imagen = file),
                ),
                const SizedBox(height: 16),
                _campo(_nombreCtrl, 'Nombre del producto'),
                _campo(_descCtrl, 'Descripción', maxLines: 2),
                _campo(_precioCtrl, 'Precio', esNumero: true),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR PRODUCTO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}