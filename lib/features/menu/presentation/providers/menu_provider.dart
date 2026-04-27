import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/models.dart';
import '../../data/repositories/menu_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ref.watch(supabaseClientProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  return repository.getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final foodItemsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  return repository.getFoodItems(categoryId: selectedCategory);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repository = ref.watch(menuRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  return repository.searchFoodItems(query);
});

final foodItemDetailProvider = FutureProvider.family<FoodItem?, String>((ref, id) async {
  final repository = ref.watch(menuRepositoryProvider);
  return repository.getFoodItemById(id);
});