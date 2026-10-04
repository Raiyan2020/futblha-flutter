import 'package:flutter/material.dart';
import '../../core/utils/constants/app_constants.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final lightTheme = ThemeData(
    fontFamily: FontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primaryBlack),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: .bold,
        color: AppColors.primaryBlack,
        fontFamily: FontFamily,
      ),
    ),
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: AppColors.primaryWhite,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all<Size>(const Size(0, 48)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primaryGrey; // Disabled background color
          }
          return AppColors.primaryColor; // Enabled background color
        }),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: FontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryWhite,
      ),
      displaySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryBlack,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlack,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryBlack,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryBlack,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: AppColors.primaryWhite,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: AppColors.primaryGrey,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      filled: true,
      fillColor: AppColors.primaryWhite,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.primaryWhite,
      elevation: 24,
      shadowColor: AppColors.primaryBlack.withValues(alpha: 0.25),
      surfaceTintColor: AppColors.primaryColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: FontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlack,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: FontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryDark,
        height: 1.45,
      ),
      alignment: Alignment.center,
      iconColor: AppColors.primaryColor,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    ),
  );

  static final darkTheme = ThemeData(
    fontFamily: FontFamily,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      iconTheme: const IconThemeData(color: AppColors.primaryWhite),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: .bold,
        fontFamily: FontFamily,
        color: AppColors.primaryWhite,
      ),
    ),
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all<Size>(const Size(0, 48)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.primaryGrey; // Disabled background color
          }
          return AppColors.primaryColor; // Enabled background color
        }),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: FontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryWhite,
      ),
      displaySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryWhite,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryWhite,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryWhite,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryWhite,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: AppColors.primaryWhite,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: AppColors.primaryGrey,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
      ),
      filled: true,
      fillColor: AppColors.primaryDark,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 24,
      shadowColor: AppColors.primaryBlack,
      surfaceTintColor: AppColors.primaryColor.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: FontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryWhite,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: FontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryLiteGrey,
        height: 1.45,
      ),
      alignment: Alignment.center,
      iconColor: AppColors.primaryColor,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
    ),
  );
}
