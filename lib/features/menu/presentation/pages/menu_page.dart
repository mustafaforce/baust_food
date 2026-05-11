import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/empty_state.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/food_item_card.dart';
import 'food_detail_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../orders/presentation/pages/order_history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMenuBody(),
          const CartPage(),
          const OrderHistoryPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(cartItemCountProvider);
                return Badge(
                  isLabelVisible: count > 0,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.onPrimary,
                  label: Text('$count'),
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBody() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final foodItemsAsync = ref.watch(foodItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FoodSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.ink,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl2,
              AppSpacing.lg,
              AppSpacing.xl2,
              AppSpacing.xl,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionEyebrow(text: 'Order', color: AppColors.primary),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'WHAT\'S\nCOOKING',
                  style: TextStyle(
                    color: AppColors.onDark,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          categoriesAsync.when(
            data: (categories) => CategoryChips(
              categories: categories,
              selectedCategoryId: selectedCategory,
              onCategorySelected: (categoryId) {
                ref.read(selectedCategoryProvider.notifier).state = categoryId;
              },
            ),
            loading: () => const SizedBox(
              height: 52,
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (error, stack) => SizedBox(
              height: 52,
              child: Center(child: Text('Error: $error')),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: foodItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.fastfood,
                    title: 'Nothing here yet',
                    message:
                        'No food items available right now. Check back soon.',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl2,
                    AppSpacing.sm,
                    AppSpacing.xl2,
                    AppSpacing.xl2,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return FoodItemCard(
                      foodItem: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FoodDetailPage(foodItemId: item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  FoodSearchDelegate(this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onDark,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.mute),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: AppColors.onDark, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppColors.onDark),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.onDark),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search the menu',
        message: 'Type a food name to find what you\'re craving.',
      );
    }

    ref.read(searchQueryProvider.notifier).state = query;
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No results',
            message: 'Nothing matches "$query".',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.canvasSoft),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!,
                          width: 56, height: 56, fit: BoxFit.cover)
                      : Container(
                          width: 56,
                          height: 56,
                          color: AppColors.canvasSoft,
                          child: const Icon(Icons.fastfood,
                              color: AppColors.mute),
                        ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.category?.name ?? "Uncategorized"} · ৳${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.body),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.mute),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodDetailPage(foodItemId: item.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
