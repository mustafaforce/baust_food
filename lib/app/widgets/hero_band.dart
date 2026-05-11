import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Vodafone-style ink hero band with massive uppercase headline.
class HeroBand extends StatelessWidget {
  final String eyebrow;
  final String headline;
  final String? subhead;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color background;
  final Color foreground;

  const HeroBand({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.subhead,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xl2,
      AppSpacing.xl3,
      AppSpacing.xl2,
      AppSpacing.xl3,
    ),
    this.background = AppColors.ink,
    this.foreground = AppColors.onDark,
  });

  const HeroBand.red({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.subhead,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.xl2,
      AppSpacing.xl3,
      AppSpacing.xl2,
      AppSpacing.xl3,
    ),
  })  : background = AppColors.primary,
        foreground = AppColors.onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            headline.toUpperCase(),
            style: TextStyle(
              color: foreground,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
          if (subhead != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              subhead!,
              style: TextStyle(
                color: foreground.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(height: AppSpacing.xl),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Square red orb with optional icon — the brand's anchor mark.
class SpeechmarkOrb extends StatelessWidget {
  final double size;
  final IconData icon;

  const SpeechmarkOrb({
    super.key,
    this.size = 48,
    this.icon = Icons.format_quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.onPrimary, size: size * 0.55),
    );
  }
}
