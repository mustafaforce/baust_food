import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
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
      backgroundColor: AppColors.canvas,
      body: foodItemAsync.when(
        data: (foodItem) {
          if (foodItem == null) {
            return const Scaffold(
              body: Center(child: Text('Food item not found')),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onDark,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (foodItem.imageUrl != null)
                        Image.network(foodItem.imageUrl!, fit: BoxFit.cover)
                      else
                        Container(
                          color: AppColors.ink,
                          alignment: Alignment.center,
                          child: const Icon(Icons.fastfood,
                              size: 96, color: AppColors.mute),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.ink.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.xl2,
                        right: AppSpacing.xl2,
                        bottom: AppSpacing.xl2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (foodItem.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pillMd),
                                ),
                                child: Text(
                                  foodItem.category!.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              foodItem.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.onDark,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '৳${foodItem.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _RatingHeader(foodItemId: foodItem.id),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl2),
                      const SectionEyebrow(text: 'About'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        foodItem.description?.isNotEmpty == true
                            ? foodItem.description!
                            : 'No description available.',
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl2),
                      if (!foodItem.isAvailable)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.canvasSoft,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: const Border(
                              left: BorderSide(
                                  color: AppColors.primary, width: 3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: AppColors.primary),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Currently unavailable',
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                  content:
                                      Text('${foodItem.name} added to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    textColor: AppColors.primary,
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
                      const SizedBox(height: AppSpacing.xl2),
                      _ReviewsSection(foodItemId: foodItem.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
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
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_border, color: AppColors.mute, size: 18),
              SizedBox(width: AppSpacing.xs),
              Text(
                'No ratings',
                style: TextStyle(color: AppColors.body, fontSize: 13),
              ),
            ],
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadius.pillMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingStars(rating: summary.avgRating, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${summary.avgRating.toStringAsFixed(1)} (${summary.ratingCount})',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.primary),
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
            SectionEyebrow(text: 'Reviews · ${reviews.length}'),
            const SizedBox(height: AppSpacing.md),
            ...reviews.take(20).map((r) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvasSoft,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RatingStars(rating: r.rating.toDouble(), size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              r.customerName?.isNotEmpty == true
                                  ? r.customerName!
                                  : 'Anonymous',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(r.createdAt),
                            style: const TextStyle(
                              color: AppColors.body,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (r.comment != null && r.comment!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          r.comment!,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
