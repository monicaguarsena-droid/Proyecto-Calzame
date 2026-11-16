import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({super.key, required this.texto, required this.esUsuario});

  List<String> _celdasDeTabla(String linea) {
    var contenido = linea.trim();
    if (contenido.startsWith('|')) contenido = contenido.substring(1);
    if (contenido.endsWith('|')) {
      contenido = contenido.substring(0, contenido.length - 1);
    }
    return contenido.split('|').map((celda) => celda.trim()).toList();
  }

  bool _esSeparadorDeTabla(String linea) {
    final celdas = _celdasDeTabla(linea);
    return celdas.isNotEmpty &&
        celdas.every((celda) => RegExp(r'^:?-{3,}:?$').hasMatch(celda));
  }

  Widget _construirTabla(List<List<String>> filas, Color colorTexto) {
    final cantidadColumnas = filas
        .map((fila) => fila.length)
        .reduce((a, b) => a > b ? a : b);
    return Table(
      border: TableBorder.all(color: const Color(0xFFE8C9D1)),
      columnWidths: cantidadColumnas == 2
          ? const {0: FlexColumnWidth(0.9), 1: FlexColumnWidth(1.7)}
          : null,
      children: filas.asMap().entries.map((entrada) {
        return TableRow(
          decoration: entrada.key == 0
              ? const BoxDecoration(color: Color(0xFFF8DDE5))
              : null,
          children: List.generate(cantidadColumnas, (indice) {
            final valor = indice < entrada.value.length
                ? entrada.value[indice]
                : '';
            return Padding(
              padding: const EdgeInsets.all(7),
              child: Text(
                valor,
                style: TextStyle(
                  color: colorTexto,
                  fontSize: 12,
                  fontWeight: entrada.key == 0
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  List<Widget> _contenido(Color colorTexto) {
    final imagenMarkdown = RegExp(r'^\s*!\[([^\]]*)\]\((https?://\S+)\)\s*$');
    final lineas = texto.split('\n');
    final contenido = <Widget>[];
    var indice = 0;

    while (indice < lineas.length) {
      if (indice + 1 < lineas.length &&
          lineas[indice].contains('|') &&
          _esSeparadorDeTabla(lineas[indice + 1])) {
        final filas = <List<String>>[_celdasDeTabla(lineas[indice])];
        indice += 2;
        while (indice < lineas.length && lineas[indice].contains('|')) {
          filas.add(_celdasDeTabla(lineas[indice]));
          indice++;
        }
        contenido.add(_construirTabla(filas, colorTexto));
        continue;
      }

      final linea = lineas[indice];
      final coincidencia = imagenMarkdown.firstMatch(linea);
      if (coincidencia == null) {
        contenido.add(
          Text(
            linea,
            style: TextStyle(color: colorTexto, fontSize: 14, height: 1.35),
          ),
        );
      } else {
        contenido.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                coincidencia.group(2)!,
                width: 180,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 180,
                  height: 48,
                  child: Center(child: Text('Imagen no disponible')),
                ),
              ),
            ),
          ),
        );
      }
      indice++;
    }
    return contenido;
  }

  @override
  Widget build(BuildContext context) {
    final colorTexto = esUsuario ? Colors.white : Colors.black87;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? const Color(0xFFE91E63) : const Color(0xFFFFF1F4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _contenido(colorTexto),
        ),
      ),
    );
  }
}
