// =============================================================================
// APP ENTRY POINT (with all providers)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_game/app_router.dart';
import 'package:flutter_game/services/save_service.dart';
import 'package:flutter_game/services/save_provider.dart';
import 'package:flutter_game/services/analytics_service.dart';
import 'package:flutter_game/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase — replace with your actual credentials
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co',
    anonKey: 'your-anon-key-here',
  );

  // Initialize local save service
  final saveService = SaveService();
  await saveService.init();

  // Track session start
  AnalyticsService.instance.sessionStart();

  // Request notification permissions
  await NotificationService.instance.requestPermission();

  runApp(
    ProviderScope(
      overrides: [
        saveServiceProvider.overrideWithValue(saveService),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match Three',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFF0C040),
          secondary: const Color(0xFF2ECC71),
          surface: const Color(0xFF16213E),
        ),
        useMaterial3: false,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}