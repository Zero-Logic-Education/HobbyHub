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
                      child: Icon(
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ...communities.map((item) => _CommunityCard(item: item)),
            const SizedBox(height: 8),
            // Discover More Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () => _tabController.animateTo(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Найти больше сообществ',
                      style: AppTypography.subheadingSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        final categoryKeys = <String>{
          for (final community in communities)
            ...community.categories.map(normalizeCategoryKey),
        }..remove('other');
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

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.4),
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
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Сообщества не найдены. Попробуйте изменить фильтры.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...filtered.map((item) {
                final isMember =
                    currentUserId != null && item.members.contains(currentUserId);
                final isPending = _membershipPendingIds.contains(item.id);

                return _CommunityCard(
                  item: item,
                  showDescription: true,
                  action: SizedBox(
                    height: 34,
                    child: FilledButton(
                      onPressed: isPending
                          ? null
                          : () => _toggleMembership(item, isMember),
                      style: FilledButton.styleFrom(
                        backgroundColor: isMember
                            ? AppColors.surfaceSecondary
                            : AppColors.primary,
                        foregroundColor: isMember
                            ? AppColors.textSecondary
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isPending
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isMember
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            )
                          : Text(isMember ? 'В группе' : 'Вступить'),
                    ),
                  ),
                );
              }),
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
        const SnackBar(content: Text('Войдите в аккаунт, чтобы вступать в группы.')),
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
          content: Text('Не удалось обновить участие в сообществе. Попробуйте позже.'),
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

class _CommunityCard extends StatelessWidget {
  final Community item;
  final Widget? action;
  final bool showDescription;

  const _CommunityCard({
    required this.item,
    this.action,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dynamic colors based on the first category
    final category = item.categories.isNotEmpty
        ? item.categories.first
        : 'Разное';
    final categoryColor = getCategoryColor(category);
    final categoryBg = categoryColor.withValues(alpha: 0.1);
    final membersCount = item.members.length;

    return GestureDetector(
      onTap: () => context.push('/communities/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: _buildCover(item),
                ),
              ],
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.subheadingLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showDescription) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getCategoryDisplayLabel(category),
                          style: AppTypography.bodySmall.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Members
                      Icon(
                        Icons.people_outline_rounded,
                        size: 16,
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
                      if (action != null) ...[
                        const SizedBox(width: 10),
                        action!,
                      ],
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

  Widget _buildCover(Community item) {
    final imageUrl = item.coverImageUrl;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackCover(item),
      );
    }
    return _buildFallbackCover(item);
  }

  Widget _buildFallbackCover(Community item) {
    final category = item.categories.isNotEmpty ? item.categories.first : 'Разное';
    final color = getCategoryColor(category);
    final trimmedName = item.name.trim();
    final firstLetter = trimmedName.isEmpty ? 'C' : trimmedName[0].toUpperCase();

    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: AppTypography.headingLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
