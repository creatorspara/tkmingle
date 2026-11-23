import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/tea_post_model.dart';

class AliasAvatar extends StatelessWidget {
  final MalayalamAlias alias;
  final double radius;
  final bool showBorder;
  final Color? borderColor;

  const AliasAvatar({
    super.key,
    required this.alias,
    this.radius = 20,
    this.showBorder = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final border = borderColor ?? AppColors.tkmPurple;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: border, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.tkmPurple.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          alias.assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: alias.alignment,
          errorBuilder: (context, error, stackTrace) {
            return CachedNetworkImage(
              imageUrl: alias.iconUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: alias.alignment,
              placeholder: (context, url) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
              ),
              errorWidget: (context, url, err) => Container(
                color: AppColors.tkmPurple.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: AppColors.tkmPurple,
                  size: 18,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
