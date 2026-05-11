import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final ValueChanged<int>? onChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        IconData icon;
        if (rating >= value) {
          icon = Icons.star;
        } else if (rating >= value - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        final star = Icon(icon, color: starColor, size: size);
        if (onChanged == null) return star;
        return InkWell(
          onTap: () => onChanged!(value),
          borderRadius: BorderRadius.circular(size),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: star,
          ),
        );
      }),
    );
  }
}
