import 'auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import 'user_provider.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserNotifications(userId).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return NotificationModel.fromJson(data);
    }).toList();
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
