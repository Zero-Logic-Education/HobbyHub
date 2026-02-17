import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/user_provider.dart';
import '../shared/app_button.dart';

class AgeVerificationScreen extends ConsumerStatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  ConsumerState<AgeVerificationScreen> createState() =>
      _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends ConsumerState<AgeVerificationScreen> {
  int? _selectedAgeGroup;

  final List<Map<String, dynamic>> _ageGroups = [
    {
      'age': 12,
      'title': 'Junior',
      'description': 'Для подростков. Доступ к школьным событиям и кружкам.',
      'icon': Icons.school_outlined,
    },
    {
      'age': 18,
      'title': 'Standard',
      'description': 'Полный доступ ко всем событиям и сообществам.',
      'icon': Icons.person_outline,
    },
    {
      'age': 25,
      'title': 'Organizer',
      'description': 'Возможность создавать свои события и группы.',
      'icon': Icons.groups_outlined,
    },
    {
      'age': 35,
      'title': 'Pro',
      'description': 'Расширенные возможности для профессиональных встреч.',
      'icon': Icons.star_outline,
    },
  ];

  Future<void> _submit() async {
    if (_selectedAgeGroup == null) return;

    final notifier = ref.read(ageVerificationNotifierProvider.notifier);
    await notifier.verifyAge(age: _selectedAgeGroup!);

    if (mounted) {
      if (_selectedAgeGroup! < 18) {
        context.push(AppRoutes.parentalConsent);
      } else {
        context.push(AppRoutes.interestsSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ваш возраст'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
            vertical: AppSpacing.screenPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выберите возрастную группу',
                style: AppTypography.headingLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Это поможет нам подобрать наиболее подходящие события для вас.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: _ageGroups.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final group = _ageGroups[index];
                    final isSelected = _selectedAgeGroup == group['age'];
                    return _AgeGroupCard(
                      title: group['title'],
                      age: group['age'],
                      description: group['description'],
                      icon: group['icon'],
                      isSelected: isSelected,
                      onTap: () =>
                          setState(() => _selectedAgeGroup = group['age']),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Продолжить',
                onPressed: _selectedAgeGroup != null ? _submit : () {},
                isEnabled: _selectedAgeGroup != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeGroupCard extends StatelessWidget {
  final String title;
  final int age;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeGroupCard({
    required this.title,
    required this.age,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.subheadingLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$age+',
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
