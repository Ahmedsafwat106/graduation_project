import 'package:flutter/material.dart';

class AppColors {

  /// 🎯 Brand Green (من Developer Dashboard)
  static const Color primary = Color(0xFF1FA463); // الأخضر الأساسي
  static const Color primaryDark = Color(0xFF159957); // الأخضر الداكن للـ gradient و الـ buttons

  /// 🌿 Secondary (متناسق مع البراند بدل 66BB6A)
  static const Color secondary = Color(0xFF27AE60);

  /// 🧼 Background (نفس روح F4F7F6 بتاعة الداشبورد)
  static const Color background = Color(0xFFF4F7F6);

  /// 📝 Text Colors
  static const Color textDark = Color(0xFF1E1E1E); // أشيك من black87 في UI الحديثة
  static const Color textLight = Colors.white;

  /// 🎨 UI Helper Colors
  static const Color grey = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE5E7EB);

  /// 🌫 Shadow (مخففة تناسب الـ modern UI)
  static Color shadow = Colors.black.withOpacity(0.08);

  /// ✨ Gradient موحد للهيدر والأزرار الكبيرة
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF1FA463),
      Color(0xFF159957),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}