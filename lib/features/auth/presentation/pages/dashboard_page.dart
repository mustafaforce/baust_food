import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baust_food/features/profile/presentation/pages/profile_page.dart';
import 'package:baust_food/features/menu/presentation/pages/menu_page.dart';
import 'package:baust_food/features/cart/presentation/providers/cart_provider.dart';
import 'package:baust_food/features/cart/presentation/pages/cart_page.dart';
import 'package:baust_food/features/vendor/presentation/pages/vendor_dashboard_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _role = 'customer';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _role = profile?['role'] ?? 'customer';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String?;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('BAUST Food'),
        actions: [
          if (_role == 'customer')
            Consumer(
              builder: (context, ref, child) {
                final cartCount = ref.watch(cartItemCountProvider);
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  tooltip: 'Cart',
                );
              },
            ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _role == 'vendor'
          ? _buildVendorBody(context, fullName)
          : _buildCustomerBody(context, fullName, user?.email ?? ''),
    );
  }

  Widget _buildVendorBody(BuildContext context, String? fullName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.storefront, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome${fullName == null ? '' : ', $fullName'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Vendor Dashboard'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VendorDashboardPage()),
                );
              },
              icon: const Icon(Icons.dashboard),
              label: const Text('Go to Vendor Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerBody(BuildContext context, String? fullName, String email) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome${fullName == null ? '' : ', $fullName'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                );
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Menu'),
            ),
          ],
        ),
      ),
    );
  }
}