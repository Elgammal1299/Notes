import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'selected_theme_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey);

    if (savedThemeIndex != null) {
      final themeMode = ThemeMode.values[savedThemeIndex];
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  Future<void> toggleTheme() async {
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme(newThemeMode);
    emit(state.copyWith(themeMode: newThemeMode));
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    await _saveTheme(themeMode);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }
}
