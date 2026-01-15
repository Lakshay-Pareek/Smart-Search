import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        MainShell.routeName: (_) => const MainShell(),
        DocumentDetailScreen.routeName: (_) => const DocumentDetailScreen(),
        AdvancedSearchScreen.routeName: (_) => const AdvancedSearchScreen(),
      },
      builder: (context, child) {
        // On web we avoid showing a scary Firebase banner – the app runs in
        // demo/no-auth mode instead.
        if (kIsWeb) {
          return child ?? const SizedBox.shrink();
        }

        // Simple banner if Firebase failed to initialize on native targets.
        if (firebaseReady) return child ?? const SizedBox.shrink();
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Colors.red.shade600,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Firebase not configured. For Android/iOS, verify platform Firebase config files are present.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  final bool firebaseReady;

  const AuthGate({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    // If Firebase isn't ready, show onboarding (user can still use "Continue as guest")
    if (!firebaseReady) {
      return const OnboardingScreen();
    }

    // Check auth state and route accordingly
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return const MainShell();
        }
        return const OnboardingScreen();
      },
    );
  }
}
