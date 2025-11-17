import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState());

  void toggleLanguage() {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    emit(state.copyWith(locale: newLocale));
  }

  void setLanguage(String languageCode) {
    emit(state.copyWith(locale: Locale(languageCode)));
  }
}
