// Archivo de configuración generado para Firebase
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSOCpjrm-IlijecsDKX55mSNBkK4SnnXg',
    appId: '1:15702634721:android:27d0b79fafdf73648847a0',
    messagingSenderId: '15702634721',
    projectId: 'calzado-marypaz',
    storageBucket: 'calzado-marypaz.firebasestorage.app',
  );
}