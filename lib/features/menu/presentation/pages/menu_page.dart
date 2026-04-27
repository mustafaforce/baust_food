import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/food_item_card.dart';
import 'food_detail_page.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final foodItemsAsync = ref.watch(foodItemsProvider);

    return Scaffold(
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
        children: [
          categoriesAsync.when(
            data: (categories) => CategoryChips(
              categories: categories,
              selectedCategoryId: selectedCategory,
              onCategorySelected: (categoryId) {
                ref.read(selectedCategoryProvider.notifier).state = categoryId;
              },
            ),
            loading: () => const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SizedBox(
              height: 50,
              child: Center(child: Text('Error: $error')),
            ),
          ),
          Expanded(
            child: foodItemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No food items available'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
                            builder: (_) => FoodDetailPage(foodItemId: item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
      return const Center(child: Text('Enter a search term'));
    }

    ref.read(searchQueryProvider.notifier).state = query;
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('No results for "$query"'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: item.imageUrl != null
                  ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood),
              title: Text(item.name),
              subtitle: Text('${item.category?.name ?? "Uncategorized"} - \$${item.price.toStringAsFixed(2)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodDetailPage(foodItemId: item.id),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}