import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
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
    {'id': 'sports', 'label': 'Sports', 'icon': Icons.sports_soccer_rounded},
    {'id': 'tech', 'label': 'Technology', 'icon': Icons.laptop_mac_rounded},
    {'id': 'art', 'label': 'Art & Craft', 'icon': Icons.palette_rounded},
    {'id': 'music', 'label': 'Music', 'icon': Icons.music_note_rounded},
    {'id': 'food', 'label': 'Food & Drink', 'icon': Icons.restaurant_rounded},
    {
      'id': 'wellness',
      'label': 'Wellness',
      'icon': Icons.self_improvement_rounded,
    },
    {'id': 'photo', 'label': 'Photography', 'icon': Icons.camera_alt_rounded},
    {'id': 'books', 'label': 'Books', 'icon': Icons.auto_stories_rounded},
    {'id': 'travel', 'label': 'Travel', 'icon': Icons.flight_takeoff_rounded},
    {'id': 'gaming', 'label': 'Gaming', 'icon': Icons.sports_esports_rounded},
    {'id': 'fitness', 'label': 'Fitness', 'icon': Icons.fitness_center_rounded},
    {'id': 'movies', 'label': 'Movies', 'icon': Icons.movie_rounded},
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
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedCount = _selectedInterests.length;
    final int neededCount = 3 - selectedCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Back Button
                Padding(
                  padding: const EdgeInsets.only(top: 16),
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

                // Progress Bar (3 steps, all active)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Header
                Text(
                  'Choose your interests',
                  style: AppTypography.headingLarge.copyWith(
                    fontSize: 32,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select at least 3 to personalize your experience',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Selection Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$selectedCount selected',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (neededCount > 0)
                      Text(
                        '$neededCount more needed',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 24),

                // Categories Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.35,
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
                  label: 'Continue to HobbyHub',
                  onPressed: selectedCount >= 3 ? _submit : () {},
                  isEnabled: selectedCount >= 3,
                ),

                const SizedBox(height: 16),

                // Skip Button
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(
                      'Skip for now',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.subheadingMedium.copyWith(
                color: AppColors.textPrimary,
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
