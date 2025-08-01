import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _lightTheme = AppTheme.lightTheme;
    _darkTheme = AppTheme.darkTheme;
    _loadThemeMode();
  }

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(Constants.themePreference);
    
    if (themeValue == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeValue == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    String themeValue;
    
    switch (mode) {
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      case ThemeMode.light:
        themeValue = 'light';
        break;
      default:
        themeValue = 'system';
    }
    
    await prefs.setString(Constants.themePreference, themeValue);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}