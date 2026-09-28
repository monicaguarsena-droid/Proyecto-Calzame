import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class Verification extends StatefulWidget {
  const Verification({Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _codeController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_validateCode);
  }

  void _validateCode() {
    setState(() {
      _isButtonEnabled = _codeController.text.length == 6;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.appBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: ColoresApp.pinkTitle,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'CALZAME',
          style: TextStyle(
            color: ColoresApp.pinkTitle,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'VERIFICACION DE CORRREO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresApp.wine,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'A tu correo le llegara un\ncodigo de 6 (seis) digitos\nPor Favor colocar en la\nsiguientes casillas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresApp.wine,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'CODIGO',
                style: TextStyle(
                  color: ColoresApp.wine,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: ColoresApp.wine),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: ColoresApp.surface,
                  hintText: '· · · · · ·',
                  hintStyle: const TextStyle(color: ColoresApp.hint),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColoresApp.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColoresApp.pink,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled ? ColoresApp.pink : ColoresApp.hint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isButtonEnabled ? () {} : null,
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: ColoresApp.onPink,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: ColoresApp.pinkTitle,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tus datos están protegidos con encriptación de nivel empresarial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresApp.wine,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}