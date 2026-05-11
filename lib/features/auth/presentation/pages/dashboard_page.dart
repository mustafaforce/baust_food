import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/hero_band.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:baust_food/features/profile/presentation/pages/profile_page.dart';
import 'package:baust_food/features/menu/presentation/pages/menu_page.dart';
import 'package:baust_food/features/cart/presentation/providers/cart_provider.dart';
import 'package:baust_food/features/cart/presentation/pages/cart_page.dart';
import 'package:baust_food/features/vendor/presentation/pages/vendor_dashboard_page.dart';
import 'package:baust_food/features/orders/presentation/pages/order_history_page.dart';

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
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Baust Food'),
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
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.onPrimary,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroBand(
            eyebrow: 'Vendor',
            headline: 'Run\nYour Shop',
            subhead: fullName == null
                ? 'Manage your menu, track orders, deliver fast.'
                : 'Welcome back, $fullName. Manage your menu and orders.',
            trailing: const SpeechmarkOrb(icon: Icons.storefront),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionEyebrow(text: 'Quick Action'),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Open your dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const VendorDashboardPage()),
                    );
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Go to Vendor Dashboard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerBody(
      BuildContext context, String? fullName, String email) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroBand(
            eyebrow: 'Campus Food',
            headline: fullName == null
                ? 'Order\nIn Seconds'
                : 'Hey ${fullName.split(' ').first}',
            subhead: fullName == null
                ? 'Browse vendors, build a cart, eat well.'
                : 'Your campus kitchens are waiting. Browse and order in seconds.',
            trailing: const SpeechmarkOrb(icon: Icons.restaurant_menu_rounded),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionEyebrow(text: 'What\'s next'),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Pick what you\'re hungry for',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MenuPage()),
                    );
                  },
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Browse Menu'),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const OrderHistoryPage()),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('My Orders'),
                ),
                const SizedBox(height: AppSpacing.xl2),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvasSoft,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          color: AppColors.body, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            color: AppColors.body,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
