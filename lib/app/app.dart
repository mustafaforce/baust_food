import 'package:baust_food/app/theme/app_theme.dart';
import 'package:baust_food/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';

class BaustFoodApp extends StatelessWidget {
  const BaustFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food',
      theme: AppTheme.lightTheme,
      home: const AuthPage(),
    );
  }
}