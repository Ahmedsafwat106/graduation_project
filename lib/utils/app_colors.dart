import 'package:flutter/material.dart';

class AppColors {


  static const Color primary = Color(0xFF1B4D54);
  static const Color primaryDark = Color(0xFF153F45);

  static const Color secondary = Color(0xFFC19A6B);
  static const Color background = Color(0xFFF4F7F6);


  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;

  static const Color grey = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE5E7EB);

  static Color shadow = Colors.black.withOpacity(0.08);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1B4D54),
      Color(0xFF153F45),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}