import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/api_config.dart';

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
  bool _isLoading = true;
  List<dynamic> _pedidos = [];

  // Reemplaza con la IP de tu servidor backend o localhost (ej. 10.0.2.2 para emulador Android)
  final String baseUrl = ApiConfig.baseUrl + '/admin';

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  // Conexión GET con el backend para obtener los pedidos reales
  Future<void> _cargarPedidos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pedidos'));
      if (response.statusCode == 200) {
        setState(() {
          _pedidos = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al conectar con el servidor: $e');
    }
  }

  // Conexión PUT con el backend para actualizar el estado del pedido
  Future<void> _actualizarEstadoPedido(String idPedido, String nuevoEstado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pedidos/$idPedido/estado'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': nuevoEstado}),
      );

      if (response.statusCode == 200) {
        _cargarPedidos(); // Recarga la lista para reflejar el cambio
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado exitosamente')),
        );
      }
    } catch (e) {
      print('Error al actualizar estado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar pedidos según estado y texto de búsqueda
    final pedidosFiltrados = _pedidos.where((pedido) {
      final estadoPedido = pedido['estado'] ?? 'Pendiente';
      final coincideEstado = _filtroEstado == 'Todos' || estadoPedido.toLowerCase() == _filtroEstado.toLowerCase();
      
      final cliente = pedido['usuarios'] != null ? pedido['usuarios']['nombre'] ?? '' : '';
      final idPedido = pedido['id'].toString();
      final coincideBusqueda = cliente.toLowerCase().contains(_filtroBusqueda.toLowerCase()) ||
          idPedido.toLowerCase().contains(_filtroBusqueda.toLowerCase());

      return coincideEstado && coincideBusqueda;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón Atrás y Título
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back, color: primaryColor),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
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
                              'Gestiona las ventas y estados de envío',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Barra de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _filtroBusqueda = val),
                        decoration: const InputDecoration(
                          hintText: 'Buscar pedido o cliente...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtros por Estado (Chips superiores)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', 'Pendiente', 'En camino', 'Entregado', 'Cancelado'].map((estado) {
                          final bool isSelected = _filtroEstado == estado;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(estado),
                              selected: isSelected,
                              onSelected: (selected) => setState(() => _filtroEstado = estado),
                              selectedColor: primaryColor,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : primaryColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    ),
                    const SizedBox(height: 20),

                    // Conteo de pedidos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pedidos recientes',
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${pedidosFiltrados.length} pedidos',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Si no hay pedidos, muestra un mensaje vacío profesional
                    pedidosFiltrados.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay pedidos registrados',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Los pedidos aparecerán aquí cuando los clientes compren.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pedidosFiltrados.length,
                            itemBuilder: (context, index) {
                              final pedido = pedidosFiltrados[index];
                              final estado = pedido['estado'] ?? 'Pendiente';
                              
                              Color colorEstado = Colors.orange;
                              if (estado == 'En camino') colorEstado = Colors.blue;
                              if (estado == 'Entregado') colorEstado = Colors.green;
                              if (estado == 'Cancelado') colorEstado = Colors.red;

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
                                          '#ORD-${pedido['id']}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorEstado.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            estado,
                                            style: TextStyle(
                                              color: colorEstado,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          pedido['usuarios']?['nombre'] ?? 'Cliente desconocido',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Producto: ${pedido['Productos']?['nombre'] ?? 'Calzado'}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Total del pedido',
                                      style: TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                    Text(
                                      '\$${pedido['total'] ?? '0'} COP',
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
                                            onPressed: () {
                                              // Ver detalles del pedido
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: primaryColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: Text('Ver Detalle', style: TextStyle(color: primaryColor, fontSize: 12)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Menú desplegable o cambio rápido de estado
                                              _actualizarEstadoPedido(pedido['id'].toString(), 'En camino');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                                            ),
                                            child: const Text('Cambiar Estado', style: TextStyle(color: Colors.white, fontSize: 11)),
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