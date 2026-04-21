import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/category_colors.dart';
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
  String _selectedCategory = 'all';
  String _selectedPriceFilter = 'all';
  String _selectedDateFilter = 'all';

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
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Поиск событий',
                    style: AppTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Категория',
                      icon: Icons.category_outlined,
                      onTap: () => _showCategoryFilter(),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Цена',
                      icon: Icons.payments_outlined,
                      onTap: () => _showPriceFilter(),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Дата',
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _showDateFilter(),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedCategory != 'all' ||
                        _selectedPriceFilter != 'all' ||
                        _selectedDateFilter != 'all')
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'all';
                            _selectedPriceFilter = 'all';
                            _selectedDateFilter = 'all';
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Сбросить'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Ошибка загрузки: $error',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      data: (events) {
        final query = _searchController.text.toLowerCase().trim();

        final filtered = events.where((event) {
          // Search filter
          if (query.isNotEmpty) {
            if (!event.title.toLowerCase().contains(query) &&
                !event.description.toLowerCase().contains(query)) {
              return false;
            }
          }

          // Category filter
          if (_selectedCategory != 'all') {
            if (event.categories.isEmpty ||
                !event.categories.any((cat) =>
                    normalizeCategoryKey(cat) == _selectedCategory)) {
              return false;
            }
          }

          // Price filter
          if (_selectedPriceFilter == 'free' && event.price > 0) {
            return false;
          } else if (_selectedPriceFilter == 'paid' && event.price == 0) {
            return false;
          }

          // Date filter
          final now = DateTime.now();
          if (_selectedDateFilter == 'today') {
            if (!_isSameDay(event.startTime, now)) {
              return false;
            }
          } else if (_selectedDateFilter == 'week') {
            final weekFromNow = now.add(const Duration(days: 7));
            if (event.startTime.isAfter(weekFromNow)) {
              return false;
            }
          } else if (_selectedDateFilter == 'month') {
            final monthFromNow = DateTime(now.year, now.month + 1, now.day);
            if (event.startTime.isAfter(monthFromNow)) {
              return false;
            }
          }

          return true;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ничего не найдено',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить фильтры',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return EventCard(
              event: filtered[index],
              onTap: () => context.push(
                '/home/event/${filtered[index].id}',
                extra: filtered[index],
              ),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _showCategoryFilter() async {
    final interestsAsync = ref.read(interestsProvider);
    final interests = interestsAsync.valueOrNull ?? [];

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите категорию',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip('Все', 'all'),
                    ...interests.map((interest) => _buildCategoryChip(
                          interest.name,
                          normalizeCategoryKey(interest.name),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showPriceFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Фильтр по цене',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPriceOption('Все', 'all'),
                _buildPriceOption('Бесплатные', 'free'),
                _buildPriceOption('Платные', 'paid'),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPriceFilter = result;
      });
    }
  }

  Widget _buildPriceOption(String label, String value) {
    final isSelected = _selectedPriceFilter == value;
    return ListTile(
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<void> _showDateFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Фильтр по дате',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDateOption('Все', 'all'),
                _buildDateOption('Сегодня', 'today'),
                _buildDateOption('На этой неделе', 'week'),
                _buildDateOption('В этом месяце', 'month'),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDateFilter = result;
      });
    }
  }

  Widget _buildDateOption(String label, String value) {
    final isSelected = _selectedDateFilter == value;
    return ListTile(
      title: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () => Navigator.pop(context, value),
    );
  }
}
