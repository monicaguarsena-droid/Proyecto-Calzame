import 'package:flutter/material.dart';
import 'package:frontend/servicios/pedido_service.dart';

class PedidosAdmin extends StatefulWidget {
  const PedidosAdmin({Key? key}) : super(key: key);

  @override
  State<PedidosAdmin> createState() => _PedidosAdminState();
}

class _PedidosAdminState extends State<PedidosAdmin> {
  final Color primaryColor = const Color(0xFF6B1229);
  final Color backgroundColor = const Color(0xFFF9F1EE);

  String _filtroEstado = 'Todos';
  String _filtroBusqueda = '';
  bool _cargando = true;
  String? _error;
  List<PedidoAdminModel> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  // ---------- Datos ----------

  Future<void> _cargarPedidos({bool spinner = true}) async {
    if (spinner) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final lista = await PedidosService.listarAdmin();
      if (!mounted) return;
      setState(() {
        _pedidos = lista;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _mostrar(String mensaje, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red : primaryColor,
      ),
    );
  }

  Future<void> _cambiarEstado(PedidoAdminModel pedido) async {
    final nuevo = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Estado del pedido #ORD-${pedido.id}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final estado in PedidosService.estados)
              ListTile(
                leading: Icon(
                  estado == pedido.estado
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _colorEstado(estado),
                ),
                title: Text(
                  estado,
                  style: TextStyle(
                    fontWeight: estado == pedido.estado
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, estado),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (nuevo == null || nuevo == pedido.estado) return;

    try {
      await PedidosService.actualizarEstado(pedido.id, nuevo);
      _mostrar('Estado actualizado a "$nuevo"', error: false);
      await _cargarPedidos(spinner: false);
    } catch (e) {
      _mostrar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---------- Formato ----------

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Listo para recoger':
        return Colors.blue;
      case 'Entregado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _pesos(double valor) {
    final entero = valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '\$$entero COP';
  }

  String _fecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.day}/${fecha.month}/${fecha.year} ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  // ---------- Interfaz ----------

  @override
  Widget build(BuildContext context) {
    final consulta = _filtroBusqueda.trim().toLowerCase();
    final filtrados = _pedidos.where((p) {
      final coincideEstado = _filtroEstado == 'Todos' ||
          p.estado.toLowerCase() == _filtroEstado.toLowerCase();
      final coincideBusqueda = consulta.isEmpty ||
          p.cliente.toLowerCase().contains(consulta) ||
          p.clienteNombre.toLowerCase().contains(consulta) ||
          p.id.toString().contains(consulta) ||
          p.cedula.contains(consulta);
      return coincideEstado && coincideBusqueda;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(),
              const SizedBox(height: 16),
              _buscador(),
              const SizedBox(height: 16),
              _chipsEstado(),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pedidos recientes',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${filtrados.length} pedidos',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _contenido(filtrados)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: primaryColor),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos de Clientes',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Gestiona las ventas y el estado de cada pedido',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        onChanged: (valor) => setState(() => _filtroBusqueda = valor),
        decoration: const InputDecoration(
          hintText: 'Buscar pedido, cliente o cédula...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _chipsEstado() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Todos', ...PedidosService.estados].map((estado) {
          final seleccionado = _filtroEstado == estado;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(estado),
              selected: seleccionado,
              onSelected: (_) => setState(() => _filtroEstado = estado),
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: seleccionado ? Colors.white : primaryColor,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _contenido(List<PedidoAdminModel> filtrados) {
    if (_cargando) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => _cargarPedidos(spinner: false),
      child: _error != null
          ? _mensaje(
              icono: Icons.error_outline,
              titulo: 'No se pudieron cargar los pedidos',
              detalle: _error!,
              accion: TextButton(
                onPressed: _cargarPedidos,
                child: Text('Reintentar', style: TextStyle(color: primaryColor)),
              ),
            )
          : filtrados.isEmpty
              ? _mensaje(
                  icono: Icons.shopping_bag_outlined,
                  titulo: 'No hay pedidos registrados',
                  detalle:
                      'Los pedidos aparecerán aquí cuando los clientes compren.',
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filtrados.length,
                  itemBuilder: (_, i) => _tarjeta(filtrados[i]),
                ),
    );
  }

  Widget _mensaje({
    required IconData icono,
    required String titulo,
    required String detalle,
    Widget? accion,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Center(
            child: Column(
              children: [
                Icon(icono, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    detalle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                if (accion != null) accion,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipEstado(String estado) {
    final color = _colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tarjeta(PedidoAdminModel pedido) {
    final primero = pedido.detalles.isNotEmpty
        ? pedido.detalles.first.producto
        : 'Sin productos registrados';
    final extra = pedido.detalles.length > 1
        ? ' y ${pedido.detalles.length - 1} más'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#ORD-${pedido.id}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              _chipEstado(pedido.estado),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pedido.cliente,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Producto: $primero$extra',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            _fecha(pedido.fecha),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 10),
          const Text(
            'Total del pedido',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Text(
            _pesos(pedido.total),
            style: TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _verDetalle(pedido),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ver Detalle',
                    style: TextStyle(color: primaryColor, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _cambiarEstado(pedido),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cambiar Estado',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Detalle ----------

  void _verDetalle(PedidoAdminModel pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #ORD-${pedido.id}',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _chipEstado(pedido.estado),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _fecha(pedido.fecha),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _titulo('Cliente'),
            _fila('Nombre', pedido.cliente),
            _fila('Cédula', pedido.cedula),
            _fila('Teléfono', pedido.celular),
            if (pedido.clienteEmail.isNotEmpty)
              _fila('Correo', pedido.clienteEmail),
            _fila('Pago', pedido.metodoPago),
            _fila('Entrega', 'Recoge en la tienda'),
            const SizedBox(height: 16),
            _titulo('Productos (${pedido.articulos})'),
            if (pedido.detalles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Este pedido no tiene productos registrados.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            for (final d in pedido.detalles) _lineaProducto(d),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _pesos(pedido.total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          texto,
          style: TextStyle(
            color: primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                etiqueta,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                valor.isEmpty ? 'Sin registrar' : valor,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _lineaProducto(PedidoDetalleAdmin d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: d.imagen.startsWith('http')
                ? Image.network(
                    d.imagen,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fotoVacia(),
                  )
                : _fotoVacia(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.producto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Talla: ${d.talla}  |  Color: ${d.color}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${d.cantidad} x ${_pesos(d.precioUnitario)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _pesos(d.subtotal),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoVacia() => Container(
        width: 56,
        height: 56,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
}