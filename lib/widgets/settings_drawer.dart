import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';
import '../cubits/language_cubit.dart';
import '../cubits/language_state.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/theme_state.dart';
import '../l10n/app_localizations.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  FontAwesomeIcons.noteSticky,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.settings,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isDark = state.themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: Text(l10n.theme),
                subtitle: Text(isDark ? l10n.darkMode : l10n.lightMode),
                secondary: Icon(
                  isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                  color: Theme.of(context).iconTheme.color,
                ),
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const Divider(),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              final isArabic = state.locale.languageCode == 'ar';
              return SwitchListTile(
                title: Text(l10n.language),
                subtitle: Text(isArabic ? 'العربية' : 'English'),
                secondary: const Icon(FontAwesomeIcons.language),
                value: isArabic,
                onChanged: (value) {
                  context.read<LanguageCubit>().toggleLanguage();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
