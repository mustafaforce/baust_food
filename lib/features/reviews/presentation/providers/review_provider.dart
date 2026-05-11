import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

final _reviewSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(_reviewSupabaseClientProvider));
});

final foodReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, foodItemId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForFood(foodItemId);
});

final ratingSummaryProvider =
    FutureProvider.family<RatingSummary, String>((ref, foodItemId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getRatingSummary(foodItemId);
});

class OrderItemReviewKey {
  final String orderId;
  final String foodItemId;
  const OrderItemReviewKey(this.orderId, this.foodItemId);

  @override
  bool operator ==(Object other) =>
      other is OrderItemReviewKey &&
      other.orderId == orderId &&
      other.foodItemId == foodItemId;

  @override
  int get hashCode => Object.hash(orderId, foodItemId);
}

final customerOrderItemReviewProvider =
    FutureProvider.family<Review?, OrderItemReviewKey>((ref, key) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getCustomerReviewForOrderItem(
    orderId: key.orderId,
    foodItemId: key.foodItemId,
  );
});
