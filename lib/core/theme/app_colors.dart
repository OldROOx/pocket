import 'package:flutter/material.dart';

/// Paleta inspirada en la imagen de referencia (estilo Duolingo).
class AppColors {
  AppColors._();

  // Primarios (naranja de la imagen)
  static const orange = Color(0xFFFF9600);
  static const orangeDark = Color(0xFFE08300); // borde inferior 3D
  static const orangeDeep = Color(0xFFCC7A00);
  static const orangeSoft = Color(0xFFFFF4E3);

  // Acentos
  static const blue = Color(0xFF1CB0F6);
  static const blueDark = Color(0xFF1899D6);
  static const green = Color(0xFF58CC02);
  static const greenDark = Color(0xFF46A302);
  static const red = Color(0xFFFF4B4B);
  static const redDark = Color(0xFFD63A3A);
  static const yellow = Color(0xFFFFC800);
  static const purple = Color(0xFFCE82FF);
  static const purpleDark = Color(0xFFA568CC);

  // Neutros - tema claro
  static const bgLight = Color(0xFFFFF9F2);
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE5E5E5);
  static const textDark = Color(0xFF3C3C3C);
  static const textGrey = Color(0xFF777777);

  // Neutros - tema oscuro
  static const bgDark = Color(0xFF131F24);
  static const cardDark = Color(0xFF1B2A32);
  static const borderDark = Color(0xFF37464F);
  static const textLight = Color(0xFFF1F7FB);
  static const textGreyDark = Color(0xFF9DB2BD);
}
