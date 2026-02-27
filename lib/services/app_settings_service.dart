import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends ChangeNotifier {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';

  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    final themeValue = prefs.getString(_themeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    if (themeValue != null) {
      _themeMode = _themeModeFromString(themeValue);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
