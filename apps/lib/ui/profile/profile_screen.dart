import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../models/event.dart';
import '../../models/community.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/community_provider.dart';
import '../shared/event_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserStreamProvider);
    final userEventsAsync = ref.watch(userEventsStreamProvider);
    final userCommunitiesAsync = ref.watch(userCommunitiesProvider);
    final followersCount = ref.watch(followersCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        data: (firebaseUser) {
          if (firebaseUser == null) return _buildNotLoggedIn();
          final firestoreUser = currentUser.value;

          final userEvents = userEventsAsync.maybeWhen(
            data: (events) => events,
            orElse: () => <Event>[],
          );
          final userCommunities = userCommunitiesAsync.maybeWhen(
            data: (communities) => communities,
            orElse: () => <Community>[],
          );

          String displayName =
              firestoreUser?.displayName ?? firebaseUser.displayName ?? '';
          if (displayName.trim().isEmpty) {
            displayName =
                firestoreUser?.username ??
                firebaseUser.email?.split('@')[0] ??
                'Пользователь';
          }

          final email = firestoreUser?.email ?? firebaseUser.email ?? '';
          final photoUrl = firestoreUser?.photoUrl ?? firebaseUser.photoURL;
          final bio =
              firestoreUser?.bio ?? 'Расскажите о себе в настройках профиля';
          final interests = firestoreUser?.interests ?? [];
          return _buildProfile(
            displayName: displayName,
            email: email,
            photoUrl: photoUrl,
            bio: bio,
            interests: interests,
            eventsCount: userEvents.length,
            communitiesCount: userCommunities.length,
            followersCount: followersCount,
            userEvents: userEvents,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Widget _buildProfile({
    required String displayName,
    required String email,
    required String? photoUrl,
    required String bio,
    required List<dynamic> interests,
    required int eventsCount,
    required int communitiesCount,
    required int followersCount,
    required List<Event> userEvents,
  }) {
    final initials = displayName
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join();
    final tags = interests.map((e) => e.toString()).toList();
    final tagColors = [
      [const Color(0xFFF17A5D), const Color(0xFFFFF0ED)],
      [const Color(0xFF2D9CDB), const Color(0xFFE8F4FD)],
      [const Color(0xFF27AE60), const Color(0xFFE8F8EF)],
      [const Color(0xFF9B51E0), const Color(0xFFF3E8FF)],
      [const Color(0xFFF2994A), const Color(0xFFFEF3E8)],
    ];

    return NestedScrollView(
      headerSliverBuilder: (ctx, _) => [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header with settings
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Профиль',
                        style: AppTypography.headingLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.editProfile),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightCoral,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Редактировать',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.settings),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Profile info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl == null
                                      ? Text(
                                          initials,
                                          style: AppTypography.headingSmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTypography.headingSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bio,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CompactStatCell(
                              value: eventsCount.toString(),
                              label: 'События',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.border,
                            ),
                            _CompactStatCell(
                              value: communitiesCount.toString(),
                              label: 'Группы',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.border,
                            ),
                            _CompactStatCell(
                              value: followersCount.toString(),
                              label: 'Подписчики',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppTypography.bodyLarge,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border,
              tabs: [
                const Tab(text: 'О себе'),
                Tab(text: 'События'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'ИНТЕРЕСЫ',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (tags.isEmpty)
                Text(
                  'Нет сохраненных интересов',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.asMap().entries.map((e) {
                    final c = tagColors[e.key % tagColors.length];
                    return _InterestTag(label: e.value, fg: c[0], bg: c[1]);
                  }).toList(),
                ),
            ],
          ),
          _buildEventsTab(context, userEvents),
        ],
      ),
    );
  }

  Widget _buildEventsTab(BuildContext context, List<Event> userEvents) {
    if (userEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_outlined,
              size: 60,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Нет событий',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: userEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = userEvents[index];
        return EventCard(
          event: event,
          onTap: () => context.push('/home/event/${event.id}', extra: event),
        );
      },
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text('Вы не авторизованы', style: AppTypography.headingMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Войти',
              style: AppTypography.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatCell extends StatelessWidget {
  final String value;
  final String label;
  const _CompactStatCell({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.subheadingLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InterestTag extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _InterestTag({required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
}
