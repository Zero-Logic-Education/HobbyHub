import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/chat.dart';

final chatServiceProvider = Provider((ref) => ChatService());

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    // Check if chat already exists
    final existingChatQuery = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: participants[0])
        .get();

    for (var doc in existingChatQuery.docs) {
      List<dynamic> existingParticipants = doc.data()['participants'] ?? [];
      if (existingParticipants.length == participants.length &&
          participants.every((p) => existingParticipants.contains(p))) {
        return doc.id;
      }
    }

    final newRef = _firestore.collection(AppConstants.chatsCollection).doc();
    final newChat = Chat(id: newRef.id, participants: participants);
    await newRef.set(newChat.toJson());
    return newRef.id;
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
