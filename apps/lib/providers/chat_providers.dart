import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../core/constants/app_constants.dart';
import 'auth_provider.dart';

final authUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserIdProvider);
});

final userChatsStreamProvider = StreamProvider<List<Chat>>((ref) {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }
  return ref.watch(chatServiceProvider).getChatsStream(userId);
});

final chatMessagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, id) {
    return ref.watch(chatServiceProvider).getMessagesStream(id);
  },
);

final unreadChatMessagesCountProvider = StreamProvider.family<int, String>((
  ref,
  chatId,
) {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) {
    return Stream.value(0);
  }

  return FirebaseFirestore.instance
      .collection(AppConstants.chatsCollection)
      .doc(chatId)
      .collection(AppConstants.messagesCollection)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) {
        var count = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['senderId'] != userId) {
            count++;
          }
        }
        return count;
      });
});
