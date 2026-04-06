import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../core/theme/app_colors.dart';

import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          TextButton(
            onPressed: () {
              final notifications = notificationsAsync.valueOrNull;
              final userId = ref.read(currentUserIdProvider);
              if (notifications != null && userId != null) {
                final firestoreService = ref.read(firestoreServiceProvider);
                for (var n in notifications) {
                  if (!n.isRead) {
                    firestoreService.markNotificationAsRead(userId, n.id);
                  }
                }
              }
            },
            child: const Text(
              'Прочитать все',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('У вас нет новых уведомлений'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isUnread = !notification.isRead;

              return ListTile(
                tileColor: isUnread
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : null,
                leading: CircleAvatar(
                  backgroundColor: _getNotificationColor(notification.type),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'dd.MM.yyyy HH:mm',
                      ).format(notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                onTap: () {
                  if (isUnread) {
                    final userId = ref.read(currentUserIdProvider);
                    if (userId != null) {
                      ref
                          .read(firestoreServiceProvider)
                          .markNotificationAsRead(userId, notification.id);
                    }
                  }

                  final relatedId = notification.relatedId;
                  switch (notification.type) {
                    case 'event_invite':
                    case 'application_approved':
                    case 'application_rejected':
                      if (relatedId != null) {
                        context.push('/home/event/$relatedId');
                      }
                      break;
                    case 'new_message':
                    case 'chat_message':
                      if (relatedId != null) {
                        context.push('/chats/$relatedId');
                      }
                      break;
                    default:
                      break;
                  }
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

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'event_invite':
      case 'system':
        return AppColors.primary;
      case 'application_approved':
        return Colors.green;
      case 'application_rejected':
        return Colors.red;
      case 'new_message':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'event_invite':
        return Icons.event;
      case 'application_approved':
        return Icons.check_circle;
      case 'application_rejected':
        return Icons.cancel;
      case 'new_message':
        return Icons.message;
      case 'system':
      default:
        return Icons.notifications;
    }
  }
}
