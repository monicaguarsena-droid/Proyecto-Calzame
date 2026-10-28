import 'package:flutter/material.dart';
import 'package:frontend/cors/colores.dart';

Widget imagenCatalogoPlaceholder({
  double? width,
  double? height,
  double iconSize = 30,
}) => Container(
  width: width,
  height: height,
  color: ColoresApp.surfaceVariant,
  alignment: Alignment.center,
  child: Icon(
    Icons.image_not_supported,
    size: iconSize,
    color: ColoresApp.textSecondary,
  ),
);
