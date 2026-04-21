import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/category_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/community.dart';

class CommunitiesScreen extends ConsumerStatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  ConsumerState<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends ConsumerState<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  String _discoverQuery = '';
  String _selectedCategoryKey = 'all';
  final Set<String> _membershipPendingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Сообщества',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/communities/create'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.lightCoral,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: AppTypography.subheadingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppTypography.subheadingSmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.border,
                tabs: const [
                  Tab(text: 'Мои группы'),
                  Tab(text: 'Найти'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildMyGroups(), _buildDiscover()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroups() {
    final communitiesAsync = ref.watch(userCommunitiesProvider);

    return communitiesAsync.when(
      data: (communities) {
        if (communities.isEmpty) {
          return const Center(child: Text('У вас пока нет групп'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: communities.length + 1,
          itemBuilder: (context, index) {
            if (index == communities.length) {
              return GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Найти\nсообщества',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _CompactCommunityCard(item: communities[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Ошибка загрузки сообществ: $err')),
    );
  }

  Widget _buildDiscover() {
    final allCommunitiesAsync = ref.watch(allCommunitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return allCommunitiesAsync.when(
      data: (communities) {
        const defaultCategoryKeys = <String>{
          'sports',
          'tech',
          'arts',
          'music',
          'health',
          'gaming',
          'cooking',
          'travel',
          'other',
        };

        final categoryKeys = <String>{
          ...defaultCategoryKeys,
          for (final community in communities)
            ...community.categories.map(normalizeCategoryKey),
        };
        final sortedCategoryKeys = categoryKeys.toList()
          ..sort(
            (a, b) => getCategoryDisplayLabelByKey(
              a,
            ).compareTo(getCategoryDisplayLabelByKey(b)),
          );

        final query = _discoverQuery.trim().toLowerCase();
        final filtered = communities.where((community) {
          final matchesQuery =
              query.isEmpty ||
              community.name.toLowerCase().contains(query) ||
              community.description.toLowerCase().contains(query);
          final matchesCategory =
              _selectedCategoryKey == 'all' ||
              community.categories.any(
                (category) =>
                    normalizeCategoryKey(category) == _selectedCategoryKey,
              );

          return matchesQuery && matchesCategory;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _discoverQuery = value;
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Поиск сообществ',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:const BorderSide(color: AppColors.primary, width: 1.4),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryKey,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'all',
                            child: Text('Все категории'),
                          ),
                          ...sortedCategoryKeys.map(
                            (key) => DropdownMenuItem<String>(
                              value: key,
                              child: Text(getCategoryDisplayLabelByKey(key)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCategoryKey = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Сообщества не найдены',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isMember =
                            currentUserId != null &&
                            item.members.contains(currentUserId);
                        final isPending = _membershipPendingIds.contains(item.id);

                        return _CompactCommunityCard(
                          item: item,
                          showJoinButton: true,
                          isMember: isMember,
                          isPending: isPending,
                          onJoinTap: () => _toggleMembership(item, isMember),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Ошибка загрузки сообществ: $err'),
        ),
      ),
    );
  }

  Future<void> _toggleMembership(Community item, bool isMember) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Войдите в аккаунт, чтобы вступать в группы.'),
        ),
      );
      return;
    }

    setState(() {
      _membershipPendingIds.add(item.id);
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      if (isMember) {
        await firestoreService.leaveCommunity(item.id, userId);
      } else {
        await firestoreService.joinCommunity(item.id, userId);
      }

      ref.invalidate(allCommunitiesProvider);
      ref.invalidate(userCommunitiesProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось обновить участие в сообществе. Попробуйте позже.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _membershipPendingIds.remove(item.id);
        });
      }
    }
  }
}

class _CompactCommunityCard extends StatelessWidget {
  final Community item;
  final bool showJoinButton;
  final bool isMember;
  final bool isPending;
  final VoidCallback? onJoinTap;

  const _CompactCommunityCard({
    required this.item,
    this.showJoinButton = false,
    this.isMember = false,
    this.isPending = false,
    this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = item.categories.isNotEmpty
        ? item.categories.first
        : 'Разное';
    final categoryColor = getCategoryColor(category);
    final membersCount = item.members.length;

    return GestureDetector(
      onTap: () => context.push('/communities/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildCover(item, categoryColor),
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$membersCount',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (showJoinButton)
                        GestureDetector(
                          onTap: isPending ? null : onJoinTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isMember
                                  ? AppColors.surfaceSecondary
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isPending
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isMember
                                          ? AppColors.primary
                                          : Colors.white,
                                    ),
                                  )
                                : Text(
                                    isMember ? 'В группе' : 'Вступить',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isMember
                                          ? AppColors.textSecondary
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
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

  Widget _buildCover(Community item, Color categoryColor) {
    final imageUrl = item.coverImageUrl;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackCover(item, categoryColor),
      );
    }
    return _buildFallbackCover(item, categoryColor);
  }

  Widget _buildFallbackCover(Community item, Color categoryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: 0.2),
            categoryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.groups_rounded,
          color: categoryColor,
          size: 48,
        ),
      ),
    );
  }
}
