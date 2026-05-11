import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class SectionEyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const SectionEyebrow({
    super.key,
    required this.text,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 24, height: 2, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
