import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/category_icons.dart';
import '../../providers/event_provider.dart';
import '../../providers/interest_provider.dart';
import '../shared/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(eventSearchQueryProvider.notifier).state =
          _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(eventSearchQueryProvider);
    final isSearching = query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Поиск',
                  style: AppTypography.headingLarge.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'События, хобби, люди',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (isSearching)
              _buildSearchResults()
            else
              ..._buildExploreSections(),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final query = ref.watch(eventSearchQueryProvider).toLowerCase().trim();
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
              ),
            );
          }, childCount: 3),
        ),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Ошибка загрузки результатов: $error',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
      data: (events) {
        final filtered = events.where((event) {
          if (query.isEmpty) return true;
          return event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Ничего не найдено',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(event: filtered[index]),
              ),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildExploreSections() {
    final interestsAsync = ref.watch(interestsProvider);

    return [
      // Browse Categories Title
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Просмотр категорий',
            style: AppTypography.subheadingLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),

      // Categories Grid
      interestsAsync.when(
        data: (interests) {
          if (interests.isEmpty) {
            return SliverToBoxAdapter(child: Container());
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final interest = interests[index];

                return _CategoryCard(
                  title: interest.name,
                  icon: _getIconForCategory(interest.category),
                  onTap: () {
                    ref.read(eventFilterProvider.notifier).setCategoryFilter([
                      interest.name,
                    ]);
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                );
              }, childCount: interests.length),
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            SliverToBoxAdapter(child: Center(child: Text('Ошибка: $e'))),
      ),
    ];
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sports':
        return Icons.directions_run_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'art':
        return Icons.palette_outlined;
      case 'music':
        return Icons.music_note_rounded;
      case 'yoga':
      case 'wellness':
        return Icons.self_improvement_rounded;
      case 'cooking':
        return Icons.restaurant_rounded;
      case 'photography':
        return Icons.camera_alt_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'dance':
        return Icons.music_note_rounded;
      case 'movies':
        return Icons.movie_rounded;
      case 'fashion':
        return Icons.checkroom_rounded;
      case 'gardening':
        return Icons.yard_rounded;
      case 'crafts':
        return Icons.brush_rounded;
      case 'travel':
        return Icons.flight_rounded;
      default:
        return categoryIcon(category);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _CategoryCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
