import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEvents = true;
  bool _pushCommunities = true;
  bool _isPrivateAccount = false;

  Future<void> _openNotificationPreferences() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Уведомления',
                      style: AppTypography.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('События'),
                      subtitle: const Text('Новые события и отклики'),
                      value: _pushEvents,
                      onChanged: (value) {
                        setState(() => _pushEvents = value);
                        setModalState(() {});
                      },
                      activeTrackColor: AppColors.primary,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Сообщества'),
                      subtitle: const Text('Обновления ваших сообществ'),
                      value: _pushCommunities,
                      onChanged: (value) {
                        setState(() => _pushCommunities = value);
                        setModalState(() {});
                      },
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPrivacyPreferences() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Конфиденциальность',
                      style: AppTypography.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Закрытый профиль'),
                      subtitle: const Text(
                        'Скрыть профиль от пользователей вне ваших сообществ',
                      ),
                      value: _isPrivateAccount,
                      onChanged: (value) {
                        setState(() => _isPrivateAccount = value);
                        setModalState(() {});
                      },
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _rateApp() async {
    final uri = Uri.parse(
      'https://play.google.com/store/search?q=HobbyHub&c=apps',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть магазин приложений.')),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выйти?'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(authNotifierProvider.notifier).signOut();
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: [
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            iconBg: const Color(0xFFFFF5E0),
            iconColor: const Color(0xFFFF6B35),
            title: 'Уведомления',
            subtitle: 'Push и email-рассылки',
            onTap: _openNotificationPreferences,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.lock_outline_rounded,
            iconBg: const Color(0xFFE8F4FD),
            iconColor: const Color(0xFF2D9CDB),
            title: 'Конфиденциальность',
            subtitle: 'Защита аккаунта',
            onTap: _openPrivacyPreferences,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            iconBg: const Color(0xFFE8F8EF),
            iconColor: const Color(0xFF27AE60),
            title: 'Язык',
            subtitle: 'Русский',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'ДОПОЛНИТЕЛЬНО',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.star_outline_rounded,
            iconBg: const Color(0xFFFFFBE6),
            iconColor: const Color(0xFFE8B86D),
            title: 'Оценить приложение',
            subtitle: 'Поделитесь мнением',
            onTap: _rateApp,
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF9B51E0),
            title: 'Помощь и поддержка',
            subtitle: 'FAQ и контакты',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconBg: const Color(0xFFE8F4FD),
            iconColor: const Color(0xFF2D9CDB),
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconBg: const Color(0xFFFFECE8),
            iconColor: const Color(0xFFEB5757),
            title: 'Выйти из аккаунта',
            subtitle: 'Завершить текущую сессию',
            onTap: _confirmSignOut,
            titleColor: const Color(0xFFEB5757),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
