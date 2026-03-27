import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../chat/chat_list_screen.dart';
import 'event_detail_screen.dart';
import 'map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatEventDate(DateTime dateTime) {
    final now = DateTime.now();
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final time = DateFormat('HH:mm').format(dateTime);

    if (eventDate == today) return 'Сегодня, $time';
    if (eventDate == tomorrow) return 'Завтра, $time';

    return DateFormat('dd.MM, HH:mm').format(dateTime);
  }

  String _formatPrice(double price, bool isFree) {
    if (isFree || price <= 0) return 'Бесплатно';
    final hasFraction = price % 1 != 0;
    return '${price.toStringAsFixed(hasFraction ? 2 : 0)} ₽';
  }

  String _categoryLabel(List<String> categories) {
    if (categories.isEmpty) return 'Разное';
    return categories.first;
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'спорт':
      case 'sports':
        return const Color(0xFF81C784);
      case 'технологии':
      case 'tech':
        return const Color(0xFF64B5F6);
      case 'творчество':
      case 'искусство':
      case 'art':
        return const Color(0xFFBA68C8);
      case 'музыка':
      case 'music':
        return const Color(0xFFFFB74D);
      default:
        return AppColors.primary;
    }
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
      data: (user) => 
          user?.displayName ?? 
          user?.username ??
          authState.value?.displayName ?? 
          authState.value?.email?.split('@')[0] ?? 
          'User',
      loading: () => 'Загрузка...',
      error: (e, st) => 
          authState.value?.displayName ?? 
          authState.value?.email?.split('@')[0] ?? 
          'User',
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
                            'Доброе утро,',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatListScreen(),
                          ),
                        );
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
                        onPressed: () {},
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
                          _EventCard(
                            event: filteredEvents[index],
                            imageUrl: filteredEvents[index].coverImageUrl ?? '',
                            category: _categoryLabel(
                              filteredEvents[index].categories,
                            ),
                            title: filteredEvents[index].title,
                            date: _formatEventDate(
                              filteredEvents[index].startTime,
                            ),
                            location:
                                (filteredEvents[index].address ?? '')
                                    .trim()
                                    .isNotEmpty
                                ? filteredEvents[index].address!
                                : 'Локация не указана',
                            participants:
                                filteredEvents[index].participants.length,
                            price: _formatPrice(
                              filteredEvents[index].price,
                              filteredEvents[index].isFree,
                            ),
                            ageRestriction: filteredEvents[index].minAge >= 18
                                ? '${filteredEvents[index].minAge}+'
                                : null,
                            categoryColor: _categoryColor(
                              _categoryLabel(filteredEvents[index].categories),
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
                    child: Text(
                      'Ошибка загрузки событий: $error',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
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

class _EventCard extends StatelessWidget {
  final Event event;
  final String imageUrl;
  final String category;
  final String title;
  final String date;
  final String location;
  final int participants;
  final String price;
  final String? ageRestriction;
  final Color categoryColor;

  const _EventCard({
    required this.event,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.date,
    required this.location,
    required this.participants,
    required this.price,
    required this.categoryColor,
    this.ageRestriction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: categoryColor.withValues(alpha: 0.3),
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: categoryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Price or age badge
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ageRestriction != null
                          ? Colors.black87
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ageRestriction ?? price,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (ageRestriction == null)
                        Text(
                          price,
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Participants and arrow
                  Row(
                    children: [
                      // Avatar stack
                      SizedBox(
                        width: 80,
                        height: 28,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _ParticipantAvatar(
                                color: AppColors.primary,
                              ),
                            ),
                            Positioned(
                              left: 20,
                              child: _ParticipantAvatar(
                                color: Color(0xFF64B5F6),
                              ),
                            ),
                            Positioned(
                              left: 40,
                              child: _ParticipantAvatar(
                                color: Color(0xFF81C784),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$participants идут',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  final Color color;

  const _ParticipantAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
