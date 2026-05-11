class Review {
  final String id;
  final String orderId;
  final String foodItemId;
  final String customerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customerName;

  Review({
    required this.id,
    required this.orderId,
    required this.foodItemId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      foodItemId: json['food_item_id'] as String,
      customerId: json['customer_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customerName: json['customer_name'] as String?,
    );
  }
}

class RatingSummary {
  final String foodItemId;
  final double avgRating;
  final int ratingCount;

  RatingSummary({
    required this.foodItemId,
    required this.avgRating,
    required this.ratingCount,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      foodItemId: json['food_item_id'] as String,
      avgRating: (json['avg_rating'] as num).toDouble(),
      ratingCount: (json['rating_count'] as num).toInt(),
    );
  }

  static RatingSummary empty(String foodItemId) =>
      RatingSummary(foodItemId: foodItemId, avgRating: 0, ratingCount: 0);
}
