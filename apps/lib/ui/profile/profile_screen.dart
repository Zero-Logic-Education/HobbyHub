import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/community_provider.dart';

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
          final userEvents = userEventsAsync.value ?? [];
          final userCommunities = userCommunitiesAsync.value ?? [];

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Профиль',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.editProfile),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightCoral,
                            borderRadius: BorderRadius.circular(10),
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
                        onTap: () {
                          context.push(AppRoutes.settings);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.paddingOf(context).top + 60,
                  16,
                  0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.9),
                              AppColors.secondary.withValues(alpha: 0.7),
                              const Color(0xFFFFB5A0).withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Transform.translate(
                          offset: const Offset(0, -38),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE8B86D),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Text(
                                      initials,
                                      style: AppTypography.headingSmall
                                          .copyWith(color: AppColors.primary),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTypography.subheadingLarge.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bio,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: [
                  _StatCell(
                    icon: Icons.event_outlined,
                    iconColor: AppColors.primary,
                    value: eventsCount.toString(),
                    label: 'События',
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _StatCell(
                    icon: Icons.groups_2_outlined,
                    iconColor: const Color(0xFF2D9CDB),
                    value: communitiesCount.toString(),
                    label: 'Группы',
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _StatCell(
                    icon: Icons.favorite_border_rounded,
                    iconColor: const Color(0xFFE84D8A),
                    value: followersCount.toString(),
                    label: 'Подписчики',
                  ),
                ],
              ),
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
              labelStyle: AppTypography.subheadingSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppTypography.subheadingSmall,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border,
              tabs: [
                const Tab(text: 'О себе'),
                Tab(text: 'События ($eventsCount)'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const SizedBox(height: 4),
              const _SectionLabel(label: 'ИНТЕРЕСЫ'),
              const SizedBox(height: 12),
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
              const SizedBox(height: 28),
              const _SectionLabel(label: 'НАСТРОЙКИ'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconBg: Color(0xFFFFF5E0),
                iconColor: Color(0xFFF2994A),
                title: 'Уведомления',
                subtitle: 'Push и email-рассылки',
                onTap: _openNotificationSettings,
              ),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconBg: Color(0xFFE8F4FD),
                iconColor: Color(0xFF2D9CDB),
                title: 'Конфиденциальность',
                subtitle: 'Защита аккаунта',
                onTap: _openPrivacySettings,
              ),
              const SizedBox(height: 28),
              _SettingsTile(
                icon: Icons.star_outline_rounded,
                iconBg: Color(0xFFFFFBE6),
                iconColor: Color(0xFFE8B86D),
                title: 'Оценить приложение',
                subtitle: 'Поделитесь мнением',
                onTap: _rateApp,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('Выйти?'),
                    content: const Text('Вы уверены, что хотите выйти?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authNotifierProvider.notifier).signOut();
                          context.go(AppRoutes.welcome);
                        },
                        child: Text(
                          'Выйти',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🚪', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Выйти из аккаунта',
                        style: AppTypography.subheadingSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: userEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = userEvents[index];
        final imageUrl = event.coverImageUrl;

        return InkWell(
          onTap: () => context.push('/home/event/${event.id}', extra: event),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: SizedBox(
                    width: 104,
                    height: 104,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceSecondary,
                              child: const Icon(Icons.image_outlined),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceSecondary,
                            child: const Icon(Icons.event_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.address?.trim().isNotEmpty == true
                              ? event.address!
                              : 'Локация не указана',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${event.participants.length} участн.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
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
      },
    );
  }

  void _openNotificationSettings() {
    context.push(AppRoutes.settings);
  }

  void _openPrivacySettings() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Конфиденциальность'),
        content: const Text(
          'Настройки приватности доступны в экране настроек. Здесь можно быстро открыть их.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Закрыть'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(AppRoutes.settings);
            },
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse('https://play.google.com/store/search?q=HobbyHub&c=apps');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть магазин приложений.'),
        ),
      );
    }
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
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
