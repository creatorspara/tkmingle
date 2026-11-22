import 'package:flutter/material.dart';
import '../../core/constants/tk_avatars.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PresetAvatarPickerSheet extends StatefulWidget {
  final String? currentAvatarId;
  final ValueChanged<TkAvatar> onSelect;

  const PresetAvatarPickerSheet({
    super.key,
    this.currentAvatarId,
    required this.onSelect,
  });

  static Future<TkAvatar?> show(BuildContext context, {String? currentAvatarId}) {
    return showModalBottomSheet<TkAvatar>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PresetAvatarPickerSheet(
        currentAvatarId: currentAvatarId,
        onSelect: (avatar) => Navigator.of(context).pop(avatar),
      ),
    );
  }

  @override
  State<PresetAvatarPickerSheet> createState() => _PresetAvatarPickerSheetState();
}

class _PresetAvatarPickerSheetState extends State<PresetAvatarPickerSheet> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Tech & Code',
    'Engineering',
    'Arts & Design',
    'Science & Maker',
    'Campus Life',
  ];

  @override
  Widget build(BuildContext context) {
    final cleanCurrentId = widget.currentAvatarId?.replaceAll('preset:', '');
    final filtered = _selectedCategory == 'All'
        ? TkAvatars.all
        : TkAvatars.all.where((a) => a.category == _selectedCategory).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.primaryAccent, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Brand Avatar',
                      style: AppTypography.titleLarge(Colors.white).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '24 built-in campus avatars — no upload needed',
                      style: AppTypography.labelSmall(AppColors.darkTextMuted),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.darkTextMuted, size: 20),
                ),
              ],
            ),
          ),

          // Categories bar
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkTextMuted,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryAccent,
                  backgroundColor: AppColors.darkCard,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryAccent : Colors.white12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Avatar Grid
          Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final avatar = filtered[index];
                final isCurrent = cleanCurrentId == avatar.id;

                return GestureDetector(
                  onTap: () => widget.onSelect(avatar),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkCard,
                            border: Border.all(
                              color: isCurrent ? AppColors.highlight : avatar.accentColor.withOpacity(0.4),
                              width: isCurrent ? 2.5 : 1.5,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.highlight.withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  avatar.assetPath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (isCurrent)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.highlight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 10,
                                      color: AppColors.darkBackground,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avatar.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.highlight : Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
