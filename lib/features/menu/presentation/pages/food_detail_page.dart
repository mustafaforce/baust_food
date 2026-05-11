import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../../reviews/presentation/widgets/rating_stars.dart';

class FoodDetailPage extends ConsumerWidget {
  final String foodItemId;

  const FoodDetailPage({super.key, required this.foodItemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodItemAsync = ref.watch(foodItemDetailProvider(foodItemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
      ),
      body: foodItemAsync.when(
        data: (foodItem) {
          if (foodItem == null) {
            return const Center(child: Text('Food item not found'));
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (foodItem.imageUrl != null)
                  Image.network(
                    foodItem.imageUrl!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fastfood,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              foodItem.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          Text(
                            '\$${foodItem.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (foodItem.category != null)
                        Chip(
                          label: Text(foodItem.category!.name),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      const SizedBox(height: 12),
                      _RatingHeader(foodItemId: foodItem.id),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        foodItem.description ?? 'No description available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      if (!foodItem.isAvailable)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Currently unavailable',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      if (foodItem.isAvailable)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(foodItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${foodItem.name} added to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/cart');
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _ReviewsSection(foodItemId: foodItem.id),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RatingHeader extends ConsumerWidget {
  final String foodItemId;
  const _RatingHeader({required this.foodItemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(ratingSummaryProvider(foodItemId));
    return summaryAsync.when(
      data: (summary) {
        if (summary.ratingCount == 0) {
          return Row(
            children: [
              const Icon(Icons.star_border, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                'No ratings yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          );
        }
        return Row(
          children: [
            RatingStars(rating: summary.avgRating, size: 20),
            const SizedBox(width: 8),
            Text(
              '${summary.avgRating.toStringAsFixed(1)} (${summary.ratingCount})',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  final String foodItemId;
  const _ReviewsSection({required this.foodItemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(foodReviewsProvider(foodItemId));
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews (${reviews.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...reviews.take(20).map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RatingStars(rating: r.rating.toDouble(), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.customerName?.isNotEmpty == true
                                    ? r.customerName!
                                    : 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(r.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (r.comment != null && r.comment!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(r.comment!),
                        ],
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
