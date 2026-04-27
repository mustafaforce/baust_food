import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
});

final placeOrderProvider = Provider<Future<Order> Function({
  required double totalAmount,
  required String deliveryAddress,
})>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  final cartItems = ref.watch(cartProvider);

  return ({
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final items = cartItems.map((item) => {
      'food_item_id': item.foodItem.id,
      'quantity': item.quantity,
      'price_at_order': item.foodItem.price,
    }).toList();

    final order = await repository.placeOrder(
      customerId: user.id,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      items: items,
    );

    ref.read(cartProvider.notifier).clearCart();

    return order;
  };
});

final customerOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  return repository.getCustomerOrders(user.id);
});

final orderDetailProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
});
