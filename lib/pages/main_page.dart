import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants.dart';
import '../cubits/language_cubit.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../widgets/note_icon_button_outlined.dart';
import 'notes_page.dart';
import 'todos_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    NotesPage(),
    TodosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? l10n.appTitle : l10n.todos),
        actions: _currentIndex == 0
            ? [
                // Test notification button (for debugging) - Only in Notes page
                
                NoteIconButtonOutlined(
                  icon: FontAwesomeIcons.language,
                  onPressed: () {
                    context.read<LanguageCubit>().toggleLanguage();
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.noteSticky),
            label: l10n.notes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.listCheck),
            label: l10n.todos,
          ),
        ],
      ),
    );
  }
}
