import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
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
