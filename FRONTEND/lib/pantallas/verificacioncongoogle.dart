import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/cors/colores.dart';

class VerificacionCorreo extends StatefulWidget {
  final String email;
  /// Lanza una excepción si el código es inválido.
  final Future<void> Function(String codigo)? onVerificar;
  /// Se llama al pulsar "Enviar código nuevamente".
  final Future<void> Function()? onReenviar;

  const VerificacionCorreo({
    super.key,
    required this.email,
    this.onVerificar,
    this.onReenviar,
  });

  @override
  State<VerificacionCorreo> createState() =>
      _VerificacionCorreoState();
}

class _VerificacionCorreoState extends State<VerificacionCorreo> {
  static const int _longitud = 6;

  final List<TextEditingController> _controllers =
      List.generate(_longitud, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_longitud, (_) => FocusNode());

  bool _cargando = false;
  String? _error;

  String get _codigo => _controllers.map((c) => c.text).join();
  bool get _completo => _codigo.length == _longitud;

  @override
  void initState() {
    super.initState();
    for (final f in _focusNodes) {
      f.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    setState(() => _error = null);

    // Soporta pegar el código completo o escribir sobre una casilla llena.
    if (value.length > 1) {
      final digitos = value.split('');
      for (var i = 0; i < digitos.length && index + i < _longitud; i++) {
        _controllers[index + i].text = digitos[i];
      }
      final siguiente = (index + digitos.length).clamp(0, _longitud - 1);
      _focusNodes[siguiente].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _longitud - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _continuar() async {
    if (!_completo) {
      setState(() => _error = 'Ingresa el código de 6 dígitos');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await widget.onVerificar?.call(_codigo);
    } catch (_) {
      if (mounted) setState(() => _error = 'Código inválido o expirado');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _reenviar() async {
    try {
      await widget.onReenviar?.call();
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te enviamos un nuevo código')),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo reenviar el código');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Verificación de\ncorreo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa el código que enviamos a tu correo\npara activar tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ColoresApp.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildCodigoCard(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.primary,
                      foregroundColor: ColoresApp.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColoresApp.textOnPrimary,
                            ),
                          )
                        : const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _cargando ? null : _reenviar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColoresApp.primary,
                      backgroundColor: ColoresApp.surface,
                      side: const BorderSide(color: ColoresApp.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enviar código nuevamente',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text.rich(
                  TextSpan(
                    text: 'Si no recibiste el correo, ',
                    children: [
                      TextSpan(
                        text: 'revisa tu carpeta de spam',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColoresApp.primary,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColoresApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodigoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Código de verificación',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ColoresApp.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Te enviamos un código de 6 dígitos a\n${widget.email}',
            style: const TextStyle(
              fontSize: 13,
              color: ColoresApp.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_longitud, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == _longitud - 1 ? 0 : 8),
                  child: _buildCasilla(i),
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: ColoresApp.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCasilla(int index) {
    final enfocada = _focusNodes[index].hasFocus;
    final conValor = _controllers[index].text.isNotEmpty;
    final resaltada = enfocada || conValor;

    return AspectRatio(
      aspectRatio: 0.82,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(index);
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _onChanged(index, v),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ColoresApp.primary,
          ),
          cursorColor: ColoresApp.primary,
          decoration: InputDecoration(
            hintText: '•',
            hintStyle: const TextStyle(
              fontSize: 20,
              color: ColoresApp.textSecondary,
            ),
            filled: true,
            fillColor: ColoresApp.background,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: resaltada ? ColoresApp.primary : ColoresApp.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColoresApp.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}