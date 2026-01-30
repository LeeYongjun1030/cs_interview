import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to Light Mode
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  ThemeController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark =
        prefs.getBool('is_dark_mode') ?? false; // Default false (Light)
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Sync AppColors state
    AppColors.isDarkMode = isDark;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      AppColors.isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      AppColors.isDarkMode = false;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    AppColors.isDarkMode = (mode == ThemeMode.dark);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
  }
}
