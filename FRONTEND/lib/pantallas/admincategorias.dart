import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart'; 
import 'package:frontend/pantallas/admin_ofertas.dart';
import 'package:frontend/pantallas/adminagregarcategoria.dart';

class AdminCategorias extends StatefulWidget {
  const AdminCategorias({Key? key}) : super(key: key);

  @override
  State<AdminCategorias> createState() => _AdminCategoriasState();
}

class _AdminCategoriasState extends State<AdminCategorias> {
  int _tabIndex = 0;

  // Lista totalmente vacía
  final List<Map<String, dynamic>> _categorias = [];

  // Modal para ver los detalles de la categoría creada
  void _mostrarDetalles(Map<String, dynamic> cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  cat['nombre'] ?? '',
                  style: const TextStyle(
                    color: ColoresApp.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: ColoresApp.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '0 productos activos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cat['descripcion'] ?? 'Sin descripción disponible',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera con botón Atrás
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: ColoresApp.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestión del Catálogo',
                        style: TextStyle(
                          color: ColoresApp.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Administra categorías y promociones',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Selector de Pestañas (Categorías / Ofertas)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? ColoresApp.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Categorías de Calzado',
                            style: TextStyle(
                              color: _tabIndex == 0 ? Colors.white : ColoresApp.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? ColoresApp.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Ofertas y Banners',
                            style: TextStyle(
                              color: _tabIndex == 1 ? Colors.white : ColoresApp.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Contador y Botón "Agregar categoría"
              if (_tabIndex == 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: ColoresApp.primary, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_categorias.length} categorías activas',
                          style: const TextStyle(
                            color: ColoresApp.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminAgregarCategoria(),
                          ),
                        );
                        if (resultado != null && resultado is Map<String, dynamic>) {
                          setState(() {
                            _categorias.add(resultado);
                          });
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text(
                        'Agregar categoría',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // 4. Listado o Mensaje Vacío
              _tabIndex == 0
                  ? (_categorias.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.category_outlined, size: 60, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay categorías registradas',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Presiona "Agregar categoría" para crear una.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categorias.length,
                          itemBuilder: (context, index) {
                            final cat = _categorias[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () => _mostrarDetalles(cat),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cat['nombre'] ?? '',
                                                    style: const TextStyle(
                                                      color: ColoresApp.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '0 productos',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: ColoresApp.primary.withOpacity(0.06),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.chevron_right,
                                                color: ColoresApp.primary,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              final resultado = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AdminAgregarCategoria(categoria: cat),
                                                ),
                                              );
                                              if (resultado != null && resultado is Map<String, dynamic>) {
                                                setState(() {
                                                  _categorias[index] = resultado;
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: ColoresApp.primary,
                                              side: BorderSide(color: Colors.grey.shade300),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _categorias.removeAt(index);
                                              });
                                            },
                                            icon: const Icon(Icons.delete_outline, size: 16),
                                            label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: ColoresApp.primary,
                                              side: BorderSide(color: Colors.grey.shade300),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ))
                  : const AdminOfertasPage(),
            ],
          ),
        ),
      ),
    );
  }
}