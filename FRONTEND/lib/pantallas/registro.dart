import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.background,
      appBar: AppBar(
        backgroundColor: ColoresApp.appBar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: ColoresApp.pinkTitle,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CALZAME',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: ColoresApp.pinkTitle,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'REGISTRARME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CEDULA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColoresApp.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'CORREO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColoresApp.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'NOMBRE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColoresApp.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'CONTRASEÑA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColoresApp.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'CONFIRMAR CONTRASEÑA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.wine,
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColoresApp.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.border),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        color: ColoresApp.onPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿YA TIENES CUENTA?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.wine,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'INICIA SECCIÓN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.link,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                '🔒 Tus datos están protegidos con encriptación de nivel empresarial',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8.5, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}