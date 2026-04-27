import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class MenuRepository {
  final SupabaseClient _client;

  MenuRepository(this._client);

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name');
    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<List<FoodItem>> getFoodItems({String? categoryId}) async {
    List<dynamic> response;
    if (categoryId != null) {
      response = await _client
          .from('food_items')
          .select('*, categories(*)')
          .eq('is_available', true)
          .eq('category_id', categoryId)
          .order('name');
    } else {
      response = await _client
          .from('food_items')
          .select('*, categories(*)')
          .eq('is_available', true)
          .order('name');
    }
    return response.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<List<FoodItem>> getFoodItemsByVendor(String vendorId) async {
    final response = await _client
        .from('food_items')
        .select('*, categories(*)')
        .eq('vendor_id', vendorId)
        .order('name');
    return response.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    final response = await _client
        .from('food_items')
        .select('*, categories(*)')
        .eq('id', id)
        .single();
    return FoodItem.fromJson(response);
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final response = await _client
        .from('food_items')
        .select('*, categories(*)')
        .eq('is_available', true)
        .ilike('name', '%$query%')
        .order('name');
    return response.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<Category> createCategory({
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    final response = await _client.from('categories').insert({
      'name': name,
      'description': description,
      'image_url': imageUrl,
    }).select().single();
    return Category.fromJson(response);
  }

  Future<FoodItem> createFoodItem({
    required String vendorId,
    required String name,
    required double price,
    String? categoryId,
    String? description,
    String? imageUrl,
  }) async {
    final response = await _client.from('food_items').insert({
      'vendor_id': vendorId,
      'name': name,
      'price': price,
      'category_id': categoryId,
      'description': description,
      'image_url': imageUrl,
    }).select('*, categories(*)').single();
    return FoodItem.fromJson(response);
  }

  Future<FoodItem> updateFoodItem(FoodItem item) async {
    final response = await _client
        .from('food_items')
        .update({
          'name': item.name,
          'category_id': item.categoryId,
          'description': item.description,
          'price': item.price,
          'image_url': item.imageUrl,
          'is_available': item.isAvailable,
        })
        .eq('id', item.id)
        .select('*, categories(*)')
        .single();
    return FoodItem.fromJson(response);
  }

  Future<void> deleteFoodItem(String id) async {
    await _client.from('food_items').delete().eq('id', id);
  }

  Future<void> toggleFoodItemAvailability(String id, bool isAvailable) async {
    await _client
        .from('food_items')
        .update({'is_available': isAvailable})
        .eq('id', id);
  }
}