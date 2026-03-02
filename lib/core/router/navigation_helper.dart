import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Вспомогательный класс для навигации в приложении
class NavigationHelper {
  /// Переход на главный экран
  static void goHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  /// Переход на экран с поиском
  static void goMap(BuildContext context) {
    context.go(AppRoutes.search);
  }

  // Переход на экран  сообщества
  static void goCommunities(BuildContext context) {
    context.go(AppRoutes.communities);
  }

  /// Переход на профиль
  static void goProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }

  /// Переход на редактирование профиля
  static void goEditProfile(BuildContext context) {
    context.push(AppRoutes.editProfile);
  }

  /// Возврат на предыдущий экран
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goHome(context);
    }
  }

  /// Переход на login экран
  static void goLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  /// Переход на register экран
  static void goRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }

  /// Переход на выбор интересов
  static void goInterestsSelection(BuildContext context) {
    context.go(AppRoutes.interestsSelection);
  }

  /// Переход на детальную страницу события
  static void goEventDetail(BuildContext context, String eventId) {
    context.push('${AppRoutes.home}/event/$eventId');
  }

  /// Переход на создание события
  static void goCreateEvent(BuildContext context) {
    context.push('${AppRoutes.home}/create-event');
  }

  /// Переход на детальную страницу сообщества
  static void goCommunityDetail(BuildContext context, String communityId) {
    context.push('${AppRoutes.home}/communities/$communityId');
  }

  /// Переход на список чатов
  static void goChats(BuildContext context) {
    context.push('${AppRoutes.home}/chats');
  }

  /// Переход в конкретный чат
  static void goChatDetail(BuildContext context, String chatId) {
    context.push('${AppRoutes.home}/chats/$chatId');
  }

  /// Замена всех маршрутов на новый (используется при выходе)
  static void replaceRoute(BuildContext context, String route) {
    context.go(route);
  }

  /// Проверить, находимся ли на маршруте
  static bool isAtRoute(BuildContext context, String location) {
    final currentLocation = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.toString();
    return currentLocation.startsWith(location);
  }
}
