import 'package:baust_food/app/theme/design_tokens.dart';
import 'package:baust_food/app/widgets/section_eyebrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/review_provider.dart';
import '../widgets/rating_stars.dart';
import '../../data/models/review_model.dart';

class RateFoodPage extends ConsumerStatefulWidget {
  final String orderId;
  final String foodItemId;
  final String foodName;

  const RateFoodPage({
    super.key,
    required this.orderId,
    required this.foodItemId,
    required this.foodName,
  });

  @override
  ConsumerState<RateFoodPage> createState() => _RateFoodPageState();
}

class _RateFoodPageState extends ConsumerState<RateFoodPage> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  Review? _existing;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (_loaded) return;
    _loaded = true;
    final repo = ref.read(reviewRepositoryProvider);
    final existing = await repo.getCustomerReviewForOrderItem(
      orderId: widget.orderId,
      foodItemId: widget.foodItemId,
    );
    if (existing != null && mounted) {
      setState(() {
        _existing = existing;
        _rating = existing.rating;
        _commentController.text = existing.comment ?? '';
      });
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a rating')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(reviewRepositoryProvider);
      final comment = _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim();
      if (_existing != null) {
        await repo.updateReview(
          reviewId: _existing!.id,
          rating: _rating,
          comment: comment,
        );
      } else {
        await repo.submitReview(
          orderId: widget.orderId,
          foodItemId: widget.foodItemId,
          rating: _rating,
          comment: comment,
        );
      }
      ref.invalidate(foodReviewsProvider(widget.foodItemId));
      ref.invalidate(ratingSummaryProvider(widget.foodItemId));
      ref.invalidate(customerOrderItemReviewProvider(
        OrderItemReviewKey(widget.orderId, widget.foodItemId),
      ));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(_existing != null ? 'Edit Review' : 'Rate Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionEyebrow(text: 'How was it?'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.foodName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl2,
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.canvasSoft,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Center(
                child: RatingStars(
                  rating: _rating.toDouble(),
                  size: 44,
                  onChanged: (value) => setState(() => _rating = value),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : Text(_existing != null ? 'Update Review' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
