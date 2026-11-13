import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/servicios/reporte_service.dart';

const List<String> _mesesCompletos = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const List<String> _mesesCortos = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

/// 1250000 -> "$ 1.250.000"
String _formatearCOP(num valor) {
  final entero = valor.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < entero.length; i++) {
    final restante = entero.length - i;
    buffer.write(entero[i]);
    if (restante > 1 && restante % 3 == 1) buffer.write('.');
  }
  return '\$ $buffer';
}

class ReporteVentas extends StatefulWidget {
  const ReporteVentas({super.key});

  @override
  State<ReporteVentas> createState() => _ReporteVentasState();
}

class _ReporteVentasState extends State<ReporteVentas> {
  static const Map<String, String> _periodos = {
    'diario': 'Diario',
    'mensual': 'Mensual',
    'trimestral': 'Trimestral',
    'anual': 'Anual',
  };

  final ReporteService _service = ReporteService();

  String _periodo = 'mensual';
  DateTime _fecha = DateTime.now();

  bool _cargando = true;
  String? _error;
  ReporteVentasData? _reporte;
  int? _seleccionado;
  int _peticion = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // ---------------------------------------------------------------------------
  // Lógica
  // ---------------------------------------------------------------------------

  Future<void> _cargar() async {
    final id = ++_peticion;
    setState(() {
      _cargando = true;
      _error = null;
      _seleccionado = null;
    });

    final result = await _service.obtenerVentas(periodo: _periodo, fecha: _fecha);

    // Ignora respuestas viejas si el usuario cambió de periodo rápido
    if (!mounted || id != _peticion) return;

    setState(() {
      _cargando = false;
      if (result['success'] == true) {
        _reporte = result['data'] as ReporteVentasData;
      } else {
        _reporte = null;
        _error = result['message']?.toString() ?? 'No se pudo cargar el reporte';
      }
    });
  }

  void _cambiarPeriodo(String nuevo) {
    if (nuevo == _periodo) return;
    _periodo = nuevo;
    _cargar();
  }

  void _mover(int delta) {
    switch (_periodo) {
      case 'diario':
        _fecha = DateTime(_fecha.year, _fecha.month, _fecha.day + delta);
        break;
      case 'mensual':
        _fecha = DateTime(_fecha.year, _fecha.month + delta, 1);
        break;
      case 'trimestral':
        _fecha = DateTime(_fecha.year, _fecha.month + delta * 3, 1);
        break;
      default:
        _fecha = DateTime(_fecha.year + delta, 1, 1);
    }
    _cargar();
  }

  Future<void> _elegirFecha() async {
    final primera = DateTime(2020);
    final ultima = DateTime(DateTime.now().year + 1, 12, 31);
    DateTime inicial = _fecha;
    if (inicial.isBefore(primera)) inicial = primera;
    if (inicial.isAfter(ultima)) inicial = ultima;

    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primera,
      lastDate: ultima,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: ColoresApp.primary),
        ),
        child: child!,
      ),
    );

    if (elegida != null) {
      _fecha = elegida;
      _cargar();
    }
  }

  String _tituloPeriodo() {
    switch (_periodo) {
      case 'diario':
        return '${_fecha.day} ${_mesesCortos[_fecha.month - 1].toLowerCase()} ${_fecha.year}';
      case 'mensual':
        return '${_mesesCompletos[_fecha.month - 1]} ${_fecha.year}';
      case 'trimestral':
        return 'Trimestre ${((_fecha.month - 1) ~/ 3) + 1} · ${_fecha.year}';
      default:
        return '${_fecha.year}';
    }
  }

  String _tituloGrafico() {
    switch (_periodo) {
      case 'diario':
        return 'Ventas por hora';
      case 'mensual':
        return 'Ventas por día';
      default:
        return 'Ventas por mes';
    }
  }

  String _nombreCubeta(CubetaReporte c) {
    switch (_periodo) {
      case 'diario':
        return c.etiqueta;
      case 'mensual':
        return 'Día ${c.etiqueta}';
      default:
        final mes = int.tryParse(c.periodo.length >= 7 ? c.periodo.substring(5, 7) : '') ?? 1;
        return _mesesCompletos[(mes - 1).clamp(0, 11)];
    }
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  BoxDecoration _decoracionTarjeta() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      );

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: ColoresApp.primary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Expanded(
            child: Text(
              'REPORTE DE VENTAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColoresApp.primary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _selectorPeriodo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _periodos.entries.map((e) {
        final activo = _periodo == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: activo,
          showCheckmark: false,
          selectedColor: ColoresApp.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: activo ? Colors.white : ColoresApp.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: activo ? ColoresApp.primary : ColoresApp.border),
          ),
          onSelected: (_) => _cambiarPeriodo(e.key),
        );
      }).toList(),
    );
  }

  Widget _navegadorFecha() {
    return Container(
      decoration: _decoracionTarjeta(),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: ColoresApp.primary,
            onPressed: _cargando ? null : () => _mover(-1),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _cargando ? null : _elegirFecha,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: ColoresApp.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _tituloPeriodo(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: ColoresApp.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: ColoresApp.primary,
            onPressed: _cargando ? null : () => _mover(1),
          ),
        ],
      ),
    );
  }

  Widget _cajaError(String mensaje) {
    return GestureDetector(
      onTap: _cargar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Text(
          '$mensaje\nToca para reintentar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red.shade400, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }

  Widget _tarjetaTotal(ReporteVentasData r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresApp.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total de ventas',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatearCOP(r.totalVentas),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPequena(String titulo, String valor, IconData icono) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _decoracionTarjeta(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 20, color: ColoresApp.primary),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(color: ColoresApp.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: const TextStyle(
                  color: ColoresApp.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaGrafico(ReporteVentasData r) {
    final seleccion = _seleccionado != null && _seleccionado! < r.desglose.length
        ? r.desglose[_seleccionado!]
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoracionTarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tituloGrafico(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 16),
          _GraficoBarras(
            datos: r.desglose,
            periodo: _periodo,
            seleccionado: _seleccionado,
            onSeleccion: (i) => setState(() => _seleccionado = i),
          ),
          const SizedBox(height: 12),
          if (seleccion != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ColoresApp.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_nombreCubeta(seleccion)} · ${_formatearCOP(seleccion.ventas)} · '
                '${seleccion.pedidos} ${seleccion.pedidos == 1 ? 'pedido' : 'pedidos'}',
                style: const TextStyle(
                  color: ColoresApp.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            )
          else
            const Text(
              'Toca una barra para ver el detalle',
              style: TextStyle(color: ColoresApp.hint, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _tarjetaDetalle(ReporteVentasData r) {
    final conVentas = r.desglose.where((c) => c.pedidos > 0).toList();
    final filas = <Widget>[];

    for (int i = 0; i < conVentas.length; i++) {
      final c = conVentas[i];
      if (i > 0) filas.add(Divider(height: 1, color: Colors.grey.shade200));
      filas.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _nombreCubeta(c),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${c.pedidos} ${c.pedidos == 1 ? 'pedido' : 'pedidos'}',
                style: const TextStyle(color: ColoresApp.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 14),
              Text(
                _formatearCOP(c.ventas),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ColoresApp.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: _decoracionTarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalle',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 4),
          ...filas,
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: _decoracionTarjeta(),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: ColoresApp.hint),
          SizedBox(height: 12),
          Text(
            'No hay pedidos entregados en este periodo',
            textAlign: TextAlign.center,
            style: TextStyle(color: ColoresApp.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando && _reporte == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: ColoresApp.primary)),
      );
    }

    if (_error != null) return _cajaError(_error!);

    final r = _reporte;
    if (r == null) return const SizedBox.shrink();

    return Opacity(
      opacity: _cargando ? 0.4 : 1,
      child: Column(
        children: [
          _tarjetaTotal(r),
          const SizedBox(height: 12),
          Row(
            children: [
              _tarjetaPequena('Pedidos entregados', '${r.cantidadPedidos}',
                  Icons.shopping_bag_outlined),
              const SizedBox(width: 12),
              _tarjetaPequena('Promedio por pedido', _formatearCOP(r.promedioPorPedido),
                  Icons.trending_up),
            ],
          ),
          const SizedBox(height: 12),
          if (r.cantidadPedidos == 0)
            _estadoVacio()
          else ...[
            _tarjetaGrafico(r),
            const SizedBox(height: 12),
            _tarjetaDetalle(r),
          ],
          const SizedBox(height: 16),
          const Text(
            'Solo se cuentan pedidos con estado Entregado. Valores en COP, hora de Bogotá.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ColoresApp.hint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(),
            Expanded(
              child: RefreshIndicator(
                color: ColoresApp.primary,
                onRefresh: _cargar,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _selectorPeriodo(),
                    const SizedBox(height: 14),
                    _navegadorFecha(),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 3,
                      child: _cargando
                          ? const LinearProgressIndicator(
                              color: ColoresApp.primary,
                              backgroundColor: Colors.transparent,
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _contenido(),
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

// -----------------------------------------------------------------------------
// Gráfico de barras sin dependencias externas
// -----------------------------------------------------------------------------

class _GraficoBarras extends StatelessWidget {
  final List<CubetaReporte> datos;
  final String periodo;
  final int? seleccionado;
  final ValueChanged<int> onSeleccion;

  const _GraficoBarras({
    required this.datos,
    required this.periodo,
    required this.seleccionado,
    required this.onSeleccion,
  });

  static const double _alturaMax = 150;

  String _etiquetaCorta(CubetaReporte c) {
    switch (periodo) {
      case 'diario':
        return c.etiqueta.length >= 2 ? c.etiqueta.substring(0, 2) : c.etiqueta;
      case 'mensual':
        return c.etiqueta;
      default:
        final mes = int.tryParse(c.periodo.length >= 7 ? c.periodo.substring(5, 7) : '') ?? 1;
        return _mesesCortos[(mes - 1).clamp(0, 11)];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maximo = datos.fold<double>(0, (m, d) => math.max(m, d.ventas));
        final ancho = math.max(constraints.maxWidth / datos.length, 28.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: _alturaMax + 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(datos.length, (i) {
                final d = datos[i];
                final activa = seleccionado == i;
                final altura = d.ventas > 0 && maximo > 0
                    ? math.max(_alturaMax * d.ventas / maximo, 4.0)
                    : 2.0;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSeleccion(i),
                  child: SizedBox(
                    width: ancho,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: math.min(ancho - 8, 28),
                          height: altura,
                          decoration: BoxDecoration(
                            color: d.ventas > 0
                                ? (activa
                                    ? ColoresApp.primary
                                    : ColoresApp.primary.withOpacity(0.55))
                                : ColoresApp.border,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _etiquetaCorta(d),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: activa ? FontWeight.bold : FontWeight.normal,
                            color: activa
                                ? ColoresApp.primary
                                : ColoresApp.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}