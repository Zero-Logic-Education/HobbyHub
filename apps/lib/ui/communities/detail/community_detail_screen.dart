import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
      backgroundColor: AppColors.background,
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    community.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: community.coverImageUrl != null
                      ? Image.network(
                          community.coverImageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.groups,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                ),
                actions: [
                  if (isModerator)
                    IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Участников: ${community.members.length}',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (currentUserId != null && !isModerator)
                            SizedBox(
                              width: 120,
                              child: PrimaryButton(
                                onPressed: () async {
                                  await _toggleMembership(
                                    context: context,
                                    ref: ref,
                                    community: community,
                                    currentUserId: currentUserId,
                                    isMember: isMember,
                                  );
                                },
                                label: isMember ? 'Покинуть' : 'Вступить',
                              ),
                            ),
                        ],
                      ),
                      if (isMember) ...[
                        const SizedBox(height: 12),
                        PrimaryButton(
                          onPressed: () {
                            _openCommunityChat(
                              context: context,
                              ref: ref,
                              community: community,
                              currentUserId: currentUserId,
                            );
                          },
                          label: 'Открыть чат группы',
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text('О сообществе', style: AppTypography.headingSmall),
                      const SizedBox(height: 8),
                      Text(
                        community.description,
                        style: AppTypography.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'События сообщества',
                            style: AppTypography.headingSmall,
                          ),
                          if (isModerator)
                            TextButton(
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
                              child: const Text('Создать'),
                            ),
                        ],
                      ),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Пока нет событий',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
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
}
