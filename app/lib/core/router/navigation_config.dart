// Дополнительная конфигурация Go Router для специальных случаев

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Сервис для управления навигацией из любой точки приложения
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Получить текущий context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Проверить, существует ли контекст
  static bool get hasContext => context != null;

  /// Получить текущий маршрут
  static String get currentRoute {
    return context != null
        ? GoRouter.of(context!).routeInformationProvider.value.uri.toString()
        : '/';
  }

  /// Проверить, находимся ли мы на маршруте
  static bool isOnRoute(String route) {
    return currentRoute.startsWith(route);
  }

  /// Отправить сообщение пользователю (SnackBar)
  static void showMessage(String message, {Duration duration = const Duration(seconds: 2)}) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
        ),
      );
    }
  }

  /// Показать диалог ошибки
  static Future<void> showError(String message) {
    return showDialog<void>(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Показать диалог подтверждения
  static Future<bool?> showConfirmDialog(
    String title,
    String message, {
    String confirmText = 'OK',
    String cancelText = 'Отмена',
  }) {
    return showDialog<bool>(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}

/// Модель для управления deep links
class DeepLinkHandler {
  /// Обработать deep link
  static String? handleDeepLink(Uri uri) {
    // Примеры deep links:
    // hobby_hub://event/123
    // hobby_hub://community/456
    // hobby_hub://user/789

    if (uri.scheme == 'hobby_hub') {
      final path = uri.pathSegments;

      if (path.isEmpty) {
        return AppRoutes.home;
      }

      switch (path[0]) {
        case 'event':
          if (path.length > 1) {
            return '${AppRoutes.home}/event/${path[1]}';
          }
          break;

        case 'community':
          if (path.length > 1) {
            return '${AppRoutes.home}/communities/${path[1]}';
          }
          break;

        case 'chat':
          if (path.length > 1) {
            return '${AppRoutes.home}/chats/${path[1]}';
          }
          break;

        case 'profile':
          if (path.length > 1) {
            // Для просмотра чужого профиля
            return '${AppRoutes.profile}?userId=${path[1]}';
          }
          return AppRoutes.profile;
      }
    }

    return null;
  }
}

/// Конфигурация для обработки ошибок навигации
class GoRouterErrorHandler {
  /// Получить страницу ошибки
  static Widget errorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ошибка'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Страница не найдена',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Маршрут: ${state.uri}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home),
              label: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Класс для логирования навигации (для отладки)
class NavigationLogger {
  static void logNavigation(String from, String to) {
    // Логирование навигации: from -> to
  }

  static void logError(String error) {
    // Логирование ошибки навигации
  }

  static void logDeepLink(Uri uri) {
    // Логирование deep link
  }
}

/// Расширения для работы с навигацией в виджетах
extension GoRouterExtensionsAdvanced on BuildContext {
  /// Получить текущий маршрут
  String get currentRoute {
    return GoRouter.of(this).routeInformationProvider.value.uri.toString();
  }

  /// Проверить, находимся ли на маршруте
  bool isOnRoute(String route) {
    return currentRoute.startsWith(route);
  }

  /// Проверить, есть ли возможность вернуться назад
  bool get canPopRoute => Navigator.of(this).canPop();

  /// Вернуться на предыдущий маршрут или на главный
  void popOrHome() {
    if (canPopRoute) {
      Navigator.of(this).pop();
    } else {
      go(AppRoutes.home);
    }
  }
}
