import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Сервис для работы с Cloud Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER CRUD ====================

  /// Создать пользователя
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(userData);
  }

  /// Получить пользователя по ID
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
  }

  /// Обновить пользователя
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(userData);
  }

  /// Удалить пользователя
  Future<void> deleteUser(String uid) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
  }

  /// Stream пользователя
  Stream<DocumentSnapshot> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots();
  }

  // ==================== EVENT CRUD ====================

  /// Создать событие
  Future<DocumentReference> createEvent(Map<String, dynamic> eventData) async {
    return await _firestore
        .collection(AppConstants.eventsCollection)
        .add(eventData);
  }

  /// Получить событие по ID
  Future<DocumentSnapshot> getEvent(String eventId) async {
    return await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .get();
  }

  /// Обновить событие
  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .update(eventData);
  }

  /// Удалить событие
  Future<void> deleteEvent(String eventId) async {
    await _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId)
        .delete();
  }

  /// Выполнить транзакцию для события (для атомарных операций)
  Future<void> runEventTransaction(
    String eventId,
    Map<String, dynamic> Function(Map<String, dynamic>) updateFunction,
  ) async {
    final eventRef = _firestore
        .collection(AppConstants.eventsCollection)
        .doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final eventDoc = await transaction.get(eventRef);

      if (!eventDoc.exists) {
        throw Exception('Событие не найдено');
      }

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final updates = updateFunction(eventData);

      transaction.update(eventRef, updates);
    });
  }

  /// Получить список событий с пагинацией
  Future<QuerySnapshot> getEvents({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(AppConstants.eventsCollection)
        .where('visibility', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  /// Stream событий
  Stream<QuerySnapshot> eventsStream({int limit = 20}) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('visibility', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Stream событий пользователя (где он участник)
  Stream<QuerySnapshot> userEventsStream(String userId) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Поиск событий по категориям
  Future<QuerySnapshot> searchEventsByCategories(
    List<String> categories,
  ) async {
    return await _firestore
        .collection(AppConstants.eventsCollection)
        .where('visibility', isEqualTo: 'public')
        .where('categories', arrayContainsAny: categories)
        .where('startTime', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('startTime')
        .limit(20)
        .get();
  }

  // ==================== COMMUNITY CRUD ====================

  /// Создать сообщество
  Future<DocumentReference> createCommunity(
    Map<String, dynamic> communityData,
  ) async {
    return await _firestore
        .collection(AppConstants.communitiesCollection)
        .add(communityData);
  }

  /// Получить сообщество по ID
  Future<DocumentSnapshot> getCommunity(String communityId) async {
    return await _firestore
        .collection(AppConstants.communitiesCollection)
        .doc(communityId)
        .get();
  }

  /// Обновить сообщество
  Future<void> updateCommunity(
    String communityId,
    Map<String, dynamic> communityData,
  ) async {
    await _firestore
        .collection(AppConstants.communitiesCollection)
        .doc(communityId)
        .update(communityData);
  }

  /// Получить список сообществ
  Future<QuerySnapshot> getCommunities({int limit = 20}) async {
    return await _firestore
        .collection(AppConstants.communitiesCollection)
        .where('privacyLevel', isEqualTo: 'public')
        .orderBy('name')
        .limit(limit)
        .get();
  }

  /// Stream сообществ пользователя
  Stream<QuerySnapshot> userCommunitiesStream(String userId) {
    return _firestore
        .collection(AppConstants.communitiesCollection)
        .where('members', arrayContains: userId)
        .snapshots();
  }

  // ==================== INTEREST CRUD ====================

  /// Получить все интересы
  Future<QuerySnapshot> getInterests() async {
    return await _firestore
        .collection(AppConstants.interestsCollection)
        .orderBy('name')
        .get();
  }

  /// Получить интересы по категории
  Future<QuerySnapshot> getInterestsByCategory(String category) async {
    return await _firestore
        .collection(AppConstants.interestsCollection)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .get();
  }

  /// Stream популярных интересов
  Stream<QuerySnapshot> popularInterestsStream({int limit = 10}) {
    return _firestore
        .collection(AppConstants.interestsCollection)
        .orderBy('popularity', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch операции для множественных обновлений
  WriteBatch getBatch() {
    return _firestore.batch();
  }

  /// Transaction для атомарных операций
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) {
    return _firestore.runTransaction(transactionHandler);
  }

  /// Присоединиться к сообществу
  Future<void> joinCommunity(String communityId, String userId) async {
    await _firestore
        .collection(AppConstants.communitiesCollection)
        .doc(communityId)
        .update({
          'members': FieldValue.arrayUnion([userId]),
        });
  }

  /// Покинуть сообщество
  Future<void> leaveCommunity(String communityId, String userId) async {
    await _firestore
        .collection(AppConstants.communitiesCollection)
        .doc(communityId)
        .update({
          'members': FieldValue.arrayRemove([userId]),
        });
  }

  /// Получить стрим сообщества
  Stream<DocumentSnapshot> getCommunityStream(String communityId) {
    return _firestore
        .collection(AppConstants.communitiesCollection)
        .doc(communityId)
        .snapshots();
  }

  /// Stream событий сообщества
  Stream<QuerySnapshot> communityEventsStream(
    String communityId, {
    int limit = 20,
  }) {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('visibility', isEqualTo: 'public')
        .where('communityId', isEqualTo: communityId)
        .orderBy('startTime', descending: false)
        .limit(limit)
        .snapshots();
  }

  // ==================== REVIEWS ====================
  Future<void> submitEventReview({
    required String eventId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    final reviewRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('reviews')
        .doc(userId);

    final eventRef = _firestore.collection('events').doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final eventDoc = await transaction.get(eventRef);
      if (!eventDoc.exists) {
        throw Exception('Event not found');
      }

      final reviewData = {
        'authorId': userId,
        'userId': userId, // Оставляем для совместимости, если где-то используется
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      transaction.set(reviewRef, reviewData, SetOptions(merge: true));
    });
  }

  Stream<QuerySnapshot> getEventReviewsStream(
    String eventId, {
    String sort = 'newest',
  }) {
    final reviewsRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('reviews');

    switch (sort) {
      case 'highest':
        return reviewsRef.orderBy('rating', descending: true).snapshots();
      case 'lowest':
        return reviewsRef.orderBy('rating').snapshots();
      case 'newest':
      default:
        return reviewsRef.orderBy('createdAt', descending: true).snapshots();
    }
  }

  // ==================== EVENT APPLICATIONS ====================

  /// Получить стрим заявок на событие
  Stream<QuerySnapshot> getEventApplications(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Одобрить заявку
  Future<void> approveApplication(String eventId, String userId, String currentUserId) async {
    // Проверка прав: только организатор может одобрять заявки
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) {
      throw Exception('Событие не найдено');
    }

    final eventData = eventDoc.data() as Map<String, dynamic>;
    if (eventData['organizerId'] != currentUserId) {
      throw Exception('У вас нет прав на модерацию заявок этого события');
    }

    final batch = _firestore.batch();

    final appRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId);
    batch.update(appRef, {'status': 'approved'});

    final eventRef = _firestore.collection('events').doc(eventId);
    batch.update(eventRef, {
      'participants': FieldValue.arrayUnion([userId])
    });

    await batch.commit();
  }

  /// Отклонить заявку
  Future<void> rejectApplication(String eventId, String userId, String currentUserId) async {
    // Проверка прав: только организатор может отклонять заявки
    final eventDoc = await _firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) {
      throw Exception('Событие не найдено');
    }

    final eventData = eventDoc.data() as Map<String, dynamic>;
    if (eventData['organizerId'] != currentUserId) {
      throw Exception('У вас нет прав на модерацию заявок этого события');
    }

    final appRef = _firestore
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .doc(userId);
    
    await appRef.update({'status': 'rejected'});
  }

  // ==================== NOTIFICATIONS ====================

  /// Получить уведомления пользователя
  Stream<QuerySnapshot> getUserNotifications(String userId, {int limit = 50}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Отметить уведомление как прочитанное
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Сохранить FCM токен
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token])
      });
    } catch (e) {
      // Если документ пользователя еще не создан (в процессе регистрации),
      // update выбросит ошибку. Мы можем проигнорировать её, 
      // так как при следующем входе токен все равно обновится.
    }
  }
}
