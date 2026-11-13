import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/admin_panel.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/olvidocontrasena.dart';
import 'package:frontend/pantallas/registro.dart';
import 'package:frontend/servicios/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final String _adminEmail = "monicaguarsena@gmail.com";

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final emailIngresado = _emailController.text.trim();

    final result = await _authService.loginWithEmail(
      emailIngresado,
      _contrasenaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();

      // Guardar token si existe
      final tokenReal = result['data']?['token'] ?? result['token'];
      if (tokenReal != null) {
        await prefs.setString('token', tokenReal);
      }

      // Guardar el correo
      await prefs.setString('email', emailIngresado);

      // Guardar el nombre del usuario (soporta varias estructuras del backend)
      String nombreUsuario = 'Usuario';
      if (result['nombre'] != null) {
        nombreUsuario = result['nombre'];
      } else if (result['data']?['usuario']?['nombre'] != null) {
        nombreUsuario = result['data']['usuario']['nombre'];
      } else if (result['usuario']?['nombre'] != null) {
        nombreUsuario = result['usuario']['nombre'];
      } else {
        // Respaldo: la parte del correo antes del '@'
        nombreUsuario = emailIngresado.split('@').first;
      }

      await prefs.setString('nombre', nombreUsuario);

      if (!mounted) return;

      // Validar si el correo ingresado es el del administrador
      if (emailIngresado.toLowerCase() == _adminEmail.toLowerCase()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanel()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    } else {
      _showSnackBar(result['message'] ?? 'Error al iniciar sesión');
    }
  }

void _handleGoogleLogin() async {
  setState(() => _isLoading = true);

  final result = await _authService.loginWithGoogle();

  if (!mounted) return;
  setState(() => _isLoading = false);

  if (result['success']) {
    final data = Map<String, dynamic>.from(result['data']);
    await _authService.guardarSesion(data);

    final usuario = data['usuario'] is Map ? data['usuario'] : {};
    final email = (usuario['email'] ?? '').toString().trim().toLowerCase();
    final rol = (usuario['rol'] ?? '').toString().toLowerCase();
    final esAdmin = email == _adminEmail.toLowerCase() || rol == 'admin';

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => esAdmin ? AdminPanel() : Home(),
      ),
    );
  } else {
    _showSnackBar(result['message'] ?? 'Error con Google');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColoresApp.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }


  InputDecoration _decoracion({
    required String hint,
    required IconData icono,
    Widget? sufijo,
  }) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: ancho),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ColoresApp.hint, fontSize: 14),
      prefixIcon: Icon(icono, color: ColoresApp.textSecondary, size: 20),
      suffixIcon: sufijo,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: borde(ColoresApp.border),
      enabledBorder: borde(ColoresApp.border),
      focusedBorder: borde(ColoresApp.primary, 1.5),
      errorBorder: borde(Colors.red.shade300),
      focusedErrorBorder: borde(Colors.red.shade400, 1.5),
    );
  }

  Widget _etiqueta(String texto) => Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ColoresApp.primary,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Títulos
                  const Text(
                    '¡Bienvenido!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inicia sesión en Calzado Mar&Paz para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: ColoresApp.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Correo
                  _etiqueta('Correo electrónico'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: const TextStyle(color: ColoresApp.textPrimary),
                    decoration: _decoracion(
                      hint: 'ejemplo@correo.com',
                      icono: Icons.mail_outline,
                    ),
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                            ? 'Ingresa un correo válido'
                            : null,
                  ),
                  const SizedBox(height: 18),

                  // Contraseña
                  _etiqueta('Contraseña'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: ColoresApp.textPrimary),
                    decoration: _decoracion(
                      hint: '••••••••',
                      icono: Icons.lock_outline,
                      sufijo: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: ColoresApp.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Mínimo 6 caracteres'
                        : null,
                  ),

                  // ¿Olvidaste tu contraseña?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecuperarCuenta()),
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: ColoresApp.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Iniciar sesión
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.primary,
                        disabledBackgroundColor: ColoresApp.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Crear cuenta
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ColoresApp.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Registro(),
                                ),
                              ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: ColoresApp.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Divisor
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o continuar con',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // Google
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GoogleLogo(size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Google',
                            style: TextStyle(
                              color: Color(0xFF4A4A4A),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;

  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _rojo = Color(0xFFEA4335);
  static const _amarillo = Color(0xFFFBBC05);
  static const _verde = Color(0xFF34A853);
  static const _azul = Color(0xFF4285F4);

  double _rad(double grados) => grados * 3.141592653589793 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.width;
    final grosor = lado * 0.2;
    final rect = Rect.fromLTWH(
      grosor / 2,
      grosor / 2,
      lado - grosor,
      lado - grosor,
    );

    Paint pincel(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..color = color;
    canvas.drawArc(rect, _rad(-140), _rad(100), false, pincel(_rojo)); // arriba
    canvas.drawArc(rect, _rad(140), _rad(80), false, pincel(_amarillo)); // izquierda
    canvas.drawArc(rect, _rad(40), _rad(100), false, pincel(_verde)); // abajo
    canvas.drawArc(rect, _rad(-5), _rad(45), false, pincel(_azul)); // derecha

    // Barra horizontal de la "G"
    final barra = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.butt
      ..color = _azul;
    canvas.drawLine(
      Offset(lado / 2, lado / 2),
      Offset(lado - grosor / 2, lado / 2),
      barra,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}