import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/insights_library_screen.dart';
import 'screens/report_preview_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/new_investigation_screen.dart';
import 'screens/analysis_progress_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const CureonixApp(),
    ),
  );
}

class CureonixApp extends StatelessWidget {
  const CureonixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cureonix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: false),
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShellScreen(),
        '/new_investigation': (context) => const NewInvestigationScreen(),
        '/analysis_progress': (context) => const AnalysisProgressScreen(),
        '/insights_library': (context) => const InsightsLibraryScreen(),
        '/report_preview': (context) => const ReportPreviewScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
