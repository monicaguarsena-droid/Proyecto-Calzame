import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';
import 'package:frontend/pantallas/registro.dart';
import 'package:frontend/pantallas/verificacion.dart'; // Asegúrate de que el nombre del archivo coincida

class InicioSesion extends StatelessWidget {
  const InicioSesion({super.key});

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ColoresApp.pinkTitle, letterSpacing: 1.5),
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
                backgroundColor: ColoresApp.black,
                child: Icon(Icons.person, color: ColoresApp.onPink, size: 35),
              ),
              const SizedBox(height: 10),
              const Text(
                'BIENVENIDOS A CALZAME',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ColoresApp.wine),
              ),
              const SizedBox(height: 30),
              _buildField('CORREO ELECTRONICO', 'EMAIL.COM', false),
              const SizedBox(height: 15),
              _buildField('CONTRASEÑA', '••••••••', true),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (v) {}, activeColor: ColoresApp.pink),
                      const Text('Recordarme', style: TextStyle(fontSize: 14, color: ColoresApp.wine)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Verification(),
                        ),
                      );
                    },
                    child: const Text('¿Olvidé mi Contraseña?', style: TextStyle(fontSize: 13, color: ColoresApp.link)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {},
                  child: const Text('INICIAR SESIÓN', style: TextStyle(color: ColoresApp.onPink, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const Divider(height: 30, thickness: 1, color: ColoresApp.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta?', style: TextStyle(fontSize: 14, color: ColoresApp.wine)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Registro())),
                    child: const Text('Registrarse', style: TextStyle(fontSize: 14, color: ColoresApp.link)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
  Widget _buildField(String label, String hint, bool isPassword) {
    const borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      borderSide: BorderSide(color: ColoresApp.border),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColoresApp.wine)),
        const SizedBox(height: 5),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: isPassword ? 14 : 12, fontWeight: isPassword ? FontWeight.normal : FontWeight.w600, color: ColoresApp.hint),
            filled: true,
            fillColor: ColoresApp.surface,
            suffixIcon: isPassword ? const Icon(Icons.visibility_off, color: ColoresApp.pink, size: 20) : null,
            border: borderStyle,
            enabledBorder: borderStyle,
          ),
        ),
      ],
    );
  }
}
