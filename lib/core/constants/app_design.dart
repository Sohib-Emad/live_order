// lib/core/constants/app_design.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDesign {
  // Colors
  static const Color primary = Color(0xFFFF6B00);
  static const Color surface = Color(0xFFF7F8FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color border = Color(0xFFE5E7EB);

  // Spacing
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;

  // Radii
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius24 = 24.0;

  // Typography
  static TextStyle heading({
    double fontSize = 20.0,
    Color color = textPrimary,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle body({
    double fontSize = 14.0,
    Color color = textSecondary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
