import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';
import 'package:frontend/pantallas/verificacioncongoogle.dart';
import 'package:frontend/servicios/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/pantallas/admin_panel.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormState>();

  // Colores
  static const Color primaryColor = Color.fromARGB(255, 96, 24, 46);
  static const Color backgroundColor = Color.fromARGB(255, 251, 248, 246);
  static const Color labelColor = Color.fromARGB(255, 97, 27, 48);

  // Controladores
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmcontrasenaController =
      TextEditingController();

  final AuthService _authService = AuthService();

  // 'CC' = Cédula de ciudadanía, 'TI' = Tarjeta de identidad
  String _tipoDocumento = 'CC';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _documentoController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _confirmcontrasenaController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Lógica
  // ---------------------------------------------------------------------------

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_contrasenaController.text.trim() !=
        _confirmcontrasenaController.text.trim()) {
      _showSnackBar('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.registerWithEmail(
      tipoDocumento: _tipoDocumento,
      cedula: _documentoController.text.trim(),
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('¡Registro exitoso! Revisa tu correo');

      final email = _emailController.text.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('nombre', _nombreController.text.trim());
      await prefs.setString('tipo_documento', _tipoDocumento);

      if (!mounted) return;

      // Navegamos a la pantalla de VerificaciónCorreo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => VerificacionCorreo(
            email: email,
            onVerificar: (codigo) async {
              final verifResult = await _authService.verificarCodigo(
                email,
                codigo,
              );

              if (verifResult['success']) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              } else {
                throw Exception(verifResult['message'] ?? 'Código incorrecto');
              }
            },
            onReenviar: () async {
              await _authService.reenviarCodigo(email);
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

  if (!mounted) return;
  setState(() => _isLoading = false);

  if (result['success']) {
    final data = Map<String, dynamic>.from(result['data']);
    await _authService.guardarSesion(data);

    final usuario = data['usuario'] is Map ? data['usuario'] : {};
    final email = (usuario['email'] ?? '').toString().trim().toLowerCase();
    final rol = (usuario['rol'] ?? '').toString().toLowerCase();
    final esAdmin = email == 'monicaguarsena@gmail.com' || rol == 'admin';

    if (!mounted) return;

    // Limpia la pila para que "atrás" no vuelva al registro
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => esAdmin ? AdminPanel() : Home()),
      (route) => false,
    );
  } else {
    _showSnackBar(result['message'] ?? 'Error con Google');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Reglas: mínimo 6 caracteres, 1 mayúscula, 1 minúscula,
  /// 2 números y 1 símbolo.
  String? _validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos una mayúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe incluir al menos una minúscula';
    }
    if (RegExp(r'\d').allMatches(value).length < 2) {
      return 'Debe incluir al menos dos números';
    }
    // Símbolos ASCII: ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
    if (!RegExp(r'[!-/:-@\[-`{-~]').hasMatch(value)) {
      return 'Debe incluir al menos un símbolo (, . # @ ! etc.)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Helpers de UI
  // ---------------------------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: labelColor,
        fontSize: 15,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      helperText: helperText,
      helperMaxLines: 2,
      helperStyle: const TextStyle(fontSize: 12, color: Color(0xFF8C8C8C)),
      errorMaxLines: 2,
      prefixIcon: Icon(
        icon,
        color: const Color.fromARGB(255, 135, 134, 134),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
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
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _tipoDocumentoChip({required String value, required String text}) {
    final selected = _tipoDocumento == value;
    return Expanded(
      child: ChoiceChip(
        label: SizedBox(
          width: double.infinity,
          child: Text(text, textAlign: TextAlign.center),
        ),
        selected: selected,
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _tipoDocumento = value;
            _documentoController.clear();
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
                      "Bienvenido a Mar&Paz",
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

                  // Tipo de documento
                  _label("Tipo de documento"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _tipoDocumentoChip(value: 'CC', text: "Cédula"),
                      const SizedBox(width: 10),
                      _tipoDocumentoChip(
                        value: 'TI',
                        text: "Tarjeta de identidad",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Número de documento
                  _label(
                    _tipoDocumento == 'CC'
                        ? "Número de cédula"
                        : "Número de tarjeta de identidad",
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _documentoController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: _inputDecoration(
                      icon: Icons.credit_card,
                      hint: "Número de documento",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu número de documento';
                      }
                      if (value.length < 6) {
                        return 'El número de documento es muy corto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nombre completo
                  _label("Nombre completo"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: _inputDecoration(
                      icon: Icons.person_outline,
                      hint: "Nombre y apellido",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Correo electrónico
                  _label("Correo electrónico"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: _inputDecoration(
                      icon: Icons.email_outlined,
                      hint: "ejemplo@correo.com",
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
                  _label("Contraseña"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline,
                      hint: "••••••••",
                      helperText:
                          "Mínimo 6 caracteres, con 1 mayúscula, 1 minúscula, 2 números y 1 símbolo",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color.fromARGB(255, 75, 75, 75),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: _validarContrasena,
                  ),
                  const SizedBox(height: 16),

                  // Confirmar contraseña
                  _label("Confirmar contraseña"),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmcontrasenaController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: primaryColor, fontSize: 14),
                    decoration: _inputDecoration(
                      icon: Icons.lock_outline,
                      hint: "••••••••",
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (value != _contrasenaController.text) {
                        return 'Las contraseñas no coinciden';
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
                      onPressed: () => Navigator.pop(context),
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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