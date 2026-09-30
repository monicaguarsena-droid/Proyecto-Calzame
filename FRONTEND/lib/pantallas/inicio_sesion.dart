import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/registro.dart';
import 'package:frontend/pantallas/verificacion.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de que el nombre del archivo coincida

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  InputDecoration _inputDecoration({
    required String hint,
    required Widget suffix,
  }) {
    OutlineInputBorder border() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColoresApp.border, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: _font(size: 12, color: ColoresApp.hint),
      filled: true,
      fillColor: ColoresApp.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: border(),
      focusedBorder: border(),
      border: border(),
      suffixIcon: suffix,
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: ColoresApp.pinkTitle,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'CALZAME',
          style: _font(
            size: 30,
            color: ColoresApp.pinkTitle,
            weight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Logo
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        // child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover)),
                        child:
                          Image.asset('name')
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'BIENVENIDA A CALZAME',
                        style: _font(size: 16, weight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Correo
                    Text(
                      'CORREO ELECTRONICO',
                      style: _font(size: 14, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: _font(size: 13),
                      decoration: _inputDecoration(
                        hint: 'EMAIL.COM',
                        suffix: const Icon(
                          Icons.visibility_outlined,
                          color: ColoresApp.pink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
                    Text(
                      'CONTRASEÑA',
                      style: _font(size: 14, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: _font(size: 13),
                      decoration: _inputDecoration(
                        hint: '- - - - - - - -',
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: ColoresApp.pink,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Recordarme / Olvidé contraseña
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            side: const BorderSide(color: ColoresApp.pink),
                            activeColor: ColoresApp.pink,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Recordarme', style: _font(size: 12)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            '¿Olvidé mi Contraseña?',
                            style: _font(size: 12, color: ColoresApp.link),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Botón iniciar sesión
                    Center(
                      child: SizedBox(
                        width: 190,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>Verification(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.pink,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'INICIAR SESIÓN',
                            style: _font(
                              size: 14,
                              color: Colors.white,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Parte inferior
            const Divider(height: 1, color: ColoresApp.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes una cuenta?', style: _font(size: 12)),
                      const SizedBox(width: 18),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Registro()),
                          );
                        },
                        child: Text(
                          'Registrarse',
                          style: _font(size: 12, color: ColoresApp.link),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'O continuar con',
                    style: _font(size: 14, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 190,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reemplaza por Image.asset('assets/google.png', width: 20)
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4285F4),
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Google',
                            style: _font(
                              size: 15,
                              color: Colors.black,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: ColoresApp.pinkTitle,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Tus datos están protegidos con encriptación de nivel empresarial',
                          textAlign: TextAlign.center,
                          style: _font(size: 10),
                        ),
                      ),
                    ],
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