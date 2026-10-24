import 'package:flutter/material.dart';
import 'package:frontend/pantallas/adminagregar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class InventarioAdminPage extends StatefulWidget {
  const InventarioAdminPage({Key? key}) : super(key: key);

  @override
  State<InventarioAdminPage> createState() => _InventarioAdminPageState();
}

class _InventarioAdminPageState extends State<InventarioAdminPage> {
  final Color primaryColor = const Color(0xFF6B1229);
  final Color backgroundColor = const Color(0xFFF9F1EE);
  final String baseUrl = "http://10.0.2.2:3000";

  String _categoriaSeleccionada = 'Todos';
  String _filtroBusqueda = '';

  // Lista vacía para que no tenga productos por defecto
  List<Map<String, dynamic>> _productos = [];
  
  Future<void> _cargarProductos() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/productos')); // O la ruta que uses
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Asegúrate de asignarlo a tu lista según cómo te devuelva los datos el backend
        _productos = List<Map<String, dynamic>>.from(data['productos'] ?? data);
      });
    }
  } catch (e) {
    print("Error al cargar productos: $e");
  }
}
  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }
  
  @override
  Widget build(BuildContext context) {
    // Filtrar productos según la categoría y búsqueda
    final productosFiltrados = _productos.where((prod) {
      final coincideCategoria = _categoriaSeleccionada == 'Todos' || prod['Categoria'] == _categoriaSeleccionada;
      // Si 'nombre' es null, le asignamos un texto vacío ('') para que no falle
      final nombreProducto = prod['Nombre']?.toString() ?? '';
      final coincideTexto = nombreProducto.toLowerCase().contains(_filtroBusqueda.toLowerCase());
      return coincideCategoria && coincideTexto;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calzado Mar&Paz',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inventario de Productos',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Administra tu calzado y sus existencias.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final resultado = await Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const AgregarProductoScreen(),
                      ),
                    );
                    if (resultado == true) {
                      _cargarProductos(); 
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'Agregar producto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (valor) {
                    setState(() {
                      _filtroBusqueda = valor;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar calzado por nombre...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Dama', 'Caballero', 'Infantil'].map((cat) {
                    final bool isSelected = _categoriaSeleccionada == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _categoriaSeleccionada = cat;
                          });
                        },
                        selectedColor: primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${productosFiltrados.length} productos activos',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        'Recientes',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Si no hay productos, mostramos un mensaje indicándole al administrador que agregue uno
              productosFiltrados.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No hay productos registrados',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Presiona "Agregar producto" para empezar.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final prod = productosFiltrados[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 85,
                                      height: 85,
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        prod['Imagen'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.image, color: primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod['Categoria'] ?? '',
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          prod['Nombre'] ?? '',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (prod['stockBajo'] == true)
                                              const Icon(Icons.warning_amber_rounded,
                                                  color: Colors.orange, size: 14)
                                            else
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${prod['Stock']} en stock${prod['stockBajo'] == true ? ' · Stock bajo' : ''}',
                                              style: TextStyle(
                                                color: prod['stockBajo'] == true ? Colors.orange[800] : Colors.grey[600],
                                                fontSize: 11,
                                                fontWeight: prod['stockBajo'] == true ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${prod['Precio']}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () {
                                        // Acción Editar
                                      },
                                      icon: Icon(Icons.edit_outlined, color: primaryColor, size: 16),
                                      label: Text('Editar', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: TextButton.styleFrom(
                                        backgroundColor: primaryColor.withOpacity(0.08),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _productos.remove(prod);
                                        });
                                      },
                                      icon: Icon(Icons.delete_outline, color: primaryColor, size: 16),
                                      label: Text('Eliminar', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}