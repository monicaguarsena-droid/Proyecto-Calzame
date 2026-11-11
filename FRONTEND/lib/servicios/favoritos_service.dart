import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda en el dispositivo los ids de los productos favoritos.
/// Solo se guardan ids: la pantalla de favoritos vuelve a pedir los
/// productos al backend, así el precio y las fotos siempre están al día.
class FavoritosService {
  static const _clave = 'favoritos_ids';

  /// Ids en orden de agregado (el último es el más reciente).
  static Future<List<String>> obtenerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_clave);
    if (texto == null || texto.isEmpty) return [];
    try {
      final decoded = jsonDecode(texto);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> esFavorito(String id) async {
    return (await obtenerIds()).contains(id);
  }

  /// Agrega el producto si no estaba y lo quita si ya estaba.
  /// Devuelve true si quedó como favorito.
  static Future<bool> alternar(String id) async {
    final ids = await obtenerIds();
    final ahoraEsFavorito = !ids.contains(id);
    if (ahoraEsFavorito) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, jsonEncode(ids));
    return ahoraEsFavorito;
  }
}