import 'package:frontend/pantallas/carrito.dart';

class Pedido {
  final String idPedido;
  final DateTime fechaHora;
  final List<ItemCarrito> items;
  final double total;
  final String metodoPago;
  final String direccion;
  final String telefono;
  final String nombreCliente;
  final String estado; 

  Pedido({
    required this.idPedido,
    required this.fechaHora,
    required this.items,
    required this.total,
    required this.metodoPago,
    required this.direccion,
    required this.telefono,
    required this.nombreCliente,
    this.estado = 'En proceso',
  });
}


class HistorialPedidosService {
  static final List<Pedido> listaPedidos = [];

  static void agregarPedido(Pedido pedido) {
    listaPedidos.insert(0, pedido); 
  }
}