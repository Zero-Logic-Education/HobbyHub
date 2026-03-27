import 'package:firebase_analytics/firebase_analytics.dart';

/// Сервис для работы с Firebase Analytics
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Получить observer для навигации
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ==================== SCREEN TRACKING ====================

  /// Залогировать просмотр экрана
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ==================== USER PROPERTIES ====================

  /// Установить ID пользователя
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Установить свойство пользователя
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Установить возраст пользователя
  Future<void> setUserAge(int age) async {
    await setUserProperty(name: 'age_group', value: _getAgeGroup(age));
  }

  /// Установить интересы пользователя
  Future<void> setUserInterests(List<String> interests) async {
    await setUserProperty(name: 'interests', value: interests.join(','));
  }

  // ==================== EVENT TRACKING ====================

  /// Залогировать событие входа
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Залогировать событие регистрации
  Future<void> logSignUp({String? method}) async {
    await _analytics.logSignUp(signUpMethod: method ?? 'unknown');
  }

  /// Залогировать создание события
  Future<void> logCreateEvent({
    required String eventId,
    required String eventType,
    String? category,
  }) async {
    await _analytics.logEvent(
      name: 'create_event',
      parameters: {
        'event_id': eventId,
        'event_type': eventType,
        'category': ?category,
      },
    );
  }

  /// Залогировать присоединение к событию
  Future<void> logJoinEvent({
    required String eventId,
    required String eventTitle,
  }) async {
    await _analytics.logEvent(
      name: 'join_event',
      parameters: {'event_id': eventId, 'event_title': eventTitle},
    );
  }

  /// Залогировать создание сообщества
  Future<void> logCreateCommunity({
    required String communityId,
    required String communityName,
  }) async {
    await _analytics.logEvent(
      name: 'create_community',
      parameters: {
        'community_id': communityId,
        'community_name': communityName,
      },
    );
  }

  /// Залогировать присоединение к сообществу
  Future<void> logJoinCommunity({
    required String communityId,
    required String communityName,
  }) async {
    await _analytics.logEvent(
      name: 'join_community',
      parameters: {
        'community_id': communityId,
        'community_name': communityName,
      },
    );
  }

  /// Залогировать поиск
  Future<void> logSearch({required String searchTerm, String? category}) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {'category': ?category},
    );
  }

  /// Залогировать шаринг
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method ?? 'unknown',
    );
  }

  // ==================== CUSTOM EVENTS ====================

  /// Залогировать добавление в избранное
  Future<void> logAddToFavorites({
    required String itemType,
    required String itemId,
  }) async {
    await _analytics.logEvent(
      name: 'add_to_favorites',
      parameters: {'item_type': itemType, 'item_id': itemId},
    );
  }

  /// Залогировать отправку сообщения
  Future<void> logSendMessage({
    required String chatType,
    String? chatId,
  }) async {
    await _analytics.logEvent(
      name: 'send_message',
      parameters: {'chat_type': chatType, 'chat_id': ?chatId},
    );
  }

  /// Залогировать оставление отзыва
  Future<void> logSubmitReview({
    required String eventId,
    required int rating,
  }) async {
    await _analytics.logEvent(
      name: 'submit_review',
      parameters: {'event_id': eventId, 'rating': rating},
    );
  }

  // ==================== UTILS ====================

  /// Получить возрастную группу
  String _getAgeGroup(int age) {
    if (age < 18) return '12-17';
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    return '55+';
  }

  /// Залогировать пользовательское событие
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters ?? {});
  }
}
