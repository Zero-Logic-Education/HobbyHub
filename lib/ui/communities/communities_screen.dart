import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_CommunityItem> _myGroups = [
    _CommunityItem(
      name: 'Йога-сообщество',
      category: 'Здоровье',
      categoryColor: Color(0xFF27AE60),
      categoryBg: Color(0xFFE8F8EF),
      members: 234,
      lastActive: '2 ч. назад',
      notifications: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80',
    ),
    _CommunityItem(
      name: 'Техно-энтузиасты',
      category: 'Технологии',
      categoryColor: Color(0xFF2D9CDB),
      categoryBg: Color(0xFFE8F4FD),
      members: 567,
      lastActive: '5 мин. назад',
      notifications: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&q=80',
    ),
    _CommunityItem(
      name: 'Арт и керамика',
      category: 'Творчество',
      categoryColor: Color(0xFFF2994A),
      categoryBg: Color(0xFFFEF3E8),
      members: 89,
      lastActive: '1 д. назад',
      notifications: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=800&q=80',
    ),
    _CommunityItem(
      name: 'Беговой клуб',
      category: 'Спорт',
      categoryColor: Color(0xFFF17A5D),
      categoryBg: Color(0xFFFFF0ED),
      members: 412,
      lastActive: '3 ч. назад',
      notifications: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
    ),
  ];

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
                  Container(
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        ..._myGroups.map((item) => _CommunityCard(item: item)),
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
  }

  Widget _buildDiscover() {
    return const Center(child: Text('Найти сообщества'));
  }
}

class _CommunityCard extends StatelessWidget {
  final _CommunityItem item;
  const _CommunityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: Image.network(
                  item.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.surfaceSecondary,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              // Notification badge
              if (item.notifications > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.notifications}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
                ),
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
                        color: item.categoryBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: item.categoryColor,
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
                      '${item.members}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Last active
                    Text(
                      item.lastActive,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityItem {
  final String name;
  final String category;
  final Color categoryColor;
  final Color categoryBg;
  final int members;
  final String lastActive;
  final int notifications;
  final String imageUrl;

  const _CommunityItem({
    required this.name,
    required this.category,
    required this.categoryColor,
    required this.categoryBg,
    required this.members,
    required this.lastActive,
    required this.notifications,
    required this.imageUrl,
  });
}
