import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/chat.dart';

final chatServiceProvider = Provider((ref) => ChatService());

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _normalizeParticipants(List<String> participants) {
    return participants
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  bool _sameParticipants(List<String> first, List<String> second) {
    if (first.length != second.length) {
      return false;
    }

    for (final id in first) {
      if (!second.contains(id)) {
        return false;
      }
    }

    return true;
  }

  Stream<List<Chat>> getChatsStream(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Chat.fromJson(data);
          }).toList();
        });
  }

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Message.fromJson(data);
          }).toList();
        });
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final messageRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc();

    final message = Message(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final chatRef = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId);

    await _firestore.runTransaction((transaction) async {
      transaction.set(messageRef, message.toJson());
      transaction.update(chatRef, {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSenderId': senderId,
      });
    });
  }

  Future<String> createChat(List<String> participants) async {
    final normalizedParticipants = _normalizeParticipants(participants);
    if (normalizedParticipants.length < 2) {
      throw Exception('Для личного чата требуется минимум два участника.');
    }

    // Check if chat already exists
    final existingChatQuery = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: normalizedParticipants[0])
        .get();

    for (var doc in existingChatQuery.docs) {
      final existingParticipants = doc.data()['participants'] ?? [];
      if (existingParticipants.length == normalizedParticipants.length &&
          normalizedParticipants.every(
            (p) => existingParticipants.contains(p),
          )) {
        return doc.id;
      }
    }

    final newRef = _firestore.collection(AppConstants.chatsCollection).doc();
    final newChat = Chat(
      id: newRef.id,
      participants: normalizedParticipants,
      type: 'direct',
    );
    await newRef.set(newChat.toJson());
    return newRef.id;
  }

  Future<String> getOrCreateCommunityChat({
    required String communityId,
    required String communityName,
    required List<String> memberIds,
    String? communityCoverUrl,
  }) async {
    final participants = _normalizeParticipants(memberIds);
    if (participants.isEmpty) {
      throw Exception('Для группового чата нет участников.');
    }

    final existingChatQuery = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('type', isEqualTo: 'community')
        .where('communityId', isEqualTo: communityId)
        .limit(1)
        .get();

    if (existingChatQuery.docs.isNotEmpty) {
      final existingDoc = existingChatQuery.docs.first;
      final existingData = existingDoc.data();
      final existingParticipants = List<String>.from(
        existingData['participants'] ?? const <String>[],
      );

      final updates = <String, dynamic>{
        'title': communityName,
        'avatarUrl': communityCoverUrl,
      };

      if (!_sameParticipants(existingParticipants, participants)) {
        updates['participants'] = participants;
      }

      await existingDoc.reference.set(updates, SetOptions(merge: true));
      return existingDoc.id;
    }

    final newRef = _firestore.collection(AppConstants.chatsCollection).doc();
    final newChat = Chat(
      id: newRef.id,
      participants: participants,
      type: 'community',
      communityId: communityId,
      title: communityName,
      avatarUrl: communityCoverUrl,
    );

    await newRef.set(newChat.toJson());
    return newRef.id;
  }

  Future<void> syncCommunityChatParticipants(
    String communityId,
    List<String> memberIds,
  ) async {
    final participants = _normalizeParticipants(memberIds);

    final existingChatQuery = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('type', isEqualTo: 'community')
        .where('communityId', isEqualTo: communityId)
        .limit(1)
        .get();

    if (existingChatQuery.docs.isEmpty) {
      return;
    }

    await existingChatQuery.docs.first.reference.update({
      'participants': participants,
    });
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final unreadSnapshot = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadSnapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    var hasUpdates = false;

    for (final doc in unreadSnapshot.docs) {
      final data = doc.data();
      if (data['senderId'] != userId) {
        batch.update(doc.reference, {'isRead': true});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }
}
