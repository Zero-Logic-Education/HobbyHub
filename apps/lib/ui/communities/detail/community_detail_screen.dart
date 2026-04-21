import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/category_colors.dart';
import '../../../models/community.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/chat_service.dart';
import '../../shared/app_button.dart';
import '../../shared/event_card.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String communityId;

  const CommunityDetailScreen({super.key, required this.communityId});

  Future<void> _toggleMembership({
    required BuildContext context,
    required WidgetRef ref,
    required Community community,
    required String currentUserId,
    required bool isMember,
  }) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final chatService = ref.read(chatServiceProvider);
    late final List<String> updatedMembers;

    try {
      if (isMember) {
        await firestoreService.leaveCommunity(community.id, currentUserId);
        updatedMembers = community.members
            .where((id) => id != currentUserId)
            .toList();
      } else {
        await firestoreService.joinCommunity(community.id, currentUserId);
        updatedMembers = <String>{...community.members, currentUserId}.toList();
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить участие в сообществе.'),
        ),
      );
      return;
    }

    try {
      await chatService.syncCommunityChatParticipants(
        community.id,
        updatedMembers,
      );
    } catch (_) {
      // Не блокируем вступление/выход, если синхронизация участников чата временно недоступна.
    }
  }

  Future<void> _openCommunityChat({
    required BuildContext context,
    required WidgetRef ref,
    required Community community,
    required String? currentUserId,
  }) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Войдите в аккаунт, чтобы открыть чат.')),
      );
      return;
    }

    if (!community.members.contains(currentUserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала вступите в сообщество, чтобы писать в чат.'),
        ),
      );
      return;
    }

    try {
      final chatId = await ref
          .read(chatServiceProvider)
          .getOrCreateCommunityChat(
            communityId: community.id,
            communityName: community.name,
            communityCoverUrl: community.coverImageUrl,
            memberIds: community.members,
          );

      if (!context.mounted) return;
      context.push('${AppRoutes.chats}/$chatId');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть чат сообщества.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityStreamProvider(communityId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: communityAsync.when(
        data: (community) {
          if (community == null) {
            return const Scaffold(
              body: Center(child: Text('Сообщество не найдено')),
            );
          }

          final isMember =
              currentUserId != null &&
              community.members.contains(currentUserId);
          final isModerator =
              currentUserId != null &&
              community.moderators.contains(currentUserId);
          final category = community.categories.isNotEmpty
              ? community.categories.first
              : 'Разное';
          final categoryColor = getCategoryColor(category);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  if (isModerator)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: community.coverImageUrl != null &&
                          community.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          community.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCommunityPlaceholder(community);
                          },
                        )
                      : _buildCommunityPlaceholder(community),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              community.name,
                              style: AppTypography.headingLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getCategoryDisplayLabel(category),
                          style: AppTypography.bodyMedium.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Members count
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${community.members.length} участников',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Action buttons
                      if (currentUserId != null && !isModerator)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _toggleMembership(
                                context: context,
                                ref: ref,
                                community: community,
                                currentUserId: currentUserId,
                                isMember: isMember,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMember
                                  ? AppColors.surfaceSecondary
                                  : AppColors.primary,
                              foregroundColor: isMember
                                  ? AppColors.textPrimary
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isMember ? 'Покинуть группу' : 'Вступить в группу',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (isMember) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _openCommunityChat(
                                context: context,
                                ref: ref,
                                community: community,
                                currentUserId: currentUserId,
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Открыть чат группы'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Description
                      Text(
                        'О сообществе',
                        style: AppTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        community.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Events section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'События',
                            style: AppTypography.headingMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isModerator)
                            TextButton.icon(
                              onPressed: () {
                                context.push(
                                  AppRoutes.createEvent,
                                  extra: {
                                    'communityId': community.id,
                                    'communityCategory':
                                        community.categories.isNotEmpty
                                        ? community.categories.first
                                        : null,
                                  },
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              label: const Text('Создать'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final eventsAsync = ref.watch(
                    communityEventsProvider(communityId),
                  );
                  return eventsAsync.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy_outlined,
                                    size: 64,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Пока нет событий',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: EventCard(event: events[index]),
                          );
                        }, childCount: events.length),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => SliverToBoxAdapter(
                      child: Center(child: Text('Ошибка: $error')),
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildCommunityPlaceholder(Community community) {
    final category = community.categories.isNotEmpty
        ? community.categories.first
        : 'Разное';
    final color = getCategoryColor(category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.groups_rounded,
                color: color,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                community.name,
                style: AppTypography.headingMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
