import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Расширения для удобной навигации через GoRouter
extension GoRouterExtensions on GoRouter {
  /// Навигация на главный экран
  void goHome() => go(AppRoutes.home);

  /// Навигация на экран карты
  void goMap() => go(AppRoutes.map);

  /// Навигация на экран профиля
  void goProfile() => go(AppRoutes.profile);

  /// Навигация на экран редактирования профиля
  void goEditProfile() => push(AppRoutes.editProfile);

  /// Навигация на экран входа
  void goLogin() => go(AppRoutes.login);

  /// Навигация на экран регистрации
  void goRegister() => go(AppRoutes.register);

  /// Навигация на выбор интересов
  void goInterestsSelection() => go(AppRoutes.interestsSelection);

  /// Навигация на детальную страницу события
  void goEventDetail(String eventId) =>
      push('${AppRoutes.home}/event/$eventId');

  /// Навигация на создание события
  void goCreateEvent() => push('${AppRoutes.home}/create-event');

  /// Навигация на детальную страницу сообщества
  void goCommunityDetail(String communityId) {
    push('${AppRoutes.home}/communities/$communityId');
  }

  /// Навигация в чат
  void goChatDetail(String chatId) => push('${AppRoutes.home}/chats/$chatId');
}

/// Расширения для BuildContext для удобной навигации
extension BuildContextRouterExtensions on GoRouter {
  /// Проверка, находимся ли мы на маршруте
  bool isAtRoute(String location) =>
      routerDelegate.currentConfiguration.uri.toString().startsWith(location);

  /// Получить текущий маршрут
  String get currentRoute => routerDelegate.currentConfiguration.uri.toString();
}
