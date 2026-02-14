import 'package:flutter/material.dart';

class AppColors {
  // مستخرجة بصريًا من شعار مساري (أزرق/تركوازي مع لمسة برتقالية)
  static const Color primary = Color(0xFF2E97C8);
  static const Color secondary = Color(0xFF55C2B9);
  static const Color accent = Color(0xFFF4A84A);
  static const Color deepTeal = Color(0xFF0E5B73);
  static const Color background = Color(0xFF0C1216);
  static const Color surface = Color(0xFF141C22);
  static const Color textPrimary = Color(0xFFE8F4F7);
  static const Color textSecondary = Color(0xFFB4C7CF);

  // أسماء قديمة للتوافق
  static const Color primaryBlue = primary;
  static const Color secondaryTeal = secondary;
  static const Color accentOrange = accent;
  static const Color darkText = deepTeal;
  static const Color lightBackground = Color(0xFFF7FBFD);

  // اتجاه التدرج في الشعار
  static const Alignment gradientStart = Alignment.centerLeft;
  static const Alignment gradientEnd = Alignment.centerRight;
}
