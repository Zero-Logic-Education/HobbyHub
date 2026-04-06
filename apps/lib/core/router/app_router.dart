import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/welcome/splash_screen.dart';
import '../../ui/welcome/welcome_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/home/event_detail_screen.dart';
import '../../ui/home/map_screen.dart';
import '../../ui/home/moderation/event_moderation_screen.dart';
import '../../ui/home/reviews/event_review_screen.dart';
import '../../ui/home/reviews/event_reviews_list_screen.dart';
import '../../ui/auth/age_verification_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/register_screen.dart';
import '../../ui/auth/register_password_screen.dart';
import '../../ui/auth/interests_screen.dart';
import '../../ui/onboarding/location_screen.dart';
import '../../ui/onboarding/parental_consent_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/main_shell/main_shell.dart';
import '../../ui/search/search_screen.dart';
import '../../ui/create/create_event_screen.dart';
import '../../ui/communities/communities_screen.dart';
import '../../ui/communities/create/create_community_screen.dart';
import '../../ui/communities/detail/community_detail_screen.dart';
import '../../ui/chat/chat_list_screen.dart';
import '../../ui/chat/chat_screen.dart';
import '../../ui/notifications/notifications_screen.dart';
import '../../ui/profile/settings/settings_screen.dart';
import '../../ui/profile/edit/edit_profile_screen.dart';
import '../../models/event.dart';
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
  static const String search = '/search';
  static const String createEvent = '/create';
  static const String eventDetail = '/home/event';
  static const String communities = '/communities';
  static const String createCommunity = '/communities/create';
  static const String communityDetail = '/communities/detail';

  static const String chats = '/chats';
  static const String notifications = '/notifications';
  static const String map = '/map';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String eventModeration = '/events/moderation';
  static const String eventReview = '/events/review';
  static const String eventReviews = '/events/reviews';
}

/// Провайдер GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Редиректы в зависимости от состояния авторизации
    redirect: (context, state) {
      // Проверяем состояние авторизации
      final isLoggedIn =
          authState.whenOrNull(data: (user) => user != null) ?? false;

      final currentPath = state.uri.path;

      // Пути, доступные без авторизации
      final isAuthPath =
          currentPath.startsWith('/auth') ||
          currentPath == AppRoutes.welcome ||
          currentPath == AppRoutes.splash;

      // Если загружается, не редиректим (пока ждем ответа от Firebase)
      if (authState.isLoading && currentPath == AppRoutes.splash) {
        return null;
      }

      // Если НЕ авторизован и пытается попасть на защищенные страницы
      if (!isLoggedIn && !isAuthPath) {
        return AppRoutes.welcome;
      }

      // Если авторизован — редиректим на home ТОЛЬКО с welcome/login/auth-корня.
      // Онбординг (age, interests, register, parental, location) проходит уже
      // после создания аккаунта, поэтому не мешаем этим путям.
      final isRootAuthPath =
          currentPath == AppRoutes.welcome ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.auth;

      if (isLoggedIn && isRootAuthPath && currentPath != AppRoutes.splash) {
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
        builder: (context, state) => const WelcomeScreen(),
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
            routes: [
              GoRoute(
                path: 'password',
                name: 'register-password',
                builder: (context, state) {
                  final data = state.extra as Map<String, dynamic>? ?? {};
                  return RegisterPasswordScreen(userData: data);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'age-verification',
            name: 'age-verification',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return AgeVerificationScreen(userData: data);
            },
          ),
          GoRoute(
            path: 'interests-selection',
            name: 'interests-selection',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return InterestsScreen(userData: data);
            },
          ),
          GoRoute(
            path: 'location',
            name: 'location',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: 'parental-consent',
            name: 'parental-consent',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return ParentalConsentScreen(userData: data);
            },
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
              ),
            ],
          ),
          // Вкладка: Поиск
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Вкладка: Создать
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.createEvent,
                name: 'create-event',
                builder: (context, state) => const CreateEventScreen(),
              ),
            ],
          ),
          // Вкладка: Сообщества
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.communities,
                name: 'communities',
                builder: (context, state) => const CommunitiesScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create-community',
                    builder: (context, state) => const CreateCommunityScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'community-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CommunityDetailScreen(communityId: id);
                    },
                  ),
                ],
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
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '${AppRoutes.eventDetail}/:id',
        name: 'event-detail',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          final event = state.extra as Event?;
          return EventDetailScreen(eventId: eventId, event: event);
        },
      ),
      GoRoute(
        path: '/events/:id/moderation',
        name: 'event-moderation',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventModerationScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/events/:id/review',
        name: 'event-review',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventReviewScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/events/:id/reviews',
        name: 'event-reviews',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventReviewsListScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.chats,
        name: 'chats',
        builder: (context, state) => const ChatListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'chat-detail',
            builder: (context, state) {
              final chatId = state.pathParameters['id']!;
              final otherUserId = state.extra as String?;
              return ChatScreen(chatId: chatId, otherUserId: otherUserId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) {
          final initialEvent = state.extra as Event?;
          return MapScreen(initialEvent: initialEvent);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
