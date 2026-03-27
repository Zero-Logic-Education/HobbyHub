import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Настройки', style: AppTypography.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Уведомления'),
          _buildSwitchTile(
            title: 'События',
            subtitle: 'Уведомления о новых событиях и откликах',
            value: _pushEvents,
            onChanged: (val) {
              setState(() => _pushEvents = val);
            },
          ),
          _buildSwitchTile(
            title: 'Сообщества',
            subtitle: 'Уведомления из ваших сообществ',
            value: _pushCommunities,
            onChanged: (val) {
              setState(() => _pushCommunities = val);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Приватность'),
          _buildSwitchTile(
            title: 'Закрытый профиль',
            subtitle: 'Скрыть профиль от пользователей вне ваших сообществ',
            value: _isPrivateAccount,
            onChanged: (val) {
              setState(() => _isPrivateAccount = val);
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
                Navigator.of(context).pop(); // Go back from settings
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Выйти из аккаунта',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: AppTypography.headingSmall.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
    );
  }
}
