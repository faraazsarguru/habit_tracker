import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'isDarkMode';
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF00E676),
          secondary: const Color(0xFF69F0AE),
          surface: Colors.white,
          onPrimary: Colors.black,
          onSurface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      );

  ThemeData get darkTheme => ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF69F0AE),
          surface: Color(0xFF121212),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        useMaterial3: true,
      );
}
