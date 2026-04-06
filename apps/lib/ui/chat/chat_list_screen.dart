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
      appBar: AppBar(title: const Text('Сообщения')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Поиск чатов',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: chatsAsync.when(
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

                    final username =
                        otherProfileAsync.value?.username ??
                        otherProfileAsync.value?.displayName ??
                        '';
                    final searchableText = username.toLowerCase();
                    if (_searchQuery.isNotEmpty &&
                        !searchableText.contains(_searchQuery)) {
                      return const SizedBox.shrink();
                    }

                    final unreadCountAsync = ref.watch(
                      unreadChatMessagesCountProvider(chat.id),
                    );
                    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: otherProfileAsync.value?.photoUrl != null
                            ? NetworkImage(otherProfileAsync.value!.photoUrl!)
                            : null,
                        child: otherProfileAsync.value?.photoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        username.isEmpty ? 'Загрузка...' : username,
                      ),
                      subtitle: Text(
                        chat.lastMessage ?? 'Нет сообщений',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: unreadCount > 0
                          ? CircleAvatar(
                              radius: 11,
                              backgroundColor: Theme.of(context).primaryColor,
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
                            )
                          : null,
                      onTap: () {
                        context.push('/chats/${chat.id}');
                      },
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) => const _ChatSkeletonTile(),
              ),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatSkeletonTile extends StatelessWidget {
  const _ChatSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
      ),
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
