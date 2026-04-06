import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../shared/event_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfileAsync = ref.watch(currentUserStreamProvider);
    final eventsState = ref.watch(eventsStreamProvider);
    final filteredEvents = ref.watch(filteredEventsListProvider);
    final filters = ref.watch(eventFilterProvider);
    final filterNotifier = ref.read(eventFilterProvider.notifier);

    final today = DateTime.now();
    final isTodaySelected =
        filters.date != null &&
        filters.date!.year == today.year &&
        filters.date!.month == today.month &&
        filters.date!.day == today.day;

    final userName = userProfileAsync.when(
      data: (user) {
        String name = user?.displayName ?? authState.value?.displayName ?? '';
        if (name.trim().isEmpty) {
          name =
              user?.username ?? authState.value?.email?.split('@')[0] ?? 'User';
        }
        return name;
      },
      loading: () => 'Загрузка...',
      error: (e, st) {
        String name = authState.value?.displayName ?? '';
        if (name.trim().isEmpty) {
          name = authState.value?.email?.split('@')[0] ?? 'User';
        }
        return name;
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and notifications
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // User avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_timeGreeting()},',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            userName,
                            style: AppTypography.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Map icon
                    IconButton(
                      onPressed: () {
                        context.push(AppRoutes.map);
                      },
                      icon: const Icon(Icons.map_outlined),
                      iconSize: 28,
                    ),
                    // Notification icon
                    Consumer(
                      builder: (context, ref, child) {
                        final unreadCount = ref.watch(
                          unreadNotificationsCountProvider,
                        );
                        return Badge(
                          isLabelVisible: unreadCount > 0,
                          label: Text(unreadCount.toString()),
                          child: IconButton(
                            onPressed: () {
                              context.push(AppRoutes.notifications);
                            },
                            icon: const Icon(Icons.notifications_outlined),
                            iconSize: 28,
                          ),
                        );
                      },
                    ),
                    // Chats/Messages icon
                    IconButton(
                      onPressed: () {
                        context.push(AppRoutes.chats);
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      iconSize: 28,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Discover card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF8A7A), Color(0xFFFF9B8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ОТКРОЙ ДЛЯ СЕБЯ',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Найди своё\nследующее хобби 🎯',
                        style: AppTypography.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.search),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Исследовать',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filter chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(
                      label: 'На выходных',
                      isSelected: filters.weekendOnly,
                      onSelected: (selected) =>
                          filterNotifier.setWeekendOnly(selected),
                    ),
                    _FilterChip(
                      label: 'Сегодня',
                      isSelected: isTodaySelected,
                      onSelected: (selected) =>
                          filterNotifier.setDateFilter(selected ? today : null),
                    ),
                    _FilterChip(
                      label: 'Бесплатно',
                      isSelected: filters.isFree == true,
                      onSelected: (selected) =>
                          filterNotifier.setFreeFilter(selected ? true : null),
                    ),
                    _FilterChip(
                      label: '18+',
                      isSelected: filters.minAge == 18,
                      onSelected: (selected) =>
                          filterNotifier.setAgeFilter(selected ? 18 : null),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Events header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ближайшие события',
                      style: AppTypography.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: filterNotifier.clearFilters,
                      child: Text(
                        'Все',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: eventsState.when(
                  data: (_) {
                    if (filteredEvents.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Text(
                          'По выбранным фильтрам событий нет.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (
                          int index = 0;
                          index < filteredEvents.length;
                          index++
                        ) ...[
                          EventCard(
                            event: filteredEvents[index],
                            imageUrl: filteredEvents[index].coverImageUrl,
                            onTap: () => context.push(
                              '/home/event/${filteredEvents[index].id}',
                              extra: filteredEvents[index],
                            ),
                          ),
                          if (index != filteredEvents.length - 1)
                            const SizedBox(height: 16),
                        ],
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ошибка загрузки событий: $error',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(eventsStreamProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
