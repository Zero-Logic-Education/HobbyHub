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

  Future<void> _markIncomingAsRead(
    List<Message> messages,
    String? userId,
  ) async {
    if (userId == null || _isMarkingRead) return;

    final hasUnreadIncoming = messages.any(
      (message) => message.senderId != userId && !message.isRead,
    );

    if (!hasUnreadIncoming) return;

    _isMarkingRead = true;
    try {
      await ref
          .read(chatServiceProvider)
          .markMessagesAsRead(widget.chatId, userId);
    } finally {
      _isMarkingRead = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.chatId));
    final currentUserId = ref.watch(authUserIdProvider);
    final chatsAsync = ref.watch(userChatsStreamProvider);

    final currentChat = chatsAsync.maybeWhen(
      data: (chats) {
        for (final chat in chats) {
          if (chat.id == widget.chatId) {
            return chat;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    final isCommunityChat = currentChat?.type == 'community';

    final resolvedOtherUserId = isCommunityChat
        ? null
        : (widget.otherUserId ??
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
              ));

    final otherUserProfileAsync = resolvedOtherUserId == null
        ? null
        : ref.watch(userProfileProvider(resolvedOtherUserId));

    final appBarTitle = isCommunityChat
        ? ((currentChat?.title ?? '').trim().isNotEmpty
              ? currentChat!.title!.trim()
              : 'Групповой чат')
        : (otherUserProfileAsync?.valueOrNull?.username ??
              otherUserProfileAsync?.valueOrNull?.displayName ??
              'Загрузка...');

    final avatarUrl = isCommunityChat
        ? currentChat?.avatarUrl
        : otherUserProfileAsync?.valueOrNull?.photoUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            avatarUrl != null && avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isCommunityChat
                            ? [
                                const Color(0xFFFF6B35).withValues(alpha: 0.8),
                                const Color(0xFFFF8C42).withValues(alpha: 0.6),
                              ]
                            : [
                                Colors.grey[400]!,
                                Colors.grey[300]!,
                              ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCommunityChat ? Icons.groups_rounded : Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appBarTitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _markIncomingAsRead(messages, currentUserId);
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет сообщений',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isMe
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35),
                                          Color(0xFFFF8C42),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isMe ? null : Colors.white,
                                borderRadius: BorderRadius.circular(18).copyWith(
                                  bottomRight: isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                  bottomLeft: !isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFFF6B35),
                              child: const Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Ошибка: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFFFF6B35),
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Сообщение...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
