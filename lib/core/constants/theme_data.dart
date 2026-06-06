import 'package:flutter/material.dart';
import 'package:go_transitions/go_transitions.dart';
import 'package:live_order/core/constants/app_design.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: GoTransitions.slide.toTop.withFade,
        TargetPlatform.iOS: GoTransitions.slide.toTop.withFade,
        TargetPlatform.macOS: GoTransitions.slide.toTop.withFade,
      },
    ),
    primaryColor: AppDesign.primary,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    fontFamily: AppDesign.fontFamily,
    textTheme: TextTheme(
      titleLarge: AppDesign.heading(fontSize: 30),
      titleMedium: AppDesign.body(fontSize: 16),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppDesign.primary,
      disabledColor: Color(0xff8391A1),
    ),
  );
}
