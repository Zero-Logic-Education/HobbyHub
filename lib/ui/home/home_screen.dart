import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

// TODO: В будущем данные будут загружаться из Firebase Firestore
// Сейчас используем mock данные для отображения UI

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userName = authState.value?.displayName ?? authState.value?.email?.split('@')[0] ?? 'User';

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
                    // Notification icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
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
                      colors: [
                        Color(0xFFFF8A7A),
                        Color(0xFFFF9B8A),
                      ],
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
                          color: Colors.white.withOpacity(0.9),
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
                          backgroundColor: Colors.white.withOpacity(0.3),
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
                    _FilterChip(label: 'На выходных', isSelected: true),
                    _FilterChip(label: 'Сегодня', isSelected: false),
                    _FilterChip(label: 'Бесплатно', isSelected: false),
                    _FilterChip(label: 'Онлайн', isSelected: false),
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
                      onPressed: () {},
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
              
              // TODO: Данные из Firestore
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'TODO: Загрузка из Firebase Firestore',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Event Cards
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _EventCard(
                      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
                      category: 'Здоровье',
                      title: 'Утренняя йога-сессия',
                      date: 'Сегодня, 8:00',
                      location: 'Центральный парк',
                      participants: 24,
                      price: 'Бесплатно',
                      categoryColor: Color(0xFF81C784),
                    ),
                    SizedBox(height: 16),
                    _EventCard(
                      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
                      category: 'Технологии',
                      title: 'Tech Networking Mixer',
                      date: 'Завтра, 18:00',
                      location: 'Tech Hub, Downtown',
                      participants: 56,
                      price: '\$15',
                      categoryColor: Color(0xFF64B5F6),
                    ),
                    SizedBox(height: 16),
                    _EventCard(
                      imageUrl: 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800',
                      category: 'Искусство',
                      title: 'Мастер-класс по гончарству',
                      date: 'Суббота, 14:00',
                      location: 'Арт-студия',
                      participants: 12,
                      price: '\$25',
                      categoryColor: Color(0xFFBA68C8),
                    ),
                    SizedBox(height: 16),
                    _EventCard(
                      imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800',
                      category: 'Музыка',
                      title: 'Джазовый вечер',
                      date: 'Пятница, 20:00',
                      location: 'Jazz Club',
                      participants: 45,
                      price: '\$20',
                      ageRestriction: '18+',
                      categoryColor: Color(0xFFFFB74D),
                    ),
                  ],
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {},
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Навигация на страницу события
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
                          color: categoryColor.withOpacity(0.3),
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
                              child: _ParticipantAvatar(color: AppColors.primary),
                            ),
                            Positioned(
                              left: 20,
                              child: _ParticipantAvatar(color: Color(0xFF64B5F6)),
                            ),
                            Positioned(
                              left: 40,
                              child: _ParticipantAvatar(color: Color(0xFF81C784)),
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