import 'package:flutter/material.dart';
import '../../../../config/design_system/app_theme.dart';
import '../cache/cache_manager.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._private();

  static ThemeNotifier get instance => _instance;

  bool _isDarkMode = false;
  bool _isInitialized = false;

  ThemeNotifier._private();

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void initialize() {
    if (!_isInitialized) {
      _isDarkMode = CacheManager.instance.getDarkMode() ?? false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await CacheManager.instance.setDarkMode(isDark);
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    await toggleTheme(isDark);
  }
}
