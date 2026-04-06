import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_provider.dart';

class EventReviewsListScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventReviewsListScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventReviewsListScreen> createState() =>
      _EventReviewsListScreenState();
}

class _EventReviewsListScreenState extends ConsumerState<EventReviewsListScreen> {
  String _sort = 'newest';

  String _sortLabel(String value) {
    switch (value) {
      case 'highest':
        return 'Сначала высокие оценки';
      case 'lowest':
        return 'Сначала низкие оценки';
      case 'newest':
      default:
        return 'Сначала новые';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.read(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзывы'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: StreamBuilder(
        stream: firestoreService.getEventReviewsStream(widget.eventId, sort: _sort),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка при загрузке отзывов'));
          }

          final reviews = snapshot.data?.docs ?? const [];

          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                'Пока нет отзывов',
                style: AppTypography.bodyLarge,
              ),
            );
          }

          var totalRating = 0.0;
          for (final reviewDoc in reviews) {
            final review = reviewDoc.data() as Map<String, dynamic>;
            totalRating += (review['rating'] as num?)?.toDouble() ?? 0.0;
          }
          final averageRating = totalRating / reviews.length;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      '${averageRating.toStringAsFixed(1)} ★',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${reviews.length} отзывов',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _sort,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Новые'),
                        ),
                        DropdownMenuItem(
                          value: 'highest',
                          child: Text('Высокие'),
                        ),
                        DropdownMenuItem(
                          value: 'lowest',
                          child: Text('Низкие'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _sort = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _sortLabel(_sort),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final review = reviews[index].data() as Map<String, dynamic>;
                    final userId = (review['authorId'] ?? review['userId']) as String;
                    final rating = (review['rating'] as num?)?.toInt() ?? 0;
                    final comment = (review['comment'] as String?) ?? '';
                    final createdAt = review['createdAt'];
                    DateTime? date;
                    if (createdAt is Timestamp) {
                      date = createdAt.toDate();
                    }

                    return FutureBuilder(
                      future: firestoreService.getUser(userId),
                      builder: (context, userSnapshot) {
                        String userName = 'Пользователь';
                        String? avatarUrl;

                        if (userSnapshot.hasData &&
                            userSnapshot.data != null &&
                            userSnapshot.data!.exists) {
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          userName =
                              (userData['displayName'] as String?)?.trim().isNotEmpty == true
                              ? userData['displayName'] as String
                              : (userData['username'] as String?) ?? 'Пользователь';
                          avatarUrl = userData['photoUrl'] as String?;
                        }

                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      backgroundImage: avatarUrl != null
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: avatarUrl == null
                                          ? const Icon(Icons.person, color: AppColors.primary)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: AppTypography.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              ...List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 16,
                                                  color: Colors.amber,
                                                );
                                              }),
                                              const SizedBox(width: 8),
                                              if (date != null)
                                                Text(
                                                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                                                  style: AppTypography.bodySmall.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (comment.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(comment, style: AppTypography.bodyMedium),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
