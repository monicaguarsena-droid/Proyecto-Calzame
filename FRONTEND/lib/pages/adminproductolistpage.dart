import 'package:flutter/material.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/pantallas/admindrawer.dart';
import 'package:frontend/pantallas/productoformsheet.dart';
import 'package:frontend/servicios/admin_product_service.dart';
import 'package:frontend/servicios/producto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Diálogo de confirmación reutilizable antes de borrar un producto
Future<bool> confirmarEliminacion(BuildContext context, String nombre) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Eliminar producto?'),
      content: Text('¿Eliminar "$nombre"? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

// Pantalla principal del panel administrativo: lista, crea, edita y elimina productos
class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  static const Color _colorPrincipal = Color(0xFFBF285D);

  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _productosFuture;

  String _adminNombre = 'Cargando...';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    // Mismo endpoint que usa la carta del cliente
    _productosFuture = _productoService.obtenerProductos();
    _cargarDatosAdmin();
  }

  void _cargarProductos() {
    setState(() {
      _productosFuture = _productoService.obtenerProductos();
    });
  }

  // Lee los datos reales del usuario logueado (guardados en el login)
  Future<void> _cargarDatosAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminNombre = prefs.getString('user_name') ?? 'Administrador';
      _adminEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _abrirFormulario({ProductoModel? producto}) async {
    final guardado = await ProductFormSheet.abrir(context, producto: producto);
    if (!guardado || !mounted) return;
    _cargarProductos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          producto == null
              ? 'Producto publicado en la carta'
              : 'Cambios guardados',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _eliminar(ProductoModel producto) async {
    final confirmar = await confirmarEliminacion(context, producto.nombre);
    if (!confirmar) return;

    try {
      await AdminProductService.eliminarProducto(producto.id);
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _imagenProducto(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.pink.shade50,
        child: const Icon(Icons.icecream_rounded, color: Color(0xFFE91E63)),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _colorPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(
        adminName: _adminNombre,
        adminEmail: _adminEmail, 
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorPrincipal,
        foregroundColor: Colors.white,
        tooltip: 'Nuevo producto',
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: _colorPrincipal,
        onRefresh: () async => _cargarProductos(),
        child: FutureBuilder<List<ProductoModel>>(
          future: _productosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _colorPrincipal),
              );
            }

            final productos = snapshot.data ?? [];
            if (snapshot.hasError || productos.isEmpty) {
              // ListView para que el "deslizar para recargar" funcione también aquí
              return ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Text(
                      snapshot.hasError
                          ? 'Error: ${snapshot.error}'
                          : 'No hay productos registrados.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _imagenProducto(p.imagenUrl),
                      ),
                    ),
                    title: Text(
                      p.nombre.isEmpty ? 'Sin nombre' : p.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '\$${p.precio.toStringAsFixed(2)}',
                      style: const TextStyle(color: _colorPrincipal),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: _colorPrincipal),
                          onPressed: () => _abrirFormulario(producto: p),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _eliminar(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
