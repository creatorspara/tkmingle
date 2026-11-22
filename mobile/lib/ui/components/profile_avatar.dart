import 'package:flutter/material.dart';
import '../../core/constants/tk_avatars.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool showVerifiedBadge;
  final bool isOnline;
  final VoidCallback? onTap;
  final String? avatarType;
  final String? avatarId;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 28,
    this.showVerifiedBadge = false,
    this.isOnline = false,
    this.onTap,
    this.avatarType,
    this.avatarId,
  });

  @override
  Widget build(BuildContext context) {
    final initials = TkAvatars.getInitials(name.isNotEmpty ? name : 'Student');
    final size = radius * 2;
    final gradientColors = TkAvatars.getDeterministicGradient(name.isNotEmpty ? name : imageUrl);

    Widget imageContent;
    final effectiveSrc = (avatarId != null && avatarId!.isNotEmpty) ? avatarId! : imageUrl.trim();

    if (TkAvatars.isPreset(effectiveSrc) || (avatarType == 'preset' && avatarId != null)) {
      final preset = TkAvatars.getById(avatarId ?? effectiveSrc);
      if (preset != null) {
        imageContent = Image.asset(
          preset.assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initialsWidget(initials, gradientColors),
        );
      } else {
        imageContent = _initialsWidget(initials, gradientColors);
      }
    } else if (effectiveSrc.startsWith('http://') || effectiveSrc.startsWith('https://')) {
      imageContent = Image.network(
        effectiveSrc,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _initialsWidget(initials, gradientColors),
      );
    } else {
      imageContent = _initialsWidget(initials, gradientColors);
    }

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: imageContent,
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

  Widget _initialsWidget(String initials, List<Color> gradientColors) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: AppTypography.titleMedium(Colors.white).copyWith(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
