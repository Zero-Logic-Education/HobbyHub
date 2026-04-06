import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Расширения для удобной навигации через GoRouter
extension GoRouterExtensions on GoRouter {
  /// Навигация на главный экран
  void goHome() => go(AppRoutes.home);

  /// Навигация на экран поиска
  void goSearch() => go(AppRoutes.search);

  /// Навигация на карту
  void goMap() => push(AppRoutes.map);

  /// Навигация на экран сообществ
  void goCommunities() => go(AppRoutes.communities);

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
      push('${AppRoutes.eventDetail}/$eventId');

  /// Навигация на создание события
  void goCreateEvent() => push(AppRoutes.createEvent);

  /// Навигация на детальную страницу сообщества
  void goCommunityDetail(String communityId) {
    push('/communities/$communityId');
  }

  /// Навигация в список чатов
  void goChats() => push(AppRoutes.chats);

  /// Навигация в чат
  void goChatDetail(String chatId) => push('${AppRoutes.chats}/$chatId');

  /// Навигация к уведомлениям
  void goNotifications() => push(AppRoutes.notifications);

  /// Навигация к настройкам
  void goSettings() => push(AppRoutes.settings);
}

/// Расширения для BuildContext для удобной навигации
extension BuildContextRouterExtensions on GoRouter {
  /// Проверка, находимся ли мы на маршруте
  bool isAtRoute(String location) =>
      routerDelegate.currentConfiguration.uri.toString().startsWith(location);

  /// Получить текущий маршрут
  String get currentRoute => routerDelegate.currentConfiguration.uri.toString();
}
