import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class InterestChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isMutual;
  final VoidCallback? onTap;
  final IconData? icon;

  const InterestChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isMutual = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isMutual) {
      backgroundColor = AppColors.highlight.withOpacity(0.18);
      textColor = AppColors.highlight;
      border = Border.all(color: AppColors.highlight.withOpacity(0.45), width: 1);
    } else if (isSelected) {
      backgroundColor = AppColors.primaryAccent;
      textColor = Colors.white;
      border = null;
    } else {
      backgroundColor = isDark ? AppColors.darkElevated : AppColors.lightElevated;
      textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      border = Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7.5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMutual) ...[
                const Icon(Icons.auto_awesome, size: 13, color: AppColors.highlight),
                const SizedBox(width: 5),
              ] else if (icon != null) ...[
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTypography.labelSmall(textColor).copyWith(
                  fontWeight: (isSelected || isMutual) ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
