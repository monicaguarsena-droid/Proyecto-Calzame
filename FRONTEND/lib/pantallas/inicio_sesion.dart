import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

class InicioSesion extends StatelessWidget {
  const InicioSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoApp,
      appBar: AppBar(
        backgroundColor: ColoresApp.appbar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: ColoresApp.letra2,
          onPressed: () => Navigator.pop(context),
        ),
        
        title: const Text(
          'CALZAME',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: ColoresApp.letra2,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 35),
              ),
              const SizedBox(height: 10),
              const Text(
                'BIENVENIDOS A CALZAME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 50),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CORREO ELECTRONICO',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.letra2),
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'EMAIL.COM',
                  hintStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColoresApp.letra3),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xFFF48FB1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: ColoresApp.fondoApp)),
                  ),
                ),
            
              const SizedBox(height: 15),

              // Contraseña
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTRASEÑA',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ColoresApp.letra2),
                ),
              ),
              const SizedBox(height: 5),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(fontSize: 14, color: ColoresApp.letra3),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.visibility_off, color: Color(0xFFC26D8B), size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xFFF48FB1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xFFF48FB1)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (v) {},
                        activeColor: const Color(0xFFF48FB1),
                      ),
                      const Text('Recordarme', style: TextStyle(fontSize: 15, color: ColoresApp.letra)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidé mi Contraseña?',
                      style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 21, 122, 255)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),

              // Botón Iniciar Sesión 
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF48FB1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  
                  onPressed: () {},
                  child: const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const Divider(height: 30, thickness: 1, color: Color.fromARGB(255, 231, 71, 146)),
               

              // Registrarse
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta?', style: TextStyle(fontSize: 15)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Registrarse', style: TextStyle(fontSize: 15, color: Colors.blue)),
                  ),
                   const SizedBox(height: 70),
                ],
              ),
              const SizedBox(height: 5),
              const Text('O continuar con', style: TextStyle(fontSize: 14, color: ColoresApp.letra)),
              const SizedBox(height: 10),


              // Protección de datos
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