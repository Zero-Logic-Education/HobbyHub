import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Спорт',
      'icon': '🏃',
      'count': 12,
      'color': const Color(0xFFFFF2F2),
    },
    {
      'title': 'Технологии',
      'icon': '💻',
      'count': 8,
      'color': const Color(0xFFF2F8FF),
    },
    {
      'title': 'Творчество',
      'icon': '🎨',
      'count': 15,
      'color': const Color(0xFFFFF9F2),
    },
    {
      'title': 'Музыка',
      'icon': '🎵',
      'count': 24,
      'color': const Color(0xFFF9F2FF),
    },
    {
      'title': 'Еда и напитки',
      'icon': '🍽️',
      'count': 10,
      'color': const Color(0xFFF2FFF2),
    },
    {
      'title': 'Здоровье',
      'icon': '🧘',
      'count': 18,
      'color': const Color(0xFFF2FFFF),
    },
    {
      'title': 'Фотография',
      'icon': '📷',
      'count': 5,
      'color': const Color(0xFFF7F7F7),
    },
    {
      'title': 'Книги',
      'icon': '📚',
      'count': 9,
      'color': const Color(0xFFFFF2FB),
    },
  ];

  final List<String> _popularSearches = [
    'Йога для начинающих',
    'IT Meetup',
    'Мастер-класс по рисованию',
    'Беговой клуб',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _categories[index];
                    return _CategoryCard(
                      title: category['title'],
                      icon: category['icon'],
                      count: category['count'],
                      color: category['color'],
                    );
                  },
                  childCount: _categories.length,
                ),
              ),
            ),

            // Popular Searches Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Популярные запросы',
                  style: AppTypography.subheadingLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Popular Searches Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _popularSearches.map((search) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            search,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String icon;
  final int count;
  final Color color;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count событий',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
