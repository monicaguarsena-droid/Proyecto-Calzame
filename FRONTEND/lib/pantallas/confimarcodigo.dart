import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class ConfirmarCodigo extends StatefulWidget {
  final String? emailInicial;
  final Future<void> Function(String email, String codigo, String nuevaContrasena)? onConfirmarCambio;
  final VoidCallback? onReenviarCodigo;
  final VoidCallback? onTerminos;
  final VoidCallback? onPolitica;

  const ConfirmarCodigo({
    super.key,
    this.emailInicial,
    this.onConfirmarCambio,
    this.onReenviarCodigo,
    this.onTerminos,
    this.onPolitica,
  });

  @override
  State<ConfirmarCodigo> createState() => _ConfirmarCodigoState();
}

class _ConfirmarCodigoState extends State<ConfirmarCodigo> {
  late final TextEditingController _emailController;
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.emailInicial ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background, // Fondo crema de la app
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
                  // Título principal
                  const Text(
                    'Confirma tu código',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtítulo descriptivo
                  const Text(
                    'Ingresa el código que llegó a tu correo\ny crea una nueva contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Correo electrónico
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                        borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 2. Campo: Código de 6 dígitos
                  const Text(
                    'Código de 6 dígitos',
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(color: ColoresApp.textPrimary, letterSpacing: 2),
                    decoration: InputDecoration(
                      counterText: '', // Oculta el contador de caracteres de maxLength
                      hintText: '123456',
                      hintStyle: const TextStyle(color: ColoresApp.hint, letterSpacing: 1),
                      prefixIcon: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: ColoresApp.textSecondary,
                      ),
                      filled: true,
                      fillColor: ColoresApp.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                        borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Ingresa el código completo de 6 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Campo: Nueva contraseña
                  const Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: ColoresApp.textPrimary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: ColoresApp.hint),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: ColoresApp.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: ColoresApp.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: ColoresApp.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                        borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Botón principal "Confirmar cambio de contraseña"
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.onConfirmarCambio != null) {
                          widget.onConfirmarCambio!(
                            _emailController.text.trim(),
                            _codigoController.text.trim(),
                            _passwordController.text.trim(),
                          );
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
                      'Confirmar cambio de contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link inferior "¿No recibiste el código? Volver a enviar"
                  Center(
                    child: GestureDetector(
                      onTap: widget.onReenviarCodigo,
                      child: const Text(
                        '¿No recibiste el código? Volver a enviar',
                        style: TextStyle(
                          color: ColoresApp.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Términos y políticas al pie
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