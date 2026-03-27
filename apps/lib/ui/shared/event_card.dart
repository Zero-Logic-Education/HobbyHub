import 'package:flutter/material.dart';
import 'package:hobby_hub/core/theme/app_colors.dart';
import 'package:hobby_hub/core/theme/app_spacing.dart';
import 'package:hobby_hub/core/theme/app_styles.dart';
import 'package:hobby_hub/core/theme/app_typography.dart';
import 'package:hobby_hub/models/event.dart';
import 'package:intl/intl.dart';

/// Карточка события для отображения в списке
class EventCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    color: AppColors.lightPink,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textHint,
                                  size: 48,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.event,
                              color: AppColors.textHint,
                              size: 48,
                            ),
                          ),
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
                          event.price > 0 ? '${event.price}₽' : 'Бесплатно',
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
                          Icon(
                            Icons.group_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
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
    return DateFormat('d MMMM', 'ru').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
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
              color: AppColors.lightPink,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.event,
                            color: AppColors.textHint,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.event,
                        color: AppColors.textHint,
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
    return DateFormat('d MMMM', 'ru').format(dateTime);
  }
}
