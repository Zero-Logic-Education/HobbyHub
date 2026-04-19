import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Сервис для работы с Firebase Cloud Messaging (Push-уведомления)
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  /// Инициализация FCM
  Future<void> initialize() async {
    // Запрос разрешений на уведомления
    await requestPermission();

    // Получить FCM токен
    final token = await getToken();
    debugPrint('FCM Token: $token');

    // Слушаем foreground сообщения
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Слушаем клики по уведомлениям
    _openedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Проверяем, было ли приложение открыто из уведомления
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Освобождение ресурсов
  void dispose() {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
  }

  /// Запросить разрешение на уведомления
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Получить FCM токен устройства
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Удалить FCM токен
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  /// Подписаться на топик
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Отписаться от топика
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Обработка foreground сообщений
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground сообщение: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }

  /// Обработка клика по уведомлению
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      'Пользователь кликнул на уведомление: ${message.notification?.title}',
    );
    debugPrint('Data: ${message.data}');

    final data = message.data;

    if (data.containsKey('eventId')) {
      // Перейти на экран события
      // navigatorKey.currentState?.pushNamed('/event', arguments: data['eventId']);
    } else if (data.containsKey('communityId')) {
      // Перейти на экран сообщества
      // navigatorKey.currentState?.pushNamed('/community', arguments: data['communityId']);
    }
  }

  /// Настройка foreground presentation опций (iOS)
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  // ==================== TOPIC SUBSCRIPTIONS ====================

  /// Подписаться на уведомления о событиях
  Future<void> subscribeToEvents() async {
    await subscribeToTopic('events');
  }

  /// Подписаться на уведомления о сообществах
  Future<void> subscribeToCommunities() async {
    await subscribeToTopic('communities');
  }

  /// Подписаться на уведомления по категории
  Future<void> subscribeToCategory(String category) async {
    await subscribeToTopic('category_$category');
  }

  /// Отписаться от всех уведомлений
  Future<void> unsubscribeFromAll() async {
    await unsubscribeFromTopic('events');
    await unsubscribeFromTopic('communities');
    // Отписка от категорий происходит индивидуально
  }
}

/// Background message handler (должен быть top-level функцией)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background сообщение: ${message.notification?.title}');
}
