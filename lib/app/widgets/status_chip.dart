import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  factory StatusChip.fromOrderStatus(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'pending':
        return StatusChip(
          label: 'Pending',
          background: AppColors.canvasSoft,
          foreground: AppColors.ink,
        );
      case 'accepted':
        return const StatusChip(
          label: 'Accepted',
          background: Color(0xFFE3F2FD),
          foreground: Color(0xFF0D47A1),
        );
      case 'preparing':
        return const StatusChip(
          label: 'Preparing',
          background: Color(0xFFFFF3E0),
          foreground: Color(0xFFE65100),
        );
      case 'ready':
        return const StatusChip(
          label: 'Ready',
          background: Color(0xFFE8F5E9),
          foreground: Color(0xFF1B5E20),
        );
      case 'delivered':
        return const StatusChip(
          label: 'Delivered',
          background: AppColors.ink,
          foreground: AppColors.onDark,
        );
      case 'cancelled':
        return const StatusChip(
          label: 'Cancelled',
          background: Color(0xFFFFEBEE),
          foreground: AppColors.primary,
        );
      default:
        return StatusChip(
          label: statusName,
          background: AppColors.canvasSoft,
          foreground: AppColors.ink,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pillMd),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
