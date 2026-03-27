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

  /// Получить список событий с пагинацией
  Future<QuerySnapshot> getEvents({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(AppConstants.eventsCollection)
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
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Поиск событий по категориям
  Future<QuerySnapshot> searchEventsByCategories(
    List<String> categories,
  ) async {
    return await _firestore
        .collection(AppConstants.eventsCollection)
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
        .where('communityId', isEqualTo: communityId)
        .orderBy('date', descending: false)
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
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      transaction.set(reviewRef, reviewData, SetOptions(merge: true));
    });
  }
}
