import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
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
    {'id': 'sport', 'label': 'Sport', 'icon': Icons.fitness_center_rounded},
    {'id': 'gaming', 'label': 'Gaming', 'icon': Icons.sports_esports_rounded},
    {'id': 'it', 'label': 'IT & Tech', 'icon': Icons.code_rounded},
    {'id': 'music', 'label': 'Music', 'icon': Icons.music_note_rounded},
    {'id': 'art', 'label': 'Art', 'icon': Icons.palette_rounded},
    {'id': 'travel', 'label': 'Travel', 'icon': Icons.landscape_rounded},
    {'id': 'food', 'label': 'Cooking', 'icon': Icons.restaurant_rounded},
    {'id': 'edu', 'label': 'Education', 'icon': Icons.school_rounded},
    {'id': 'photo', 'label': 'Photography', 'icon': Icons.camera_alt_rounded},
    {'id': 'movie', 'label': 'Movies', 'icon': Icons.movie_rounded},
    {'id': 'yoga', 'label': 'Yoga', 'icon': Icons.self_improvement_rounded},
    {'id': 'dance', 'label': 'Dancing', 'icon': Icons.auto_awesome_rounded},
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Button
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Progress Bar (3 steps, 3 active)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Header
              Text(
                'What do you like?',
                style: AppTypography.headingLarge.copyWith(
                  fontSize: 32,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose at least 3 categories to personalize your experience.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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

              const SizedBox(height: 16),

              // Finish Button
              PrimaryButton(
                label: 'Finish Setup',
                onPressed: _selectedInterests.length >= 3 ? _submit : () {},
                isEnabled: _selectedInterests.length >= 3,
                isLoading: false, // Можно добавить состояние загрузки
              ),

              const SizedBox(height: 16),

              // Bottom Back Button
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Back',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
          color: isSelected ? AppColors.primary : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.subheadingMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
