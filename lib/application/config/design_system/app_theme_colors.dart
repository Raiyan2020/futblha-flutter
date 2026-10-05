import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colors that follow the current theme (light/dark), matching how the
/// Settings page builds its cards from [ThemeData.cardColor].
///
/// In light mode every getter returns the color the app used before,
/// so only dark mode changes.
extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Page background (light: #F6FDFB, dark: #121212).
  Color get scaffoldBackground => Theme.of(this).scaffoldBackgroundColor;

  /// Card / container / sheet background (light: white, dark: #1E1E1E).
  /// Replaces `AppColors.primaryWhite` / `Colors.white` used as a surface.
  Color get cardBackground => Theme.of(this).cardColor;

  /// Light-green tinted surface for chips, info rows and sections.
  /// Replaces `AppColors.secondaryColor` used as a background.
  Color get chipBackground => isDarkMode ? const Color(0xFF1C3A2E) : AppColors.secondaryColor;

  /// Neutral filled surface for placeholders, avatars and inactive pills.
  /// Replaces `AppColors.primaryLiteGrey` used as a background.
  Color get mutedBackground => isDarkMode ? const Color(0xFF2C2C2C) : AppColors.primaryLiteGrey;

  /// Card and field borders. Replaces `AppColors.borderGrey`.
  Color get borderColor => isDarkMode ? const Color(0xFF333333) : AppColors.borderGrey;

  /// Main text on a card or page. Replaces `AppColors.primaryBlack` / `Colors.black` as text.
  Color get textPrimary => isDarkMode ? AppColors.primaryWhite : AppColors.primaryBlack;

  /// Secondary text. Replaces `AppColors.primaryDark` as text.
  Color get textSecondary => isDarkMode ? const Color(0xFFC7C7C7) : AppColors.primaryDark;

  /// Brand green for text and icons drawn on a card or page background.
  /// The dark green [AppColors.primaryColor] is unreadable on #1E1E1E, so
  /// dark mode uses a lighter green. Do not use for button/badge fills.
  Color get brandOnSurface => isDarkMode ? const Color(0xFF5FC79B) : AppColors.primaryColor;
}
