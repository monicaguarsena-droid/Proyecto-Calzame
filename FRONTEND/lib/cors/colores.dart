import 'package:flutter/material.dart';
 
/// Paleta de colores de CalzaMe (extraída del diseño en Figma).
/// Los valores son aproximados; ajusta los hex si tienes los exactos.
class ColoresApp {
  ColoresApp._();
 
  // Marca
  static const Color primary = Color(0xFF6B1229); // Vino / burdeos (botones, títulos, links)
  static const Color primaryDark = Color(0xFF55091F); // Estado pressed
  static const Color primaryLight = Color(0xFF8A2A42); // Acentos / íconos activos
 
  // Fondos
  static const Color background = Color(0xFFF9F1EE); // Crema de pantallas
  static const Color surface = Color(0xFFFFFFFF); // Inputs, tarjetas, botón Google
  static const Color surfaceVariant = Color(0xFFF3E7E3); // Chips / fondos suaves
 
  // Texto
  static const Color textPrimary = Color(0xFF2B1B1F); // Texto principal
  static const Color textSecondary = Color(0xFF6E6468); // Subtítulos, hints
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Texto sobre botón vino
  static const Color hint = Color(0xFF9A9094); // Placeholders
 
  // Bordes
  static const Color border = Color(0xFFE6DAD6); // Bordes de inputs
  static const Color outline = primary; // Botón secundario (outlined)
 
  // Estados
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
}