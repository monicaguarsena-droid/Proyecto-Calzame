import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/carrito.dart';

class CompraScreen extends StatefulWidget {
  final List<ItemCarrito> items;
  final double total;

  const CompraScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<CompraScreen> createState() => _CompraScreenState();
}

class _CompraScreenState extends State<CompraScreen> {
  bool _isProcessing = false;

  // Datos editables de envío
  String _nombre = 'Evelyn Arrigui';
  String _cedula = '1234567890';
  String _telefono = '+57 300 123 4567';
  String _direccion = 'Calle Principal #12-34, Garzón, Huila';

  // Método de pago seleccionado
  String _metodoPago = 'Nequi';
  String _detallePago = 'Cuenta vinculada: 300 123 4567';

  // Tipo y costo de envío
  final String _tipoEnvio = 'Estándar';
  final double _costoEnvio = 0.0;

  int get _cantidadTotalProductos {
    return widget.items.fold(0, (sum, item) => sum + item.cantidad);
  }

  // Modal para editar datos de envío
  void _editarEnvioModal() {
    final nameCtrl = TextEditingController(text: _nombre);
    final cedulaCtrl = TextEditingController(text: _cedula);
    final telCtrl = TextEditingController(text: _telefono);
    final dirCtrl = TextEditingController(text: _direccion);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar Datos de Envío',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
              const SizedBox(height: 10),
              TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: 'Cédula')),
              const SizedBox(height: 10),
              TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
              const SizedBox(height: 10),
              TextField(controller: dirCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _nombre = nameCtrl.text;
                      _cedula = cedulaCtrl.text;
                      _telefono = telCtrl.text;
                      _direccion = dirCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Modal para seleccionar método de pago
  void _seleccionarPagoModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el medio de pago',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: const Text('Nequi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pago instantáneo por celular'),
                value: 'Nequi',
                groupValue: _metodoPago,
                activeColor: ColoresApp.primary,
                onChanged: (val) {
                  setState(() {
                    _metodoPago = val!;
                    _detallePago = 'Cuenta vinculada: 300 123 4567';
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Daviplata', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Transferencia rápida'),
                value: 'Daviplata',
                groupValue: _metodoPago,
                activeColor: ColoresApp.primary,
                onChanged: (val) {
                  setState(() {
                    _metodoPago = val!;
                    _detallePago = 'Cuenta vinculada: 300 123 4567';
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Tarjeta de Crédito / Débito', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Visa terminada en •••• 4242'),
                value: 'Tarjeta',
                groupValue: _metodoPago,
                activeColor: ColoresApp.primary,
                onChanged: (val) {
                  setState(() {
                    _metodoPago = val!;
                    _detallePago = 'Visa terminada en •••• 4242';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _procesarCompra() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('¡Compra exitosa!'),
          ]),
          content: const Text(
            'Tu pedido ha sido procesado correctamente y llegará muy pronto.',
            style: TextStyle(color: ColoresApp.textSecondary, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Limpiar el carrito tras la compra exitosa
                CarritoService.itemsCarrito.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false,
                );
              },
              child: const Text('Volver al inicio', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalGeneral = widget.total + _costoEnvio;

    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Finalizar Compra",
          style: TextStyle(
            color: ColoresApp.primary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lista desplegable con el detalle de TODOS los productos seleccionados
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen del pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColoresApp.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColoresApp.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_cantidadTotalProductos artículos',
                      style: const TextStyle(fontSize: 12, color: ColoresApp.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              // Renderiza cada producto del carrito en la lista
              for (int i = 0; i < widget.items.length; i++) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.items[i].imagen,
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 65,
                          height: 65,
                          color: ColoresApp.surfaceVariant,
                          child: const Icon(Icons.image_not_supported, color: ColoresApp.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.items[i].titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cantidad: ${widget.items[i].cantidad}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5A5A5A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(widget.items[i].precio * widget.items[i].cantidad).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ColoresApp.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < widget.items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(height: 1),
                  ),
              ],
            ], padding: 18),
            const SizedBox(height: 20),

            // 2. Datos de Envío ordenados por fila
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: ColoresApp.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Datos de envío',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.primary),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _editarEnvioModal,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _datoEnvioFila('Nombre:', _nombre),
              const SizedBox(height: 6),
              _datoEnvioFila('Cédula:', _cedula),
              const SizedBox(height: 6),
              _datoEnvioFila('Teléfono:', _telefono),
              const SizedBox(height: 6),
              _datoEnvioFila('Dirección:', _direccion),
            ]),
            const SizedBox(height: 10),

            // Tipo de envío fuera del cuadro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: ColoresApp.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Tipo de envío: $_tipoEnvio (Entrega estimada en 3-5 días)',
                    style: const TextStyle(fontSize: 12, color: ColoresApp.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Método de Pago
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payment, color: ColoresApp.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Método de pago',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.primary),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _seleccionarPagoModal,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(color: ColoresApp.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _metodoPago,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ColoresApp.primary),
              ),
              const SizedBox(height: 2),
              Text(
                _detallePago,
                style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A4A), fontWeight: FontWeight.w500),
              ),
            ]),
            const SizedBox(height: 20),

            // 4. Resumen de precios
            _buildCard([
              _filaResumen('Subtotal', '\$${widget.total.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              _filaResumen('Envío ($_tipoEnvio)', _costoEnvio == 0 ? 'Gratis' : '\$${_costoEnvio.toStringAsFixed(0)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1),
              ),
              _filaResumen('Total a pagar', '\$${totalGeneral.toStringAsFixed(0)}', esTotal: true),
            ]),
            const SizedBox(height: 30),

            // 5. Botón Pagar ahora
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _procesarCompra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Pagar de forma segura',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 15, color: Color(0xFF6B6B6B)),
                  SizedBox(width: 5),
                  Text(
                    'Pagos 100% seguros y encriptados',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children, {double padding = 16}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _datoEnvioFila(String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            etiqueta,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColoresApp.primary),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A4A), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _filaResumen(String titulo, String valor, {bool esTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: esTotal ? 15 : 13,
            fontWeight: esTotal ? FontWeight.bold : FontWeight.w500,
            color: esTotal ? ColoresApp.primary : const Color(0xFF4A4A4A),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: esTotal ? 19 : 14,
            fontWeight: FontWeight.w800,
            color: ColoresApp.primary,
          ),
        ),
      ],
    );
  }
}