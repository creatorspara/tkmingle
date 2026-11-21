import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/college_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../state/discovery_provider.dart';
import '../../components/custom_button.dart';
import '../../components/interest_chip.dart';

class DiscoveryFilterSheet extends ConsumerStatefulWidget {
  const DiscoveryFilterSheet({super.key});

  @override
  ConsumerState<DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends ConsumerState<DiscoveryFilterSheet> {
  late String _dept;
  late String _year;
  late String _interest;
  late bool _onlyAvailable;
  late bool _recentlyJoined;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(discoveryFiltersProvider);
    _dept = filters.department;
    _year = filters.academicYear;
    _interest = filters.interest;
    _onlyAvailable = filters.onlyAvailable;
    _recentlyJoined = filters.recentlyJoined;
  }

  void _apply() {
    ref.read(discoveryFiltersProvider.notifier).state = DiscoveryFilters(
      department: _dept,
      academicYear: _year,
      interest: _interest,
      onlyAvailable: _onlyAvailable,
      recentlyJoined: _recentlyJoined,
    );
    ref.read(discoveryProvider.notifier).refresh();
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _dept = 'All';
      _year = 'All';
      _interest = 'All';
      _onlyAvailable = false;
      _recentlyJoined = false;
    });
    ref.read(discoveryFiltersProvider.notifier).state = const DiscoveryFilters();
    ref.read(discoveryProvider.notifier).refresh();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deptOptions = [
      'All',
      'Same Department',
      'Different Department',
      ...CollegeData.departments,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discovery Filters',
                    style: AppTypography.headlineLarge(
                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset All', style: TextStyle(color: AppColors.primaryAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Department Scope
              Text(
                'Department & Cross-Branch Scope',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _dept,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: deptOptions.map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _dept = val);
                },
              ),
              const SizedBox(height: 20),
              // Academic Year
              Text(
                'Academic Year',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', ...CollegeData.academicYears].map((yr) {
                  final isSel = _year == yr;
                  return ChoiceChip(
                    label: Text(yr),
                    selected: isSel,
                    selectedColor: AppColors.primaryAccent,
                    onSelected: (selected) {
                      if (selected) setState(() => _year = yr);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Interests
              Text(
                'Specific Interest Match',
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', ...CollegeData.interestCategories].map((cat) {
                  final isSel = _interest == cat;
                  return InterestChip(
                    label: cat,
                    isSelected: isSel,
                    onTap: () => setState(() => _interest = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Switch filters
              SwitchListTile(
                title: const Text('Only Available to Socialize Now'),
                subtitle: const Text('Filters for students who marked themselves active'),
                value: _onlyAvailable,
                activeColor: AppColors.highlight,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _onlyAvailable = val),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Apply Filters',
                width: double.infinity,
                onPressed: _apply,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
