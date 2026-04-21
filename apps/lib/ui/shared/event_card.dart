import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_hub/core/theme/app_colors.dart';
import 'package:hobby_hub/core/theme/app_spacing.dart';
import 'package:hobby_hub/core/theme/app_styles.dart';
import 'package:hobby_hub/core/theme/app_typography.dart';
import 'package:hobby_hub/core/utils/category_colors.dart';
import 'package:hobby_hub/models/event.dart';
import 'package:hobby_hub/models/user.dart';
import 'package:hobby_hub/providers/user_provider.dart';
import 'package:intl/intl.dart';

/// Карточка события для отображения в списке
class EventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final String? imageUrl;

  const EventCard({
    required this.event,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantIds = event.participants.take(3).toList();
    final category = event.categories.isNotEmpty
        ? event.categories.first
        : 'Разное';
    final categoryColor = getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMd),
                  ),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: imageUrl != null
                        ? null
                        : BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor.withValues(alpha: 0.3),
                                categoryColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(categoryColor);
                            },
                          )
                        : _buildPlaceholder(categoryColor),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppStyles.shadowSmallList,
                      ),
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Status badge
                if (event.status.isNotEmpty)
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        event.status,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      getCategoryDisplayLabel(category),
                      style: AppTypography.labelSmall.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Date and time
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(event.startTime),
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Time
                  _buildInfoRow(
                    icon: Icons.access_time_outlined,
                    text: _formatTime(event.startTime),
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Location
                  if (event.address != null && event.address!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      text: event.address!,
                      maxLines: 1,
                    ),
                  SizedBox(height: AppSpacing.md),

                  // Bottom row: price, participants, rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price or Free
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          event.price > 0 ? '${event.price}₸' : 'Бесплатно',
                          style: AppTypography.labelSmall.copyWith(
                            color: event.price > 0
                                ? AppColors.primary
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Participants count
                      Row(
                        children: [
                          _ParticipantsPreview(participantIds: participantIds),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '${event.participants.length}/${event.maxParticipants}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Rating
                      if (event.rating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 4),
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    if (DateFormat.localeExists('ru')) {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
    return DateFormat('dd.MM').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildPlaceholder(Color categoryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration_outlined,
              color: categoryColor,
              size: 48,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            event.title,
            style: AppTypography.labelLarge.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'идёт':
        return AppColors.info;
      case 'скоро':
        return AppColors.warning;
      case 'завершено':
        return AppColors.success;
      case 'отменено':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ParticipantsPreview extends ConsumerWidget {
  final List<String> participantIds;

  const _ParticipantsPreview({required this.participantIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (participantIds.isEmpty) {
      return Icon(Icons.group_outlined, size: 16, color: AppColors.textSecondary);
    }

    final avatars = <Widget>[];
    for (int index = 0; index < participantIds.length; index++) {
      final userAsync = ref.watch(userProfileProvider(participantIds[index]));
      avatars.add(
        Positioned(
          left: index * 14,
          child: _ParticipantCircle(userAsync: userAsync),
        ),
      );
    }

    return SizedBox(
      width: (participantIds.length - 1) * 14 + 20,
      height: 20,
      child: Stack(children: avatars),
    );
  }
}

class _ParticipantCircle extends StatelessWidget {
  final AsyncValue<User?> userAsync;

  const _ParticipantCircle({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) {
        final photoUrl = user?.photoUrl;
        final displayName = user?.displayName ?? user?.username ?? '';
        final initial = displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

        if (photoUrl != null && photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 9,
              backgroundImage: NetworkImage(photoUrl),
            ),
          );
        }

        return CircleAvatar(
          radius: 10,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 9,
            backgroundColor: AppColors.lightCoral,
            child: Text(
              initial,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
      loading: () => CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white,
        child: CircleAvatar(radius: 9, backgroundColor: AppColors.surfaceSecondary),
      ),
      error: (error, stackTrace) => CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white,
        child: CircleAvatar(radius: 9, backgroundColor: AppColors.surfaceSecondary),
      ),
    );
  }
}

/// Компактная карточка события для сетки
class CompactEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final String? imageUrl;

  const CompactEventCard({
    required this.event,
    this.onTap,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: imageUrl != null
                  ? null
                  : BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          getCategoryColor(event.categories.isNotEmpty ? event.categories.first : 'Разное')
                              .withValues(alpha: 0.3),
                          getCategoryColor(event.categories.isNotEmpty ? event.categories.first : 'Разное')
                              .withValues(alpha: 0.1),
                        ],
                      ),
                    ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.celebration_outlined,
                            color: getCategoryColor(event.categories.isNotEmpty ? event.categories.first : 'Разное'),
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.celebration_outlined,
                        color: getCategoryColor(event.categories.isNotEmpty ? event.categories.first : 'Разное'),
                        size: 32,
                      ),
                    ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(event.startTime),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    if (DateFormat.localeExists('ru')) {
      return DateFormat('d MMMM', 'ru').format(dateTime);
    }
    return DateFormat('dd.MM').format(dateTime);
  }
}
