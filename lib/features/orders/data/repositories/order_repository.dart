import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderRepository {
  final SupabaseClient _client;

  OrderRepository(this._client);

  Future<Order> placeOrder({
    required String customerId,
    required double totalAmount,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final orderResponse = await _client.from('orders').insert({
      'customer_id': customerId,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress,
      'status': 'pending',
    }).select().single();

    final orderId = orderResponse['id'] as String;

    final orderItems = items.map((item) => {
      'order_id': orderId,
      'food_item_id': item['food_item_id'],
      'quantity': item['quantity'],
      'price_at_order': item['price_at_order'],
    }).toList();

    await _client.from('order_items').insert(orderItems);

    return Order.fromJson(orderResponse);
  }

  Future<List<Order>> getCustomerOrders(String customerId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  Future<Order?> getOrderById(String orderId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) return null;
    return Order.fromJson(response);
  }
}
