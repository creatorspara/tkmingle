import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final bool isGlowing;

  const StatusBadge({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primaryAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: baseColor.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: baseColor),
            const SizedBox(width: 4.5),
          ],
          Text(
            text,
            style: AppTypography.labelSmall(baseColor).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
