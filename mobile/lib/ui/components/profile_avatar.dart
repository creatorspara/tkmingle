import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool showVerifiedBadge;
  final bool isOnline;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 28,
    this.showVerifiedBadge = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final size = radius * 2;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _initialsWidget(initials),
              )
            : _initialsWidget(initials),
      ),
    );

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    if (!showVerifiedBadge && !isOnline) {
      return avatar;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (showVerifiedBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.highlight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 11,
                  color: AppColors.darkBackground,
                ),
              ),
            ),
          )
        else if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.darkBackground,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsWidget(String initials) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.darkElevated,
      child: Text(
        initials,
        style: AppTypography.titleMedium(Colors.white).copyWith(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String string) {
    if (string.trim().isEmpty) return '?';
    final parts = string.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return string.substring(0, string.length >= 2 ? 2 : 1).toUpperCase();
  }
}
