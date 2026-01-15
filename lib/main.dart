import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Initialize sqflite ffi for desktop/test environments BEFORE any database usage.
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'firebase/firebase_initializer.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/search/advanced_search_screen.dart';
import 'ui/screens/search/document_detail_screen.dart';
import 'ui/screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On non-web platforms (desktop / tests) initialize the ffi implementation
  // so the sqflite global APIs (openDatabase, getDatabasesPath, etc.) work.
  if (!kIsWeb) {
    try {
      sqfliteFfiInit();
      // set global databaseFactory to ffi implementation
      sqflite.databaseFactory = databaseFactoryFfi;
      debugPrint('sqflite ffi initialized');
    } catch (e, st) {
      // If the ffi package is not available or initialization fails we'll log
      // the issue and continue — LocalStorageService has fallbacks for web.
      debugPrint('sqflite ffi init failed: $e\n$st');
    }
  }

  final firebaseReady = await initializeFirebase();
  runApp(SmartDocumentSearchApp(firebaseReady: firebaseReady));
}

class SmartDocumentSearchApp extends StatelessWidget {
  final bool firebaseReady;

  const SmartDocumentSearchApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Document Search',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthGate(firebaseReady: firebaseReady),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        AdvancedSearchScreen.routeName: (_) => const AdvancedSearchScreen(),
        DocumentDetailScreen.routeName: (_) => const DocumentDetailScreen(),
        MainShell.routeName: (_) => const MainShell(),
      },
    );
  }
}
