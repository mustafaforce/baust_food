import 'package:baust_food/app/theme/app_theme.dart';
import 'package:baust_food/features/auth/presentation/pages/auth_page.dart';
import 'package:baust_food/features/auth/presentation/pages/dashboard_page.dart';
import 'package:baust_food/features/cart/presentation/pages/cart_page.dart';
import 'package:baust_food/features/orders/presentation/pages/checkout_page.dart';
import 'package:baust_food/features/orders/presentation/pages/order_history_page.dart';
import 'package:baust_food/features/vendor/presentation/pages/vendor_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaustFoodApp extends StatelessWidget {
  const BaustFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/orders': (context) => const OrderHistoryPage(),
        '/vendor': (context) => const VendorDashboardPage(),
      },
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
