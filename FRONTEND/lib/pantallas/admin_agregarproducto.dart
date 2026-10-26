import 'package:flutter/material.dart';


class AdminAgregarProducto extends StatefulWidget {
  const AdminAgregarProducto({super.key});

  @override
  State<AdminAgregarProducto> createState() => _AdminAgregarProductoState();
}

class _AdminAgregarProductoState extends State<AdminAgregarProducto> {
  String _categoriaSeleccionada = 'Dama';
  final List<String> _tallasDisponibles = ['30', '31', '32', '33', '34', '35', '36', '37', '38', '39'];
  final List<String> _tallasSeleccionadas = [];

  final Color _primaryColor = const Color.fromARGB(255, 97, 24, 46);
  final Color _backgroundColor = const Color(0xFFF7F4F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con botón Atrás
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: _primaryColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Atrás',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Agregar Producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tarjeta Subir Imagen
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 36, color: _primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      'Subir imagen del calzado',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campo Nombre
              Text(
                'Nombre del producto',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Sandalia de tiras',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              Text(
                'Categoría',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _categoriaSeleccionada,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                    items: ['Dama', 'Caballero', 'Infantil'].map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _categoriaSeleccionada = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Precio y Stock
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio (\$)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock (Unidades)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: _primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                'Descripción del calzado',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Descripción del calzado',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tallas
              Text(
                'Tallas disponibles',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _tallasDisponibles.length,
                  itemBuilder: (context, index) {
                    final talla = _tallasDisponibles[index];
                    final seleccionada = _tallasSeleccionadas.contains(talla);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(talla),
                        selected: seleccionada,
                        selectedColor: _primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: seleccionada ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: seleccionada ? _primaryColor : Colors.grey.shade200),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tallasSeleccionadas.add(talla);
                            } else {
                              _tallasSeleccionadas.remove(talla);
                            }
                          });
                        },
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('¡Producto guardado exitosamente!'),
                        backgroundColor: _primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'Guardar Producto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}