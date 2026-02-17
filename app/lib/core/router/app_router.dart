import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/welcome/splash_screen.dart';
import '../../ui/welcome/welcome_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/auth/age_verification_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/register_screen.dart';
import '../../ui/auth/interests_screen.dart';
import '../../ui/main_shell/main_shell.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Определение именованных маршрутов
abstract class AppRoutes {
  // Приветственные экраны
  static const String splash = '/';
  static const String welcome = '/welcome';

  // Аутентификация
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String interestsSelection = '/auth/interests-selection';
  static const String ageVerification = '/auth/age-verification';

  // Основные экраны
  static const String home = '/home';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // События
  static const String eventDetail = '/event/:id';
  static const String createEvent = '/create-event';

  // Сообщества
  static const String communities = '/communities';
  static const String communityDetail = '/community/:id';

  // Чаты
  static const String chats = '/chats';
  static const String chatDetail = '/chat/:id';
}

/// Провайдер для отслеживания состояния маршрутизации
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userState = ref.watch(currentUserStreamProvider);
  final isAgeVerified = ref.watch(isAgeVerifiedProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggingIn = state.uri.toString().startsWith('/auth');
      final isAgeVerification = state.uri.toString().startsWith(
        AppRoutes.ageVerification,
      );

      return authState.when(
        data: (user) {
          if (user != null && userState.isLoading) {
            return null;
          }

          if (user != null && !isAgeVerified && !isAgeVerification) {
            return AppRoutes.ageVerification;
          }

          // Если пользователь вошел и пытается перейти на страницу авторизации
          if (user != null && isLoggingIn) {
            return AppRoutes.home;
          }
          // Если пользователь не вошел и пытается перейти на защищённую страницу
          if (user == null && !isLoggingIn) {
            return AppRoutes.auth;
          }
          return null;
        },
        loading: () => AppRoutes.auth,
        error: (error, stack) => AppRoutes.auth,
      );
    },
    routes: [
      // Приветственные экраны
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Маршруты аутентификации
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Аутентификация')),
          body: const Center(child: Text('Auth Screen')),
        ),
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
        ],
      ),

      // Главный экран с нижней навигацией
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // События
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
          GoRoute(
            path: 'create-event',
            name: 'create-event',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Создать событие')),
              body: const Center(child: Text('Create Event')),
            ),
          ),

          // Сообщества
          GoRoute(
            path: 'communities',
            name: 'communities',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Сообщества')),
              body: const Center(child: Text('Communities')),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'community-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return Scaffold(
                    appBar: AppBar(title: const Text('Сообщество')),
                    body: Center(child: Text('Community Detail: $id')),
                  );
                },
              ),
            ],
          ),

          // Чаты
          GoRoute(
            path: 'chats',
            name: 'chats',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Чаты')),
              body: const Center(child: Text('Chats')),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'chat-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return Scaffold(
                    appBar: AppBar(title: const Text('Чат')),
                    body: Center(child: Text('Chat Detail: $id')),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Карта
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Карта')),
          body: const Center(child: Text('Map Screen')),
        ),
      ),

      // Профиль
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Профиль')),
          body: const Center(child: Text('Profile Screen')),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-profile',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Редактирование профиля')),
              body: const Center(child: Text('Edit Profile Screen')),
            ),
          ),
        ],
      ),
    ],

    // Обработка ошибок навигации
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

    // Логирование для отладки
    debugLogDiagnostics: true,
  );
});
