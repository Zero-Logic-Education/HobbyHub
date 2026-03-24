import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(dateTime);
  }

  String _formatPrice(double price, bool isFree) {
    if (isFree || price <= 0) return 'Бесплатно';
    final hasFraction = price % 1 != 0;
    return '${price.toStringAsFixed(hasFraction ? 2 : 0)} ₽';
  }

  String _categoryLabel() {
    if (event.categories.isEmpty) return 'Разное';
    return event.categories.first;
  }

  Color _categoryColor() {
    switch (_categoryLabel().toLowerCase()) {
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
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor();
    final location = (event.address ?? '').trim().isNotEmpty
        ? event.address!
        : 'Локация не указана';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                event.coverImageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: categoryColor.withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: categoryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: AppTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date & Time and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Дата и время',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(event.startTime),
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Цена',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(event.price, event.isFree),
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (event.latitude != 0 || event.longitude != 0)
                              Text(
                                '${event.latitude.toStringAsFixed(4)}, ${event.longitude.toStringAsFixed(4)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View Map button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Показать на карте'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Event
                  Text(
                    'О событии',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Join Event button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Присоединиться',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _categoryLabel(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Organizer
                  Text(
                    'Организатор',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'H',
                          style: AppTypography.headingMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Команда HobbyHub',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Смотреть профиль →',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Attendees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Участники (${event.participants.length})',
                        style: AppTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Смотреть всех →',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Attendees avatars
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 40,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _AttendeeAvatar(color: Color(0xFFFF8A7A)),
                            ),
                            Positioned(
                              left: 30,
                              child: _AttendeeAvatar(color: Color(0xFF64B5F6)),
                            ),
                            Positioned(
                              left: 60,
                              child: _AttendeeAvatar(color: Color(0xFF81C784)),
                            ),
                            if (event.participants.length > 3)
                              Positioned(
                                left: 90,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    '+${event.participants.length - 3}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendeeAvatar extends StatelessWidget {
  final Color color;

  const _AttendeeAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
          image: NetworkImage(
            'https://i.pravatar.cc/150?img=${color.hashCode % 70}',
          ),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {},
        ),
      ),
    );
  }
}
