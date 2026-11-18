import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/pantallas/carrito.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CarritoService.itemsCarrito.clear();
    await CarritoService.cargarCarrito();
  });

  test('permite gestionar el carrito sin iniciar sesión', () async {
    await CarritoService.agregarProducto(
      productoId: '42',
      imagen: '',
      titulo: 'Sandalia',
      subtitulo: 'Dama',
      precioStr: '25000',
      talla: '37',
      color: 'Negro',
    );
    await CarritoService.agregarProducto(
      productoId: '42',
      imagen: '',
      titulo: 'Sandalia',
      subtitulo: 'Dama',
      precioStr: '25000',
      talla: '37',
      color: 'Negro',
    );
    await CarritoService.agregarProducto(
      productoId: '42',
      imagen: '',
      titulo: 'Sandalia',
      subtitulo: 'Dama',
      precioStr: '25000',
      talla: '38',
      color: 'Negro',
    );

    expect(CarritoService.itemsCarrito, hasLength(2));
    expect(CarritoService.itemsCarrito.first.cantidad, 2);

    await CarritoService.actualizarCantidad(
      CarritoService.itemsCarrito.first,
      3,
    );
    await CarritoService.eliminar(CarritoService.itemsCarrito.last);

    expect(CarritoService.itemsCarrito, hasLength(1));
    expect(CarritoService.itemsCarrito.single.cantidad, 3);

    await CarritoService.vaciar();
    expect(CarritoService.itemsCarrito, isEmpty);
  });

  testWidgets('pide iniciar sesión al confirmar una compra invitada', (
    tester,
  ) async {
    await CarritoService.agregarProducto(
      productoId: '42',
      imagen: '',
      titulo: 'Sandalia',
      subtitulo: 'Dama',
      precioStr: '25000',
    );

    await tester.pumpWidget(const MaterialApp(home: CarritoScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceder al pago'));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido!'), findsOneWidget);
  });
}
