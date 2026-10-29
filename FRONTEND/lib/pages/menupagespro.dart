import 'package:flutter/material.dart';
import 'package:frontend/pantallas/producto.dart';
import 'package:frontend/servicios/admin_product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/producto_service.dart';
import 'package:frontend/pantallas/productocard.dart';
import 'package:frontend/componentes/chat/chat_calzame_modal.dart';
import 'package:frontend/pantallas/productoformsheet.dart';

import 'package:frontend/pages/adminproductolistpage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _productosFuture;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    // Asignación directa en el inicio (Sin setState)
    _productosFuture = _productoService.obtenerProductos();
    _cargarRol();
  }

  void _recargar() {
    setState(() {
      _productosFuture = _productoService.obtenerProductos();
    });
  }

  Future<void> _cargarRol() async {
    final prefs = await SharedPreferences.getInstance();
    final String rol = prefs.getString('user_role') ?? '';

    if (!mounted) return;
    setState(() {
      _esAdmin = rol.toLowerCase() == 'admin';
    });
  }

  Future<void> _editarProducto(ProductoModel producto) async {
    final guardado = await ProductFormSheet.abrir(context, producto: producto);
    if (guardado) _recargar();
  }

  Future<void> _eliminarProducto(ProductoModel producto) async {
    final confirmar = await confirmarEliminacion(context, producto.nombre);
    if (!confirmar) return;

    try {
      await AdminProductService.eliminarProducto(producto.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado'),
          backgroundColor: Colors.green,
        ),
      );
      _recargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> confirmarEliminacion(
    BuildContext context,
    String nombreProducto,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text(
                '¿Estás seguro de que deseas eliminar "$nombreProducto"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _construirLista(List<ProductoModel> productos) {
    if (productos.isEmpty) {
      return const Center(
        child: Text('No hay productos disponibles por el momento.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      itemCount: productos.length,
      itemBuilder: (context, i) => ProductoCard(
        producto: productos[i],
        onVerMas: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleProductoScreen(
                productoId: productos[i].id,
                imagen: productos[i].imagenUrl ?? '',
                titulo: productos[i].nombre,
                subtitulo: productos[i].descripcion,
                precio: '\$${productos[i].precio.toStringAsFixed(0)}',
              ),
            ),
          );
        },
        onEditar: _esAdmin
            ? () {
                _editarProducto(productos[i]);
              }
            : null,
        onEliminar: _esAdmin
            ? () {
                _eliminarProducto(productos[i]);
              }
            : null,
        onComprar: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comprando: ${productos[i].nombre}'),
            backgroundColor: const Color(0xFFE91E63),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        title: const Text(
          'Nuestra Carta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: const Color(0xFFBF285D),
        actions: [
          if (_esAdmin)
            IconButton(
              tooltip: 'Panel de Administración',
              icon: const Icon(
                Icons.admin_panel_settings,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProductListPage(),
                  ),
                );
                _recargar(); // Refresca la carta al volver del panel admin
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFE91E63),
        onRefresh: () async => _recargar(),
        child: FutureBuilder<List<ProductoModel>>(
          future: _productosFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE91E63)),
              );
            }

            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${snap.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _recargar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBF285D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _construirLista(snap.data ?? []);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFBC2552),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.support_agent_rounded),
        label: const Text(
          'Asesor Mimos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ChatCalzameModal(),
        ),
      ),
    );
  }
}
