import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/chat_providers.dart';
import '../../providers/user_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final userId = ref.watch(authUserIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Сообщения',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Поиск',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет активных чатов',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isCommunityChat = chat.type == 'community';
                    final otherUserId = isCommunityChat
                        ? null
                        : chat.participants.firstWhere(
                            (p) => p != userId,
                            orElse: () => '',
                          );

                    if (!isCommunityChat &&
                        (otherUserId == null || otherUserId.isEmpty)) {
                      return const SizedBox.shrink();
                    }

                    final otherProfile = !isCommunityChat && otherUserId != null
                        ? ref
                              .watch(userProfileProvider(otherUserId))
                              .valueOrNull
                        : null;

                    final username =
                        otherProfile?.username ??
                        otherProfile?.displayName ??
                        '';
                    final title = isCommunityChat
                        ? ((chat.title ?? '').trim().isNotEmpty
                              ? chat.title!.trim()
                              : 'Групповой чат')
                        : (username.isEmpty ? 'Загрузка...' : username);
                    final searchableText = '$title ${chat.lastMessage ?? ''}'
                        .toLowerCase();
                    if (_searchQuery.isNotEmpty &&
                        !searchableText.contains(_searchQuery)) {
                      return const SizedBox.shrink();
                    }

                    final unreadCountAsync = ref.watch(
                      unreadChatMessagesCountProvider(chat.id),
                    );
                    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

                    final avatarUrl = isCommunityChat
                        ? chat.avatarUrl
                        : otherProfile?.photoUrl;

                    return InkWell(
                      onTap: () {
                        context.push(
                          '/chats/${chat.id}',
                          extra: isCommunityChat ? null : otherUserId,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: avatarUrl != null &&
                                          avatarUrl.isNotEmpty
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  backgroundColor: Colors.grey[300],
                                  child: avatarUrl == null || avatarUrl.isEmpty
                                      ? Text(
                                          title.isNotEmpty
                                              ? title[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : null,
                                ),
                                if (!isCommunityChat)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (chat.lastMessageAt != null)
                                        Text(
                                          _formatTime(chat.lastMessageAt!),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: unreadCount > 0
                                                ? const Color(0xFFFF6B35)
                                                : Colors.grey,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          chat.lastMessage ?? 'Нет сообщений',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: unreadCount > 0
                                                ? Colors.black87
                                                : Colors.grey,
                                            fontWeight: unreadCount > 0
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (unreadCount > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFF6B35),
                                                Color(0xFFFF8C42)
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unreadCount > 99
                                                ? '99+'
                                                : unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) => const _ChatSkeletonTile(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Ошибка: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}д';
    } else {
      return '${dateTime.day}.${dateTime.month}';
    }
  }
}

class _ChatSkeletonTile extends StatelessWidget {
  const _ChatSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey.shade300),
      title: Container(
        height: 12,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          height: 10,
          width: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
