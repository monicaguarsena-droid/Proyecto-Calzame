import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/productoModel.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onComprar;
  final VoidCallback onVerMas;
  // Solo se muestran si se pasan (admin)
  final Function()? onEditar;
  final Function()? onEliminar;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onComprar,
    required this.onVerMas,
    this.onEditar,
    this.onEliminar,
  });

  Widget _botonAdmin({
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icono, size: 18, color: color),
        ),
      ),
    );
  }

  Widget _construirImagen() {
    final String? imagen = producto.imagenUrl;
    final double alturaFoto = 150.0; // Altura original del primer diseño

    if (imagen == null || imagen.isEmpty) {
      return Container(
        height: alturaFoto,
        width: double.infinity,
        color: Colors.pink.shade50,
        child: const Icon(
          Icons.shopping_bag_rounded, // Icono original del primer diseño
          size: 64,
          color: Color(0xFFE91E63),
        ),
      );
    }

    final bool esUrlWeb =
        imagen.startsWith('http://') || imagen.startsWith('https://');

    return Container(
      height: alturaFoto,
      width: double.infinity,
      color: Colors.pink.shade50,
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: esUrlWeb
          ? Image.network(
              imagen,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE91E63),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.pink.shade50,
                child: const Icon(
                  Icons.broken_image_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            )
          : Image.file(
              File(imagen),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.pink.shade50,
                child: const Icon(
                  Icons.broken_image_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: _construirImagen(),
              ),
              if (onEditar != null || onEliminar != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (onEditar != null)
                        _botonAdmin(
                          icono: Icons.edit,
                          color: const Color(0xFFBF285D),
                          onTap: onEditar!,
                        ),
                      if (onEditar != null && onEliminar != null)
                        const SizedBox(width: 6),
                      if (onEliminar != null)
                        _botonAdmin(
                          icono: Icons.delete_outline,
                          color: Colors.red,
                          onTap: onEliminar!,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  producto.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE91E63),
                          side: const BorderSide(color: Color(0xFFE91E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onVerMas,
                        child: const Text('Ver más'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onComprar,
                        child: const Text('Comprar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}