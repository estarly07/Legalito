import 'package:flutter/material.dart';

// Define your color palette
class AppColors {
  static const Color primaryBlue = Color(0xFF377DFF); // Azul primario
  static const Color darkBlue = Color(0xFF2B4C7E); // Azul oscuro
  static const Color lightGray = Color(0xFFF2F4F8); // Gris claro
  static const Color mediumGray = Color(0xFFB0B8C5); // Gris medio
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Blanco de fondo
  static const Color textPrimary = Color(0xFF263238); // Texto oscuro
}

// Define your app theme
final ThemeData appTheme = ThemeData.light().copyWith(
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.lightGray, // Text color on primary color
    onSecondary: AppColors.textPrimary, // Text color on secondary color
    onSurface: AppColors.textPrimary, // Text color on surface color
    onBackground: AppColors.textPrimary, // Text color on background color
    onError: AppColors.lightGray, // Text color on error color (if defined)
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.backgroundWhite,
  textTheme: ThemeData.light().textTheme.copyWith(
    // Customize the light text theme
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    // Define other text styles as needed
  ),
  buttonTheme: const ButtonThemeData(
    // You can customize button themes here
  ),
  // You can define other theme properties here (font, etc.)
);
