import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/chat_providers.dart';
import '../../providers/user_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final userId = ref.watch(authUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сообщения')),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('Нет активных чатов'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants.firstWhere(
                (p) => p != userId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) return const SizedBox.shrink();

              final otherProfileAsync = ref.watch(
                userProfileProvider(otherUserId),
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: otherProfileAsync.value?.photoUrl != null
                      ? NetworkImage(otherProfileAsync.value!.photoUrl!)
                      : null,
                  child: otherProfileAsync.value?.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(otherProfileAsync.value?.username ?? 'Загрузка...'),
                subtitle: Text(
                  chat.lastMessage ?? 'Нет сообщений',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight:
                        chat.lastMessageSenderId != userId &&
                            (chat.lastMessageSenderId != null)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  context.push('/chats/${chat.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}
