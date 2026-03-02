import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: authState.when(
        data: (firebaseUser) {
          if (firebaseUser == null) {
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
                  Text(
                    'Вы не авторизованы',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Войдите, чтобы увидеть свой профиль',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Используем данные из Firestore если есть, иначе из Firebase Auth
          final firestoreUser = currentUser.value;
          final displayName = firestoreUser?.displayName ?? 
                             firebaseUser.displayName ?? 
                             'Пользователь';
          final email = firestoreUser?.email ?? 
                       firebaseUser.email ?? 
                       '';
          final photoUrl = firestoreUser?.photoUrl ?? 
                          firebaseUser.photoURL;
          final interests = firestoreUser?.interests ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Avatar and user info
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : email.isNotEmpty 
                                  ? email[0].toUpperCase() 
                                  : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: AppTypography.headingLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Интересы',
                        value: interests.length.toString(),
                      ),
                      _StatItem(
                        label: 'События',
                        value: '0',
                      ),
                      _StatItem(
                        label: 'Друзья',
                        value: '0',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Menu items
                _MenuItem(
                  icon: Icons.favorite_border,
                  title: 'Мои интересы',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.event,
                  title: 'Мои события',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.people_outline,
                  title: 'Друзья',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: 'Конфиденциальность',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Помощь',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Выйти из аккаунта?'),
                            content: const Text(
                              'Вы уверены, что хотите выйти?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .signOut();
                                },
                                child: const Text(
                                  'Выйти',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Выйти из аккаунта'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
