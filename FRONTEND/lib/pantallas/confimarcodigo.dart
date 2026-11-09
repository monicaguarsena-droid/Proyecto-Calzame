import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';
import 'package:frontend/servicios/recuperar_service.dart';

class ConfirmarCodigo extends StatefulWidget {
  final String? emailInicial;
  final Future<void> Function(String email, String codigo, String nuevaContrasena)?
      onConfirmarCambio;
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
  final _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _enviando = false;
  bool _reenviando = false;
  int _segundosEspera = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.emailInicial ?? '');
    _iniciarEspera(); // el código acaba de enviarse: esperamos antes de reenviar
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codigoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _iniciarEspera() {
    _timer?.cancel();
    _segundosEspera = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _segundosEspera--);
      if (_segundosEspera <= 0) t.cancel();
    });
  }

  void _mostrar(String mensaje, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? ColoresApp.error : ColoresApp.primary,
      ),
    );
  }

  Future<void> _confirmar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final codigo = _codigoController.text.trim();
    final nueva = _contrasenaController.text.trim();

    setState(() => _enviando = true);
    try {
      if (widget.onConfirmarCambio != null) {
        await widget.onConfirmarCambio!(email, codigo, nueva);
      } else {
        await RecuperacionService.restablecer(
          email: email,
          codigo: codigo,
          nuevaContrasena: nueva,
        );
      }
      if (!mounted) return;
      _mostrar(
        'Contraseña actualizada. Inicia sesión con tu nueva contraseña.',
        error: false,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _mostrar(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _reenviar() async {
    if (_reenviando || _segundosEspera > 0) return;

    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _mostrar('Escribe tu correo para reenviar el código');
      return;
    }

    setState(() => _reenviando = true);
    try {
      widget.onReenviarCodigo?.call();
      await RecuperacionService.solicitarCodigo(email);
      if (!mounted) return;
      setState(_iniciarEspera);
      _mostrar('Te enviamos un nuevo código', error: false);
    } catch (error) {
      if (!mounted) return;
      _mostrar(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _reenviando = false);
    }
  }

  InputDecoration _decoracion({
    required String hint,
    required IconData icono,
    Widget? sufijo,
    bool ocultarContador = false,
  }) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: ancho),
        );
    return InputDecoration(
      counterText: ocultarContador ? '' : null,
      hintText: hint,
      hintStyle: const TextStyle(color: ColoresApp.hint),
      prefixIcon: Icon(icono, color: ColoresApp.textSecondary),
      suffixIcon: sufijo,
      filled: true,
      fillColor: ColoresApp.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: borde(ColoresApp.border),
      enabledBorder: borde(ColoresApp.border),
      focusedBorder: borde(ColoresApp.primary, 1.5),
    );
  }

  Widget _etiqueta(String texto) => Text(
        texto,
        style: const TextStyle(
          color: ColoresApp.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final puedeReenviar = _segundosEspera <= 0 && !_reenviando;

    return Scaffold(
      backgroundColor: ColoresApp.background,
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
                    'Confirma tu código',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                  _etiqueta('Correo electrónico'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: ColoresApp.textPrimary),
                    decoration: _decoracion(
                      hint: 'ejemplo@correo.com',
                      icono: Icons.mail_outline,
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Ingresa tu correo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _etiqueta('Código de 6 dígitos'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      color: ColoresApp.textPrimary,
                      letterSpacing: 2,
                    ),
                    decoration: _decoracion(
                      hint: '123456',
                      icono: Icons.mark_email_unread_outlined,
                      ocultarContador: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Ingresa el código completo de 6 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _etiqueta('Nueva contraseña'),
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
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: ColoresApp.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
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

                  ElevatedButton(
                    onPressed: _enviando ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primary,
                      foregroundColor: ColoresApp.textOnPrimary,
                      disabledBackgroundColor: ColoresApp.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _enviando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirmar cambio de contraseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: puedeReenviar ? _reenviar : null,
                      child: Text(
                        _reenviando
                            ? 'Enviando código…'
                            : _segundosEspera > 0
                                ? '¿No recibiste el código? Reenviar en $_segundosEspera s'
                                : '¿No recibiste el código? Volver a enviar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: puedeReenviar
                              ? ColoresApp.primary
                              : ColoresApp.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

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