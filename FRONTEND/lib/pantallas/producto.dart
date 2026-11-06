import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/componentes/imagen_catalogo_placeholder.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/models/productoModel.dart';
import 'package:frontend/servicios/favoritos_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final ProductoModel producto;

  const DetalleProductoScreen({
    super.key,
    required this.producto,
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  late String tallaSeleccionada;
  int colorSeleccionadoIndex = 0;
  bool esFavorito = false;
  late String imagenActual;

  @override
  void initState() {
    super.initState();
    tallaSeleccionada = widget.producto.tallas.isNotEmpty 
        ? widget.producto.tallas.first 
        : '37';
        
    imagenActual = widget.producto.imagenes.isNotEmpty
        ? widget.producto.imagenes.first
        : '';
        
    esFavorito = FavoritosService.esFavorito(widget.producto.nombre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColoresApp.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imagenActual.isNotEmpty
                      ? Image.network(
                          imagenActual,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => imagenCatalogoPlaceholder(iconSize: 50),
                        )
                      : imagenCatalogoPlaceholder(iconSize: 50),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.producto.nombre,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${widget.producto.precio.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColoresApp.primary),
              ),
              const SizedBox(height: 20),
              const Text("Tallas disponibles", style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: widget.producto.tallas.map((talla) {
                  bool esSeleccionada = tallaSeleccionada == talla;
                  return ChoiceChip(
                    label: Text(talla),
                    selected: esSeleccionada,
                    selectedColor: ColoresApp.primary,
                    labelStyle: TextStyle(color: esSeleccionada ? Colors.white : ColoresApp.primary),
                    onSelected: (_) => setState(() => tallaSeleccionada = talla),
                  );
                }).toList(),
              ),
              if (widget.producto.colores.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text("Colores disponibles", style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(widget.producto.colores.length, (index) {
                    final colorItem = widget.producto.colores[index];
                    bool esSeleccionado = colorSeleccionadoIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          colorSeleccionadoIndex = index;
                          if (colorItem.imagenUrl.isNotEmpty) {
                            imagenActual = colorItem.imagenUrl;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: esSeleccionado ? ColoresApp.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColoresApp.border),
                        ),
                        child: Text(
                          colorItem.color,
                          style: TextStyle(
                            color: esSeleccionado ? Colors.white : ColoresApp.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 20),
              const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, color: ColoresApp.primary)),
              const SizedBox(height: 6),
              Text(widget.producto.descripcion, style: const TextStyle(color: ColoresApp.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}