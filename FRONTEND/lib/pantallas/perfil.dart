import 'package:flutter/material.dart';
import 'package:frontend/servicios/pedido_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:frontend/pantallas/favoritos.dart';
import 'package:frontend/pantallas/pedido.dart';
import 'package:frontend/pantallas/detalle_pedido.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';
import 'package:frontend/pantallas/ubicacion_tienda.dart';

import 'package:frontend/servicios/perfil_service.dart';

String _pesos(double valor) {
  final entero = valor.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '\$$entero';
}

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final int _tab = 3; // Pestaña Cuenta seleccionada

  PerfilUsuario? _perfil;
  bool _cargando = true;
  String? _errorCarga;
  bool _notificacionesActivas = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  // ---------- Datos ----------

  /// Carga los datos reales desde la base de datos (tabla usuarios).
  Future<void> _cargarPerfil() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final perfil = await PerfilService.obtener();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre', perfil.nombre);
      await prefs.setString('email', perfil.email);
      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _cargando = false;
      });
    } catch (error) {
      // Si no hay conexión mostramos lo último que se guardó en el teléfono
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _perfil = PerfilUsuario(
          nombre: prefs.getString('nombre') ?? '',
          cedula: '',
          telefono: '',
          email: prefs.getString('email') ?? '',
        );
        _cargando = false;
        _errorCarga = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _mostrar(String mensaje, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? ColoresApp.error : ColoresApp.success,
      ),
    );
  }

  /// Vuelve a la pantalla anterior; si no hay ninguna (se llegó con pushReplacement
  /// desde la barra inferior), va al inicio en vez de cerrar la única pantalla.
  void _volver() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  // ---------- Navegación ----------

  void _onItemTapped(int index) {
    if (index == _tab) return;

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
    }
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    // Solo se borran los datos de la sesión (así no se pierden, por ejemplo, los favoritos)
    for (final clave in ['token', 'jwt_token', 'email', 'nombre', 'cedula', 'telefono']) {
      await prefs.remove(clave);
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  // ---------- Pedidos ----------

  /// Convierte un pedido de la base de datos al modelo que usa la pantalla de detalle.
  Pedido _aPedido(PedidoAdminModel p) {
    return Pedido(
      idPedido: 'ORD-${p.id}',
      fechaHora: p.fecha ?? DateTime.now(),
      items: p.detalles
          .map(
            (d) => ItemCarrito(
              id: '',
              productoId: '',
              imagen: d.imagen,
              titulo: d.producto,
              subtitulo: 'Talla ${d.talla}  •  Color ${d.color}',
              precio: d.precioUnitario,
              talla: d.talla,
              color: d.color,
              cantidad: d.cantidad,
            ),
          )
          .toList(),
      total: p.total,
      metodoPago: p.metodoPago.isEmpty ? 'No registrado' : p.metodoPago,
      direccion: 'Tienda CalzaMe - Calle Principal #12-34, Garzón, Huila',
      telefono: p.celular.isEmpty ? 'No registrado' : p.celular,
      nombreCliente: p.cliente,
      estado: p.estado,
    );
  }

  void _mostrarHistorialPedidos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _HistorialPedidosSheet(
        onAbrir: (pedido) {
          Navigator.pop(sheetContext);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetallePedidoScreen(pedido: _aPedido(pedido)),
            ),
          );
        },
      ),
    );
  }

  // ---------- Edición ----------

  Future<void> _mostrarModalEdicion() async {
    final perfil = _perfil;
    if (perfil == null) return;

    // La hoja guarda los cambios en el servidor y devuelve el perfil actualizado
    final actualizado = await showModalBottomSheet<PerfilUsuario>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditarPerfilSheet(perfil: perfil),
    );
    if (actualizado == null || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', actualizado.nombre);
    if (!mounted) return;

    setState(() => _perfil = actualizado);
    _mostrar('¡Datos actualizados con éxito!', error: false);
  }

  // ---------- Interfaz ----------

  @override
  Widget build(BuildContext context) {
    final perfil = _perfil;
    final nombre = (perfil?.nombre ?? '').trim();

    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: ColoresApp.primary),
              )
            : RefreshIndicator(
                color: ColoresApp.primary,
                onRefresh: _cargarPerfil,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _volver,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: ColoresApp.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const Text(
                            'MI CUENTA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ColoresApp.primary,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColoresApp.primary, width: 2),
                          color: const Color(0xFFEFE6EE),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: ColoresApp.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nombre.isEmpty ? 'Completa tu nombre' : nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColoresApp.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        perfil?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                      if (_errorCarga != null) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _cargarPerfil,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No se pudieron cargar tus datos ($_errorCarga). Toca para reintentar.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Datos de la cuenta
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.border),
                        ),
                        child: Column(
                          children: [
                            _filaDato(
                              Icons.badge_outlined,
                              'Cédula',
                              perfil?.cedula ?? '',
                            ),
                            const Divider(height: 22),
                            _filaDato(
                              Icons.phone_outlined,
                              'Teléfono',
                              perfil?.telefono ?? '',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _tarjetaOpcion(
                        icon: Icons.shopping_bag_outlined,
                        titulo: 'Mis pedidos',
                        subtitulo: 'Revisa el estado de tus compras',
                        onTap: _mostrarHistorialPedidos,
                      ),
                      const SizedBox(height: 12),
                      _tarjetaOpcion(
                        icon: Icons.person_outline,
                        titulo: 'Editar información personal',
                        subtitulo: 'Nombre, teléfono, cédula',
                        onTap: _mostrarModalEdicion,
                      ),
                      const SizedBox(height: 12),
                      _tarjetaOpcion(
                        icon: Icons.storefront_outlined,
                        titulo: 'Ubicación de la tienda',
                        subtitulo: 'Garzón, Huila (Recogida en local)',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UbicacionTiendaScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ColoresApp.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: ColoresApp.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Notificaciones push',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: ColoresApp.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _notificacionesActivas
                                        ? 'Activadas'
                                        : 'Desactivadas',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ColoresApp.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _notificacionesActivas,
                              activeColor: ColoresApp.primary,
                              onChanged: (value) {
                                setState(() => _notificacionesActivas = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A1D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _cerrarSesion,
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '🔒 Tus datos están protegidos y seguros',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColoresApp.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _filaDato(IconData icono, String etiqueta, String valor) {
    final vacio = valor.trim().isEmpty;
    return Row(
      children: [
        Icon(icono, color: ColoresApp.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 13,
            color: ColoresApp.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          vacio ? 'Sin registrar' : valor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: vacio ? ColoresApp.textSecondary : ColoresApp.primary,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaOpcion({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColoresApp.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ColoresApp.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColoresApp.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: ColoresApp.textSecondary,
            ),
          ],
        ),
      ),
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
                          fontWeight:
                              _tab == i ? FontWeight.w700 : FontWeight.w400,
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

/// Historial de pedidos del cliente, leído de la base de datos.
/// El cliente puede quitar un pedido de su lista manualmente.
class _HistorialPedidosSheet extends StatefulWidget {
  final void Function(PedidoAdminModel pedido) onAbrir;

  const _HistorialPedidosSheet({required this.onAbrir});

  @override
  State<_HistorialPedidosSheet> createState() => _HistorialPedidosSheetState();
}

class _HistorialPedidosSheetState extends State<_HistorialPedidosSheet> {
  bool _cargando = true;
  String? _error;
  List<PedidoAdminModel> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool spinner = true}) async {
    if (spinner) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final lista = await PedidosService.listarMios();
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

  Future<void> _eliminar(PedidoAdminModel pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar pedido'),
        content: Text(
          '¿Quieres quitar el pedido #ORD-${pedido.id} de tu historial? La tienda conserva el registro de la compra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await PedidosService.ocultar(pedido.id);
      if (!mounted) return;
      setState(() => _pedidos.removeWhere((p) => p.id == pedido.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: ColoresApp.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Pedidos Realizados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca un pedido para ver el detalle completo.',
            style: TextStyle(fontSize: 12, color: ColoresApp.textSecondary),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: ColoresApp.primary),
      );
    }

    return RefreshIndicator(
      color: ColoresApp.primary,
      onRefresh: () => _cargar(spinner: false),
      child: _error != null
          ? _mensaje(
              'No se pudieron cargar tus pedidos.\n$_error',
              accion: TextButton(
                onPressed: _cargar,
                child: const Text('Reintentar'),
              ),
            )
          : _pedidos.isEmpty
              ? _mensaje('Aún no tienes pedidos registrados.')
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) => _tarjeta(_pedidos[index]),
                ),
    );
  }

  Widget _mensaje(String texto, {Widget? accion}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 260,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ColoresApp.textSecondary,
                      fontSize: 14,
                    ),
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

  Widget _tarjeta(PedidoAdminModel pedido) {
    final fecha = pedido.fecha;
    final fechaTexto = fecha == null
        ? 'Sin fecha'
        : '${fecha.day}/${fecha.month}/${fecha.year}';
    final color = _colorEstado(pedido.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColoresApp.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 6, bottom: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColoresApp.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_bag, color: ColoresApp.primary, size: 20),
        ),
        title: Text(
          'Pedido #ORD-${pedido.id}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: ColoresApp.primary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha: $fechaTexto  •  Total: ${_pesos(pedido.total)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: ColoresApp.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  pedido.estado,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: 'Eliminar de mi historial',
          icon: const Icon(Icons.delete_outline, color: ColoresApp.error, size: 22),
          onPressed: () => _eliminar(pedido),
        ),
        onTap: () => widget.onAbrir(pedido),
      ),
    );
  }
}


/// Formulario para editar los datos. Los controladores se crean y se liberan aquí,
/// dentro de su propio ciclo de vida, para no destruirlos mientras la hoja se cierra.
class _EditarPerfilSheet extends StatefulWidget {
  final PerfilUsuario perfil;

  const _EditarPerfilSheet({required this.perfil});

  @override
  State<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends State<_EditarPerfilSheet> {
  late final TextEditingController _nombreCtrl =
      TextEditingController(text: widget.perfil.nombre);
  late final TextEditingController _telefonoCtrl =
      TextEditingController(text: widget.perfil.telefono);
  late final TextEditingController _cedulaCtrl =
      TextEditingController(text: widget.perfil.cedula);

  bool _guardando = false;
  String? _mensajeError;

  bool get _tieneCedula => widget.perfil.cedula.trim().isNotEmpty;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final nombre = _nombreCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final digitos = telefono.replaceAll(RegExp(r'\D'), '');

    if (nombre.isEmpty) {
      setState(() => _mensajeError = 'Escribe tu nombre');
      return;
    }
    if (telefono.isNotEmpty && digitos.length < 7) {
      setState(() => _mensajeError = 'Escribe un teléfono válido');
      return;
    }

    setState(() {
      _guardando = true;
      _mensajeError = null;
    });

    try {
      final actualizado = await PerfilService.actualizar(
        nombre: nombre,
        telefono: telefono,
        cedula: _tieneCedula ? null : _cedulaCtrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context, actualizado);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _mensajeError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Información Personal',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColoresApp.primary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.perfil.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                helperText: 'El correo no se puede cambiar',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cedulaCtrl,
              enabled: !_tieneCedula,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cédula',
                helperText: _tieneCedula
                    ? 'La cédula no se puede cambiar'
                    : 'Se guarda una sola vez',
              ),
            ),
            if (_mensajeError != null) ...[
              const SizedBox(height: 10),
              Text(
                _mensajeError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.primary,
                  disabledBackgroundColor: ColoresApp.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
      ),
    );
  }
}