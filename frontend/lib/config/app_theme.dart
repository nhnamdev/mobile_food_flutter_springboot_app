import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFFFE724C);
  static const Color accentColor = Color(0xFFF8B64C);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111719);
  static const Color textSecondary = Color(0xFF5B5B5E);
  static const Color subColor = Color(0xFF9796A1);
  static const Color textGrey = Color(0xFF67666D);
  
  // Background Colors
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF2F2F2);
  static const Color inputBorder = Color(0xFFEEEEEE);
  
  // Other Colors
  static const Color error = Color(0xFFFF0404);
  static const Color success = Color(0xFF4CAF50);
  static const Color star = Color(0xFFFFD700);
  static const Color info = Color(0xFF2196F3);
  static const Color divider = Color(0xFFE0E0E0);
}

class AppTextStyles {
  static const String fontFamily = 'Roboto';
  
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: AppColors.white,
  );
  
  // Label Text
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.subColor,
  );
  
  // Caption Text
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.subColor,
  );
}

class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.primaryColor.withOpacity(0.25),
      blurRadius: 30,
      offset: const Offset(0, 20),
    ),
  ];
  
  static List<BoxShadow> inputShadow = [
    BoxShadow(
      color: const Color(0xFFD3D1D8).withOpacity(0.25),
      blurRadius: 30,
      offset: const Offset(15, 15),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.label,
      ),
    );
  }
}
