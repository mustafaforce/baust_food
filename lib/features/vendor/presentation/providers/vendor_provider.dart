import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../menu/data/models/food_item_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(ref.watch(supabaseClientProvider));
});

final vendorOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(vendorRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return repository.getVendorOrders(user.id);
});

final vendorFoodItemsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repository = ref.watch(vendorRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return repository.getVendorFoodItems(user.id);
});

final updateOrderStatusProvider = Provider<Future<void> Function(String, String)>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return (String orderId, String status) async {
    await repository.updateOrderStatus(orderId, status);
    ref.invalidate(vendorOrdersProvider);
  };
});

final addFoodItemProvider = Provider<Future<FoodItem> Function({
  required String name,
  required double price,
  String? categoryId,
  String? description,
  String? imageUrl,
})>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  return ({
    required String name,
    required double price,
    String? categoryId,
    String? description,
    String? imageUrl,
  }) async {
    final item = await repository.addFoodItem(
      vendorId: user.id,
      name: name,
      price: price,
      categoryId: categoryId,
      description: description,
      imageUrl: imageUrl,
    );
    ref.invalidate(vendorFoodItemsProvider);
    return item;
  };
});

final updateFoodItemProvider = Provider<Future<FoodItem> Function(FoodItem)>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return (FoodItem item) async {
    final updated = await repository.updateFoodItem(item);
    ref.invalidate(vendorFoodItemsProvider);
    return updated;
  };
});

final deleteFoodItemProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return (String id) async {
    await repository.deleteFoodItem(id);
    ref.invalidate(vendorFoodItemsProvider);
  };
});

final toggleFoodItemAvailabilityProvider = Provider<Future<void> Function(String, bool)>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return (String id, bool isAvailable) async {
    await repository.toggleFoodItemAvailability(id, isAvailable);
    ref.invalidate(vendorFoodItemsProvider);
  };
});
