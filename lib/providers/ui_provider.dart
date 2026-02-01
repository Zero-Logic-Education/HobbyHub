import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum для основных экранов приложения
enum AppRoute {
  splash,
  onboarding,
  auth,
  home,
  events,
  map,
  communities,
  chat,
  profile,
  settings,
  unknown,
}

/// State notifier для управления навигацией
class NavigationNotifier extends StateNotifier<AppRoute> {
  NavigationNotifier() : super(AppRoute.splash);

  void navigateTo(AppRoute route) {
    state = route;
  }

  void goBack() {
    // Логика для возврата на предыдущий экран
    // Это может быть более сложным, в зависимости от реализации
  }
}

/// Провайдер для управления навигацией
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, AppRoute>((ref) {
  return NavigationNotifier();
});

/// State notifier для управления видимостью loading индикатора
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool isLoading) {
    state = isLoading;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

/// Провайдер для loading состояния
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

/// Enum для toast сообщений
enum ToastType {
  success,
  error,
  info,
  warning,
}

/// Класс для toast сообщения
class ToastMessage {
  final String message;
  final ToastType type;
  final Duration duration;

  ToastMessage({
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 3),
  });
}

/// State notifier для управления toast сообщениями
class ToastNotifier extends StateNotifier<ToastMessage?> {
  ToastNotifier() : super(null);

  void show(String message,
      {ToastType type = ToastType.info,
      Duration duration = const Duration(seconds: 3)}) {
    state = ToastMessage(message: message, type: type, duration: duration);

    Future.delayed(duration, () {
      if (state?.message == message) {
        state = null;
      }
    });
  }

  void showSuccess(String message) {
    show(message, type: ToastType.success);
  }

  void showError(String message) {
    show(message, type: ToastType.error);
  }

  void showInfo(String message) {
    show(message, type: ToastType.info);
  }

  void showWarning(String message) {
    show(message, type: ToastType.warning);
  }

  void clear() {
    state = null;
  }
}

/// Провайдер для управления toast сообщениями
final toastProvider = StateNotifierProvider<ToastNotifier, ToastMessage?>((ref) {
  return ToastNotifier();
});

/// State notifier для управления темой приложения
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light, true = dark

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

/// Провайдер для управления темой
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

/// State notifier для управления состоянием фильтрации
class FilterVisibilityNotifier extends StateNotifier<bool> {
  FilterVisibilityNotifier() : super(false);

  void toggleFilters() {
    state = !state;
  }

  void showFilters() {
    state = true;
  }

  void hideFilters() {
    state = false;
  }
}

/// Провайдер для видимости фильтров
final filterVisibilityProvider =
    StateNotifierProvider<FilterVisibilityNotifier, bool>((ref) {
  return FilterVisibilityNotifier();
});
