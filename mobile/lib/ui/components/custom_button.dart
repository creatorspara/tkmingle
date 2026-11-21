import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, ghost }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20, color: _getTextColor(isDark)),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTypography.labelLarge(_getTextColor(isDark)),
        ),
      ],
    );

    if (variant == ButtonVariant.primary) {
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: onPressed == null ? null : AppColors.primaryGradient,
            color: onPressed == null ? (isDark ? AppColors.darkBorder : AppColors.lightBorder) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryAccent.withOpacity(0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: buttonContent,
          ),
        ),
      );
    }

    if (variant == ButtonVariant.secondary) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkElevated : AppColors.lightElevated,
            foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: buttonContent,
        ),
      );
    }

    if (variant == ButtonVariant.outline) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryAccent,
            side: const BorderSide(color: AppColors.primaryAccent, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: buttonContent,
        ),
      );
    }

    // Ghost
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buttonContent,
      ),
    );
  }

  Color _getTextColor(bool isDark) {
    if (variant == ButtonVariant.primary) return Colors.white;
    if (variant == ButtonVariant.outline) return AppColors.primaryAccent;
    if (variant == ButtonVariant.secondary) {
      return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }
}
