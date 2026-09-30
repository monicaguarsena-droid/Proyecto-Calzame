import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/cors/colores.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key, this.nombre = ''});

  final String nombre;

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool _guardando = false;

  Future<void> _guardar() async {
    setState(() => _guardando = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColoresApp.pink,
        content: Text('Cambios guardados', style: _font(color: ColoresApp.onPink)),
      ),
    );
  }

  TextStyle _font({
    double size = 14,
    Color color = ColoresApp.wine,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.fondamento(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.appBar,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ColoresApp.pinkTitle),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'PERFIL',
          style: _font(
            size: 28,
            color: ColoresApp.pinkTitle,
            weight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                size: 28, color: ColoresApp.pinkTitle),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // Foto de perfil
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F3F4),
                        border: Border.all(color: ColoresApp.black, width: 4),
                      ),
                      // Reemplaza por la foto del usuario:
                      // child: ClipOval(child: Image.asset('assets/perfil.png', fit: BoxFit.cover)),
                      child: const Icon(Icons.person,
                          size: 70, color: ColoresApp.black),
                    ),
                    const SizedBox(height: 20),

                    // Nombre
                    Text(
                      widget.nombre,
                      style: _font(size: 24, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),

                    // Opciones
                    _OpcionPerfil(
                      icono: Icons.shopping_cart_outlined,
                      texto: 'Mis pedidos',
                      style: _font(size: 14, color: ColoresApp.black, weight: FontWeight.bold),
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _OpcionPerfil(
                      icono: Icons.location_on_outlined,
                      texto: 'Mis Direcciones',
                      style: _font(size: 14, color: ColoresApp.black, weight: FontWeight.bold),
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _OpcionPerfil(
                      icono: Icons.settings_outlined,
                      texto: 'Configuraciones',
                      style: _font(size: 14, color: ColoresApp.black, weight: FontWeight.bold),
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, color: ColoresApp.border),

            // Botón guardar
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.pink,
                    disabledBackgroundColor: ColoresApp.pink,
                    foregroundColor: ColoresApp.onPink,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: ColoresApp.onPink,
                          ),
                        )
                      : Text(
                          'Guardar',
                          style: _font(
                            size: 20,
                            color: ColoresApp.onPink,
                            weight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 44),

            // Mensaje de privacidad
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline,
                      size: 20, color: ColoresApp.pinkTitle),
                  const SizedBox(width: 8),
                  Text(
                    'Su datos no serán revelados a terceros',
                    style: _font(size: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de opción con icono a la izquierda y flecha a la derecha.
class _OpcionPerfil extends StatelessWidget {
  const _OpcionPerfil({
    required this.icono,
    required this.texto,
    required this.style,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColoresApp.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(icono, size: 20, color: ColoresApp.pink),
              const SizedBox(width: 8),
              Expanded(child: Text(texto, style: style)),
              const Icon(Icons.chevron_right,
                  size: 24, color: ColoresApp.pink),
            ],
          ),
        ),
      ),
    );
  }
}