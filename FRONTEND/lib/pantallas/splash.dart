import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/pantallas/inicio_sesion.dart';
import 'package:video_player/video_player.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/zapato.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController
            ..setLooping(true)
            ..play();
        }
      });
    // Después de 5 segundos pasa a Inicio
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            //video
            if (_videoController.value.isInitialized)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            //nombre calzame
            const Positioned(
              bottom: 190,
              child: Text(
                'CALZAME',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: Color(0xFFE9799B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
