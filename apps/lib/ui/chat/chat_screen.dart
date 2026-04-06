import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat.dart';
import '../../providers/chat_providers.dart';
import '../../providers/user_provider.dart';
import '../../services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? otherUserId;

  const ChatScreen({super.key, required this.chatId, this.otherUserId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isMarkingRead = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(authUserIdProvider);
    if (userId == null) return;

    ref.read(chatServiceProvider).sendMessage(widget.chatId, userId, text);
    _messageController.clear();
  }

  Future<void> _markIncomingAsRead(List<Message> messages, String? userId) async {
    if (userId == null || _isMarkingRead) return;

    final hasUnreadIncoming = messages.any(
      (message) => message.senderId != userId && !message.isRead,
    );

    if (!hasUnreadIncoming) return;

    _isMarkingRead = true;
    try {
      await ref.read(chatServiceProvider).markMessagesAsRead(widget.chatId, userId);
    } finally {
      _isMarkingRead = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final currentUserId = ref.watch(authUserIdProvider);
    final chatsAsync = ref.watch(userChatsStreamProvider);

    final resolvedOtherUserId =
        widget.otherUserId ??
        chatsAsync.maybeWhen(
          data: (chats) {
            for (final chat in chats) {
              if (chat.id == widget.chatId) {
                for (final participantId in chat.participants) {
                  if (participantId != currentUserId) {
                    return participantId;
                  }
                }
              }
            }
            return null;
          },
          orElse: () => null,
        );

    final otherUserProfileAsync = resolvedOtherUserId == null
        ? null
        : ref.watch(userProfileProvider(resolvedOtherUserId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          otherUserProfileAsync?.valueOrNull?.username ?? 'Загрузка...',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _markIncomingAsRead(messages, currentUserId);
                if (messages.isEmpty) {
                  return const Center(child: Text('Нет сообщений'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                            bottomLeft: !isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
