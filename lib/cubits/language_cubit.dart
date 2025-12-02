import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const String _languageKey = 'selected_language';

  LanguageCubit() : super(const LanguageState()) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'en';
    emit(state.copyWith(locale: Locale(savedLanguage)));
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await _saveLanguage(newLocale.languageCode);
    emit(state.copyWith(locale: newLocale));
  }

  Future<void> setLanguage(String languageCode) async {
    await _saveLanguage(languageCode);
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
