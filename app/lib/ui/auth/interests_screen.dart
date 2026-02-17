import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/user_provider.dart';
import '../shared/app_button.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final Set<String> _selectedInterests = {};

  final List<Map<String, dynamic>> _categories = [
    {'id': 'sport', 'label': 'Спорт', 'icon': Icons.fitness_center},
    {'id': 'gaming', 'label': 'Гейминг', 'icon': Icons.sports_esports},
    {'id': 'it', 'label': 'IT и Технологии', 'icon': Icons.code},
    {'id': 'music', 'label': 'Музыка', 'icon': Icons.music_note},
    {'id': 'art', 'label': 'Искусство', 'icon': Icons.palette},
    {'id': 'travel', 'label': 'Путешествия', 'icon': Icons.landscape},
    {'id': 'food', 'label': 'Кулинария', 'icon': Icons.restaurant},
    {'id': 'edu', 'label': 'Обучение', 'icon': Icons.school},
    {'id': 'photo', 'label': 'Фотография', 'icon': Icons.camera_alt},
    {'id': 'movie', 'label': 'Кино', 'icon': Icons.movie},
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  Future<void> _submit() async {
    final notifier = ref.read(currentUserProfileNotifierProvider.notifier);
    await notifier.updateProfile(interests: _selectedInterests.toList());

    if (mounted) {
      context.push(AppRoutes.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ваши интересы'),
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
              Text('Что вам нравится?', style: AppTypography.headingLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Выберите хотя бы 3 категории, чтобы мы могли настроить ленту под вас.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedInterests.contains(
                      category['id'],
                    );
                    return _InterestCard(
                      label: category['label'],
                      icon: category['icon'],
                      isSelected: isSelected,
                      onTap: () => _toggleInterest(category['id']),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Завершить',
                onPressed: _selectedInterests.length >= 3 ? _submit : () {},
                isEnabled: _selectedInterests.length >= 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestCard({
    required this.label,
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
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
