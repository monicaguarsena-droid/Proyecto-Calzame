import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/confimarcodigo.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';

class RecuperarCuenta extends StatefulWidget {
  final Future<void> Function(String email)? onEnviarCodigo;
  final VoidCallback? onIniciarSesion;
  final VoidCallback? onTerminos;
  final VoidCallback? onPolitica;

  const RecuperarCuenta({
    super.key,
    this.onEnviarCodigo,
    this.onIniciarSesion,
    this.onTerminos,
    this.onPolitica,
  });

  @override
  State<RecuperarCuenta> createState() => _RecuperarCuentaState();
}

class _RecuperarCuentaState extends State<RecuperarCuenta> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background, // Color de fondo crema
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Recupera tu cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Ingresa tu correo electrónico para recibir un código de verificación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 36),

                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: ColoresApp.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'ejemplo@correo.com',
                      hintStyle: const TextStyle(color: ColoresApp.hint),
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: ColoresApp.textSecondary,
                      ),
                      filled: true,
                      fillColor: ColoresApp.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ColoresApp.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ColoresApp.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColoresApp.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Te enviaremos un código de 6 dígitos a ese correo para que puedas continuar con la recuperación de tu cuenta.',
                    style: TextStyle(
                      color: ColoresApp.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón "Enviar código"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmarCodigo(),
                        ),
                      );
                      if (_formKey.currentState!.validate()) {
                        if (widget.onEnviarCodigo != null) {
                          widget.onEnviarCodigo!(_emailController.text.trim());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primary,
                      foregroundColor: ColoresApp.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Enviar código',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InicioSesion(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: '¿Recuerdas tu contraseña? ',
                          style: TextStyle(
                            color: ColoresApp.textSecondary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(
                                color: ColoresApp.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Al continuar, aceptas nuestros ',
                            style: TextStyle(
                              color: ColoresApp.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onTerminos,
                            child: const Text(
                              'Términos y condiciones',
                              style: TextStyle(
                                color: ColoresApp.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            ' y ',
                            style: TextStyle(
                              color: ColoresApp.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onPolitica,
                            child: const Text(
                              'Política de privacidad',
                              style: TextStyle(
                                color: ColoresApp.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            '.',
                            style: TextStyle(
                              color: ColoresApp.textSecondary,
                              fontSize: 11,
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
