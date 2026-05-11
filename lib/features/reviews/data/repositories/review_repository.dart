import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _client;

  ReviewRepository(this._client);

  Future<Review> submitReview({
    required String orderId,
    required String foodItemId,
    required int rating,
    String? comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client.from('reviews').insert({
      'order_id': orderId,
      'food_item_id': foodItemId,
      'customer_id': user.id,
      'rating': rating,
      'comment': comment,
    }).select().single();

    return Review.fromJson(response);
  }

  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final response = await _client
        .from('reviews')
        .update({'rating': rating, 'comment': comment})
        .eq('id', reviewId)
        .select()
        .single();
    return Review.fromJson(response);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }

  Future<List<Review>> getReviewsForFood(String foodItemId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('food_item_id', foodItemId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Review?> getCustomerReviewForOrderItem({
    required String orderId,
    required String foodItemId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final response = await _client
        .from('reviews')
        .select()
        .eq('order_id', orderId)
        .eq('food_item_id', foodItemId)
        .eq('customer_id', user.id)
        .maybeSingle();
    if (response == null) return null;
    return Review.fromJson(response);
  }

  Future<RatingSummary> getRatingSummary(String foodItemId) async {
    final response = await _client
        .from('food_item_ratings')
        .select()
        .eq('food_item_id', foodItemId)
        .maybeSingle();
    if (response == null) return RatingSummary.empty(foodItemId);
    return RatingSummary.fromJson(response);
  }
}
