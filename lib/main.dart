import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/src/l10n/generated/quill_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants.dart';
import 'cubits/language_cubit.dart';
import 'cubits/language_state.dart';
import 'cubits/notes_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/theme_state.dart';
import 'cubits/todos_cubit.dart';
import 'l10n/app_localizations.dart';
import 'models/note.dart';
import 'models/todo.dart';
import 'pages/main_page.dart';
import 'repositories/notes_repository.dart';
import 'repositories/todos_repository.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  print('🔔 ========== APP STARTING ==========');

  // Initialize Hive
  await Hive.initFlutter();
  print('🔔 Hive initialized');

  // Register Hive Adapters
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TodoAdapter());
  print('🔔 Hive adapters registered');

  // Initialize repositories
  final notesRepository = HiveNotesRepository();
  await notesRepository.init();
  print('🔔 Notes repository initialized');

  final todosRepository = HiveTodosRepository();
  await todosRepository.init();
  print('🔔 Todos repository initialized');

  // Initialize notification service
  print('🔔 Initializing notification service...');
  await NotificationService().initialize();
  print('🔔 Notification service initialized');

  // Test notification immediately on app start
  print('🔔 Testing immediate notification...');
  try {
    await NotificationService().showImmediateNotification(
      title: 'تطبيق بدأ!',
      body: 'التطبيق بدأ بنجاح - الإشعارات تعمل! 🎉',
    );
    print('🔔 ✅ Test notification sent successfully');
  } catch (e) {
    print('🔔 ❌ Test notification failed: $e');
  }

  runApp(MyApp(
    notesRepository: notesRepository,
    todosRepository: todosRepository,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.notesRepository,
    required this.todosRepository,
    super.key,
  });

  final NotesRepository notesRepository;
  final TodosRepository todosRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotesCubit(notesRepository)),
        BlocProvider(create: (context) => TodosCubit(todosRepository)),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Notes',
                locale: languageState.locale,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  ...FlutterQuillLocalizations.localizationsDelegates,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                themeMode: themeState.themeMode,
                theme: ThemeData(
                  brightness: Brightness.light,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: primary,
                    brightness: Brightness.light,
                  ),
                  useMaterial3: true,
                  fontFamily: 'Poppins',
                  scaffoldBackgroundColor: background,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: background,
                    titleTextStyle: TextStyle(
                      color: primary,
                      fontSize: 32,
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w600,
                    ),
                    iconTheme: IconThemeData(color: black),
                  ),
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: primary,
                    brightness: Brightness.dark,
                  ),
                  useMaterial3: true,
                  fontFamily: 'Poppins',
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFF121212),
                    titleTextStyle: TextStyle(
                      color: primary,
                      fontSize: 32,
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w600,
                    ),
                    iconTheme: IconThemeData(color: white),
                  ),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Color(0xFF1E1E1E),
                    selectedItemColor: primary,
                    unselectedItemColor: Colors.grey,
                  ),
                ),
                home: const MainPage(),
              );
            },
          );
        },
      ),
    );
  }
}
