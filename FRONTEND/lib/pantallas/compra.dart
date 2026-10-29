import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/perfil.dart';
import 'package:frontend/pantallas/pedido.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompraScreen extends StatefulWidget {
  final List<ItemCarrito> items;
  final double total;

  const CompraScreen({super.key, required this.items, required this.total});

  @override
  State<CompraScreen> createState() => _CompraScreenState();
}

class _CompraScreenState extends State<CompraScreen> {
  bool _isProcessing = false;
  final int _tab = 1; // Carrito / Proceso de compra activo

  // Datos de contacto para la recogida
  String _nombre = 'Sofia Pérez';
  String _cedula = '1234567890';
  String _telefono = '+57 300 123 4567';
  final String _puntoRecogida =
      'Tienda CalzaMe - Calle Principal #12-34, Garzón, Huila';

  // Método de pago seleccionado
  String _metodoPago = 'Nequi';
  String _detallePago = 'Cuenta vinculada: 300 123 4567';

  final String baseUrl = 'http://10.0.2.2:3000/api';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Si el nombre, cédula o correo están guardados, los asignamos.
      // Si no hay cédula guardada aún, dejamos un texto por defecto o vacío.
      _nombre = prefs.getString('nombre') ?? _nombre;
      _cedula = prefs.getString('cedula') ?? _cedula;
      _telefono = prefs.getString('telefono') ?? _telefono;
    });
  }

  int get _cantidadTotalProductos {
    return widget.items.fold(0, (sum, item) => sum + item.cantidad);
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CarritoScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FavoritosScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PerfilScreen()),
      );
    }
  }

  Future<void> _enviarPedidoAlServidor() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pedidos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario_id': 1, // ID del cliente
          'total': widget.total,
          'productos': widget.items.map((item) {
            return {
              'nombre': item.titulo,
              'precio': item.precio,
              'cantidad': item.cantidad,
              'talla': item.talla,
              'color': item.color,
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 201) {
        print('Pedido sincronizado con el backend exitosamente');
      }
    } catch (e) {
      print('Error al conectar con el servidor backend: $e');
    }
  }

  // Modal para editar datos de contacto
  void _editarContactoModal() {
    final nameCtrl = TextEditingController(text: _nombre);
    final cedulaCtrl = TextEditingController(text: _cedula);
    final telCtrl = TextEditingController(text: _telefono);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                'Editar Datos de Contacto',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cedulaCtrl,
                decoration: const InputDecoration(labelText: 'Cédula'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: telCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _nombre = nameCtrl.text;
                      _cedula = cedulaCtrl.text;
                      _telefono = telCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona el medio de pago',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                title: const Text(
                  'Nequi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                title: const Text(
                  'Daviplata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                title: const Text(
                  'Tarjeta de Crédito / Débito',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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

  void _procesarCompra() async {
    setState(() => _isProcessing = true);

    await _enviarPedidoAlServidor();

    double totalGeneral = widget.total;

    // Guardar el pedido en el historial global
    final nuevoPedido = Pedido(
      idPedido: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
      fechaHora: DateTime.now(),
      items: List.from(widget.items),
      total: totalGeneral,
      metodoPago: _metodoPago,
      direccion: _puntoRecogida,
      telefono: _telefono,
      nombreCliente: _nombre,
      estado: 'Listo para recoger',
    );

    HistorialPedidosService.agregarPedido(nuevoPedido);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('¡Pedido registrado!'),
            ],
          ),
          content: const Text(
            'Tu pedido ha sido registrado con éxito. Acércate a la tienda para retirarlo.',
            style: TextStyle(color: ColoresApp.textSecondary, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColoresApp.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  await CarritoService.vaciar();
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString().replaceFirst('Exception: ', ''),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false,
                );
              },
              child: const Text(
                'Volver al inicio',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalGeneral = widget.total;

    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ColoresApp.primary,
            size: 24,
          ),
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
            // 1. Resumen de productos
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen del pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresApp.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_cantidadTotalProductos artículos',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              for (int i = 0; i < widget.items.length; i++) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.items[i].imagen.startsWith('http')
                          ? Image.network(
                              widget.items[i].imagen,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  imagenCatalogoPlaceholder(
                                    width: 65,
                                    height: 65,
                                  ),
                            )
                          : imagenCatalogoPlaceholder(width: 65, height: 65),
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

            // 2. Información de Recogida en Tienda
            _buildCard([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        color: ColoresApp.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Método de entrega',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _editarContactoModal,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                        color: ColoresApp.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '📍 Recogida en tienda física (No se hacen envíos)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _puntoRecogida,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A4A)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1),
              ),
              _datoEnvioFila('Nombre:', _nombre),
              const SizedBox(height: 6),
              _datoEnvioFila('Cédula:', _cedula),
              const SizedBox(height: 6),
              _datoEnvioFila('Teléfono:', _telefono),
            ]),
            const SizedBox(height: 20),

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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _seleccionarPagoModal,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(
                        color: ColoresApp.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _metodoPago,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _detallePago,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // 4. Resumen de precios
            _buildCard([
              _filaResumen('Subtotal', '\$${widget.total.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              _filaResumen('Recogida en tienda', 'Gratis'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(height: 1),
              ),
              _filaResumen(
                'Total a pagar',
                '\$${totalGeneral.toStringAsFixed(0)}',
                esTotal: true,
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Confirmar y Pagar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                  Icon(Icons.store, size: 15, color: Color(0xFF6B6B6B)),
                  SizedBox(width: 5),
                  Text(
                    'Paga en línea y retira directamente en el local',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
      bottomNavigationBar: _nav(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ColoresApp.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
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

  Widget _nav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Inicio'),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, 'Carrito'),
      (Icons.favorite_border, Icons.favorite, 'Favoritos'),
      (Icons.person_outline, Icons.person, 'Cuenta'),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: ColoresApp.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tab == i ? items[i].$2 : items[i].$1,
                        size: 22,
                        color: _tab == i
                            ? ColoresApp.primary
                            : ColoresApp.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _tab == i
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _tab == i
                              ? ColoresApp.primary
                              : ColoresApp.textSecondary,
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
