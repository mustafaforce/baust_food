import 'package:baust_food/app/theme/app_theme.dart';
import 'package:baust_food/features/auth/presentation/pages/auth_page.dart';
import 'package:baust_food/features/auth/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaustFoodApp extends StatelessWidget {
  const BaustFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baust Food',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = auth.currentSession;
        if (session == null) {
          return const AuthPage();
        }
        return const DashboardPage();
      },
    );
  }
}
