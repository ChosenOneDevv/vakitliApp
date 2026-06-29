import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF0D3B13);
  static const Color lightGreen = Color(0xFF2E7D32);
  static const Color gold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFE8D48B);
  static const Color navy = Color(0xFF1A237E);
  static const Color cream = Color(0xFFFFF8E1);
  static const Color darkCream = Color(0xFFF5E6C8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1C1C1C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBg = Color(0xFFFFFDF5);
  static const Color scaffoldBg = Color(0xFFFAF6ED);

  // Koyu tema yüzeyleri
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkOnSurface = Color(0xFFE8E8E8);
}

class AppTheme {
  /// Tüm metin stilleri — verilen ana metin rengiyle (light/dark).
  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        color: AppColors.lightText,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
    );
  }

  static const _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: AppColors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: 'Amiri',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
      letterSpacing: 0.5,
    ),
  );

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  );

  static const _fabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.gold,
    foregroundColor: AppColors.darkText,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.gold,
        tertiary: AppColors.navy,
        surface: AppColors.cream,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      appBarTheme: _appBarTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.darkText.withValues(alpha: 0.07)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.lightText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),
      textTheme: _textTheme(AppColors.darkText),
      elevatedButtonTheme: _elevatedButtonTheme,
      floatingActionButtonTheme: _fabTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkCream,
        thickness: 1,
      ),
    );
  }

  /// Material You — cihaz duvar kağıdından gelen dinamik renk şeması.
  static ThemeData dynamicTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.darkText;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.5 : 0.4),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),
      textTheme: _textTheme(textColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.lightGreen,
        secondary: AppColors.gold,
        tertiary: AppColors.lightGold,
        surface: AppColors.darkSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: _appBarTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.white.withValues(alpha: 0.06)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.lightGreen,
        unselectedItemColor: AppColors.lightText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),
      textTheme: _textTheme(AppColors.darkOnSurface),
      elevatedButtonTheme: _elevatedButtonTheme,
      floatingActionButtonTheme: _fabTheme,
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
      ),
    );
  }
}
