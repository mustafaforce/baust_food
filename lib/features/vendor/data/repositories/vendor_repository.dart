import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../menu/data/models/food_item_model.dart';

class VendorRepository {
  final SupabaseClient _client;

  VendorRepository(this._client);

  Future<List<FoodItem>> getVendorFoodItems(String vendorId) async {
    final response = await _client
        .from('food_items')
        .select('*, categories(*)')
        .eq('vendor_id', vendorId)
        .order('name');
    return response.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<List<Order>> getVendorOrders(String vendorId) async {
    // Get vendor's food item IDs
    final foodItems = await _client
        .from('food_items')
        .select('id')
        .eq('vendor_id', vendorId);

    final foodItemIds = (foodItems as List).map((e) => e['id'] as String).toList();

    if (foodItemIds.isEmpty) return [];

    // Get all orders with their items
    final allOrders = await _client
        .from('orders')
        .select('*, order_items(*, food_items(*))')
        .order('created_at', ascending: false);

    // Filter orders that contain vendor's food items
    final vendorOrderIds = <String>{};
    for (final order in (allOrders as List)) {
      final items = order['order_items'] as List? ?? [];
      for (final item in items) {
        if (foodItemIds.contains(item['food_item_id'])) {
          vendorOrderIds.add(order['id'] as String);
          break;
        }
      }
    }

    if (vendorOrderIds.isEmpty) return [];

    return allOrders
        .where((json) => vendorOrderIds.contains(json['id']))
        .map((json) => Order.fromJson(json))
        .toList();
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    final response = await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select()
        .single();
    return Order.fromJson(response);
  }

  Future<FoodItem> addFoodItem({
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
