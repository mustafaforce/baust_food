import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/empty_state.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
import 'package:baust_food/app/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../../data/models/order_model.dart';
import '../../../reviews/presentation/pages/rate_food_page.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../../reviews/presentation/widgets/rating_stars.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message:
                  'When you place an order, it will show up here.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(customerOrdersProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: orders.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error',
                  style: const TextStyle(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => ref.refresh(customerOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailPage(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.canvasSoft),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  StatusChip.fromOrderStatus(order.status.name),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.canvasSoft, height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items?.length ?? 0} item${(order.items?.length ?? 0) == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.body,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '৳${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} · $hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBlock(order),
                const SizedBox(height: AppSpacing.xl2),
                const SectionEyebrow(text: 'Delivery Address'),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.canvasSoft,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          order.deliveryAddress,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl2),
                const SectionEyebrow(text: 'Items'),
                const SizedBox(height: AppSpacing.sm),
                _buildOrderItemsList(order),
                const SizedBox(height: AppSpacing.xl2),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: AppColors.mute,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '৳${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.onDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatusBlock(Order order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionEyebrow(text: 'Status'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.status.displayName.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              StatusChip.fromOrderStatus(order.status.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList(Order order) {
    final isDelivered = order.status == OrderStatus.delivered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: order.items!
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border: Border.all(color: AppColors.canvasSoft),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _OrderItemTile(
                    order: order,
                    item: item,
                    isDelivered: isDelivered,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _OrderItemTile extends ConsumerWidget {
  final Order order;
  final OrderItem item;
  final bool isDelivered;

  const _OrderItemTile({
    required this.order,
    required this.item,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodName = item.foodItem?.name ?? 'Item';
    final reviewKey = OrderItemReviewKey(order.id, item.foodItemId);
    final reviewAsync = isDelivered
        ? ref.watch(customerOrderItemReviewProvider(reviewKey))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$foodName × ${item.quantity}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '৳${(item.priceAtOrder * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (isDelivered && reviewAsync != null)
          reviewAsync.when(
            data: (review) {
              if (review == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Rate this item'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onPressed: () =>
                          _openRatePage(context, ref, foodName),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    RatingStars(rating: review.rating.toDouble(), size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () =>
                          _openRatePage(context, ref, foodName),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  Future<void> _openRatePage(
    BuildContext context,
    WidgetRef ref,
    String foodName,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateFoodPage(
          orderId: order.id,
          foodItemId: item.foodItemId,
          foodName: foodName,
        ),
      ),
    );
    ref.invalidate(customerOrderItemReviewProvider(
      OrderItemReviewKey(order.id, item.foodItemId),
    ));
  }
}
