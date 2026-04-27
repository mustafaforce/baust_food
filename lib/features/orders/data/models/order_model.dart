import '../../../menu/data/models/food_item_model.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final String id;
  final String customerId;
  final OrderStatus status;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddress: json['delivery_address'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'status': status.name,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String foodItemId;
  final int quantity;
  final double priceAtOrder;
  final DateTime createdAt;
  final FoodItem? foodItem;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.foodItemId,
    required this.quantity,
    required this.priceAtOrder,
    required this.createdAt,
    this.foodItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      foodItemId: json['food_item_id'] as String,
      quantity: json['quantity'] as int,
      priceAtOrder: (json['price_at_order'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      foodItem: json['food_items'] != null
          ? FoodItem.fromJson(json['food_items'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'food_item_id': foodItemId,
      'quantity': quantity,
      'price_at_order': priceAtOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
