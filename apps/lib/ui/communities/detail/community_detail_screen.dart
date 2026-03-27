import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../shared/app_button.dart';
import '../../shared/event_card.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String communityId;

  const CommunityDetailScreen({super.key, required this.communityId});

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
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                      },
                    ),
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
                                  final firestoreService = ref.read(
                                    firestoreServiceProvider,
                                  );
                                  if (isMember) {
                                    await firestoreService.leaveCommunity(
                                      communityId,
                                      currentUserId,
                                    );
                                  } else {
                                    await firestoreService.joinCommunity(
                                      communityId,
                                      currentUserId,
                                    );
                                  }
                                },
                                label: isMember ? 'Покинуть' : 'Вступить',
                              ),
                            ),
                        ],
                      ),
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
                                context.push('/create');
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
