import 'package:flutter/material.dart';
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

  final Color _primaryColor = const Color(0xFF6B2D3C);
  final Color _backgroundColor = const Color(0xFFF7F4F0);

  final String _adminEmail = "monicaguarsena@gmail.com";

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final emailIngresado = _emailController.text.trim();

    final result = await _authService.loginWithEmail(
      emailIngresado,
      _contrasenaController.text.trim(),
    );
    
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
      
      // GUARDAR EL NOMBRE DEL USUARIO (Soporta múltiples estructuras del backend)
      String nombreUsuario = 'Usuario';
      if (result['nombre'] != null) {
        nombreUsuario = result['nombre'];
      } else if (result['data']?['usuario']?['nombre'] != null) {
        nombreUsuario = result['data']['usuario']['nombre'];
      } else if (result['usuario']?['nombre'] != null) {
        nombreUsuario = result['usuario']['nombre'];
      } else {
        // Si no viene el nombre explícito, extraemos la parte antes del '@' del correo como respaldo
        nombreUsuario = emailIngresado.split('@').first;
      }
      
      await prefs.setString('nombre', nombreUsuario);

      // Verificamos si el widget sigue montado antes de usar el context
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
      if (!mounted) return;
      _showSnackBar(result['message'] ?? 'Error al iniciar sesión');
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.loginWithGoogle();

    setState(() => _isLoading = false);

    if (result['success']) {
      final userData = result['data']?['usuario'] ?? result['usuario'] ?? {};
      final String userEmail = (userData['email'] ?? result['data']?['email'] ?? '').trim();
      final String nombre = userData['nombre'] ?? userData['name'] ?? userEmail.split('@').first;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', userEmail);
      await prefs.setString('nombre', nombre);

      if (!mounted) return;

      if (userEmail.toLowerCase() == _adminEmail.toLowerCase()) {
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
      if (!mounted) return;
      _showSnackBar(result['message'] ?? 'Error con Google');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
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
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 36,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Bienvenido!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Inicia sesión en Calzado Mar&Paz para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Correo electrónico',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.email_outlined, color: _primaryColor, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) => (value == null || !value.contains('@')) ? 'Ingresa un correo válido' : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Contraseña',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline, color: _primaryColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecuperarCuenta())),
                      child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: _primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botón de Google conectado a _handleGoogleLogin
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      icon: Icon(Icons.g_mobiledata, color: _primaryColor, size: 28),
                      label: Text('Continuar con Google', style: TextStyle(color: _primaryColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Registro())),
                      child: Text('Crear cuenta nueva', style: TextStyle(color: _primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
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