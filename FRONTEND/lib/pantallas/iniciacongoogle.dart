import 'package:flutter/material.dart';
import 'package:frontend/pantallas/home.dart';
import 'package:frontend/servicios/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Instancia oficial de GoogleSignIn para evitar el error rojo
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Lista simulada o dinámica de cuentas previas en el dispositivo
  final List<Map<String, String>> _savedAccounts = [];

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1. Cierra sesión previa y abre el selector de cuentas de Google
      await _googleSignIn.signOut(); 
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        setState(() => _isLoading = false);
        return;
      }

      // 2. Obtiene los detalles de autenticación (tokens) si los necesitas enviar al backend
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Llama a tu servicio de autenticación
      final result = await _authService.loginWithGoogle();

      if (!mounted) return;

      setState(() => _isLoading = false);
    
      if (result['success'] == true) {
        // Navegar a la pantalla principal de CalzaMe
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const Home())
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar sesión con Google')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores basados en la identidad visual de CalzaMe (Tonos vino tinto y fondo crema)
    const Color primaryColor = Color(0xFF6B2D3C);
    const Color backgroundColor = Color(0xFFFBF8F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Icono de Google superior
              Image.network(
                'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                height: 40,
              ),
              const SizedBox(height: 20),
              const Text(
                'Elige una cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Continúa a CalzaMe',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Lista de cuentas guardadas / Selector
              Expanded(
                child: ListView(
                  children: [
                    ..._savedAccounts.map(
                      (account) => _buildAccountCard(
                        name: account['name']!,
                        email: account['email']!,
                        initials: account['initials']!,
                        isSelected: false,
                        onTap: _handleGoogleLogin,
                        primaryColor: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón para usar otra cuenta
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Colors.transparent),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _handleGoogleLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Usar otra cuenta',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador de carga si está autenticando
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: primaryColor),
                ),

              // Términos y condiciones
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Al continuar, aceptas nuestros Términos y condiciones y Política de privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String name,
    required String email,
    required String initials,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Text(
            initials,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: primaryColor)
            : null,
        onTap: onTap,
      ),
    );
  }
}