import 'package:flutter/material.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/verificacioncongoogle.dart';
import 'package:frontend/servicios/auth_service.dart'; // Asegúrate de importar tu AuthService
import 'package:shared_preferences/shared_preferences.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmcontrasenaController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _confirmcontrasenaController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_contrasenaController.text.trim() !=
        _confirmcontrasenaController.text.trim()) {
      _showSnackBar('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.registerWithEmail(
      cedula: _cedulaController.text.trim(),
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('¡Registro exitoso! Revisa tu correo');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text.trim());
      await prefs.setString('nombre', _nombreController.text.trim());
      //Navegamos a la pantalla de VerificaciónCorreo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificacionCorreo(
            email: _emailController.text.trim(),
            onVerificar: (codigo) async {
              // Llamamos al servicio de backend para verificar el código en la BD
              final verifResult = await _authService.verificarCodigo(
                _emailController.text.trim(),
                codigo,
              );

              if (verifResult['success']) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
              } else {
                // AQUÍ CAMBIAMOS: Lanzamos el mensaje real que venga del backend (ej. Supabase o Express)
                throw Exception(verifResult['message'] ?? 'Código incorrecto');
              }
            },
            onReenviar: () async {
              // Llamamos al servicio para solicitar un nuevo código de verificación
              await _authService.reenviarCodigo(_emailController.text.trim());
            },
          ),
        ),
      );
    } else {
      _showSnackBar(result['message'] ?? 'Error al registrar el usuario');
    }
  }

  void _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    final result = await _authService.loginWithGoogle();

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      _showSnackBar(result['message'] ?? 'Error con Google');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 96, 24, 46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 96, 24, 46);
    const backgroundColor = Color.fromARGB(255, 251, 248, 246);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Bienvenida a CalzaMe",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 111, 30, 54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      "Regístrate para empezar a comprar",
                      style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cédula
                  const Text(
                    "Cédula",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 97, 27, 48),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.credit_card,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: "0000000000",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu cédula';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nombre completo
                  const Text(
                    "Nombre completo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 97, 27, 48),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: "Nombre y apellido",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu nombre completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Correo electrónico
                  const Text(
                    "Correo electrónico",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 97, 27, 48),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: "ejemplo@correo.com",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  const Text(
                    "Contraseña",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 27, 49),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 135, 134, 134),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color.fromARGB(255, 75, 75, 75),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      hintText: "••••••••",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirmar contraseña
                  const Text(
                    "Confirmar contraseña",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 27, 49),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmcontrasenaController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 135, 134, 134),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color.fromARGB(255, 75, 75, 75),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      hintText: "••••••••",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón Crear cuenta
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 106, 29, 51),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Crear cuenta",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón Ya tengo cuenta
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor, width: 1),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Ya tengo cuenta",
                        style: TextStyle(
                          color: Color.fromARGB(255, 106, 25, 49),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "o continuar con",
                          style: TextStyle(
                            color: Color.fromARGB(255, 106, 106, 106),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón Google
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleRegister,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "G",
                            style: TextStyle(
                              color: Color(0xFFEA4335),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Google",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color.fromARGB(255, 113, 113, 113),
                          fontSize: 13,
                          height: 1.8,
                        ),
                        children: [
                          TextSpan(text: "Al continuar, aceptas nuestros "),
                          TextSpan(
                            text: "Términos y\ncondiciones",
                            style: TextStyle(
                              color: Color.fromARGB(255, 90, 25, 45),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: " y "),
                          TextSpan(
                            text: "Política de privacidad",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: "."),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
