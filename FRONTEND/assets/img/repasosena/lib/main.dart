import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MenuPrincipalScreen(),
    );
  }
}

// ==========================================
// MENÚ PRINCIPAL
// ==========================================
class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('evelyne')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Ejercicio1Screen(),
                    ),
                  );
                },
                child: const Text('estilos de texto'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Ejercicio2Screen(),
                    ),
                  );
                },
                child: const Text('registro'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Ejercicio3Screen(),
                    ),
                  );
                },
                child: const Text('iconos'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Ejercicio4Screen(),
                    ),
                  );
                },
                child: const Text('botones'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 1: Texto Estilizado
// ==========================================
class Ejercicio1Screen extends StatelessWidget {
  const Ejercicio1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Texto Estilizado')),
      body: const SafeArea(
        child: Center(
          child: Text(
            "Hola Mundo!",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              wordSpacing: 10,
              letterSpacing: 5,
              backgroundColor: Colors.yellowAccent,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 2: Texto Enriquecido
// ==========================================
class Ejercicio2Screen extends StatelessWidget {
  const Ejercicio2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Texto Enriquecido')),
      body: SafeArea(
        child: Center(
          child: RichText(
            text: TextSpan(
              text: "Tiene Cuenta?",
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: <TextSpan>[
                TextSpan(
                  text: " Registrese?",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 15,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 3: Fila de Iconos
// ==========================================
class Ejercicio3Screen extends StatelessWidget {
  const Ejercicio3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fila de Iconos')),
      body: const SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.ac_unit, color: Colors.redAccent, size: 40.0),
              Icon(Icons.back_hand, color: Colors.greenAccent, size: 60.0),
              Icon(Icons.mail_lock, color: Colors.blueAccent, size: 80.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA 4: Alerta Dialog y Botones con Estilo
// ==========================================
class Ejercicio4Screen extends StatelessWidget {
  const Ejercicio4Screen({super.key});

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Dialog'),
          content: const Text('Mensaje....'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botones y Alerta')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón superior azul tipo OK con sombra
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showAlertDialog(context),
                child: const Text('OK'),
              ),
              const SizedBox(height: 40),

              // Botón central de Búsqueda (como el de tu imagen)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showAlertDialog(context),
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
              const SizedBox(height: 40),

              // Botón inferior verde estilo Login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () => _showAlertDialog(context),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
