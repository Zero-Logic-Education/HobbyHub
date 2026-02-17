import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/welcome/splash_screen.dart';
import '../../ui/welcome/welcome_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/auth/age_verification_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/register_screen.dart';
import '../../ui/auth/interests_screen.dart';
import '../../ui/onboarding/location_screen.dart';
import '../../ui/onboarding/parental_consent_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/main_shell/main_shell.dart';
import '../../providers/auth_provider.dart';

/// Константы путей маршрутов
class AppRoutes {
  // Приветствие и Аутентификация
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String interestsSelection = '/auth/interests-selection';
  static const String ageVerification = '/auth/age-verification';
  static const String locationPermission = '/auth/location';
  static const String parentalConsent = '/auth/parental-consent';
  static const String auth = '/auth';

  // Основные экраны
  static const String home = '/home';
  static const String map = '/map';
  static const String communities = '/communities';
  static const String chats = '/chats';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}

/// Провайдер GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Редиректы в зависимости от состояния авторизации
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthPath =
          state.uri.path.startsWith('/auth') ||
          state.uri.path == AppRoutes.welcome ||
          state.uri.path == AppRoutes.splash;

      if (!isLoggedIn && !isAuthPath) {
        return AppRoutes.welcome;
      }

      if (isLoggedIn && isAuthPath && state.uri.path != AppRoutes.splash) {
        // Если залогинен и пытается зайти на Login/Welcome - на Home
        // Но Splash пропускаем, чтобы он сам перенаправил
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Группа аутентификации и онбординга
      GoRoute(
        path: '/auth',
        builder: (context, state) => const WelcomeScreen(), // Заглушка
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'age-verification',
            name: 'age-verification',
            builder: (context, state) => const AgeVerificationScreen(),
          ),
          GoRoute(
            path: 'interests-selection',
            name: 'interests-selection',
            builder: (context, state) => const InterestsScreen(),
          ),
          GoRoute(
            path: 'location',
            name: 'location',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: 'parental-consent',
            name: 'parental-consent',
            builder: (context, state) => const ParentalConsentScreen(),
          ),
        ],
      ),

      // Основная оболочка с нижней навигацией
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Вкладка: Главная
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'event/:id',
                    name: 'event-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id'];
                      return Scaffold(
                        appBar: AppBar(title: const Text('Событие')),
                        body: Center(child: Text('Event Detail: $id')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Вкладка: Карта
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                name: 'map',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Карта')),
                  body: const Center(child: Text('Map Screen')),
                ),
              ),
            ],
          ),
          // Вкладка: Создать
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Создать')),
                  body: const Center(child: Text('Create Page')),
                ),
              ),
            ],
          ),
          // Вкладка: Сообщества
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.communities,
                name: 'communities',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Сообщества')),
                  body: const Center(child: Text('Communities')),
                ),
              ),
            ],
          ),
          // Вкладка: Профиль
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit-profile',
                    builder: (context, state) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Редактирование профиля'),
                      ),
                      body: const Center(child: Text('Edit Profile Screen')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Страница не найдена'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
});
