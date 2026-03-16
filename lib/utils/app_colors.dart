import 'package:flutter/material.dart';

class AppColors {


  static const Color primary = Color(0xFF1FA463);
  static const Color primaryDark = Color(0xFF159957);

  static const Color secondary = Color(0xFF27AE60);
  static const Color background = Color(0xFFF4F7F6);


  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;

  static const Color grey = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE5E7EB);

  static Color shadow = Colors.black.withOpacity(0.08);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1FA463),
      Color(0xFF159957),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}