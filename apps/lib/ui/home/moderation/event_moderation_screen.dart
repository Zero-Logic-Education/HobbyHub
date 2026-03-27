import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../models/user.dart' as model;

final eventApplicationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, eventId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getEventApplications(eventId).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  });
});

class EventModerationScreen extends ConsumerWidget {
  final String eventId;

  const EventModerationScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(eventApplicationsProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заявки на участие'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(child: Text('Нет новых заявок'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final userId = app['userId'] as String;

              return ApplicationCard(
                eventId: eventId,
                userId: userId,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }
}

class ApplicationCard extends ConsumerWidget {
  final String eventId;
  final String userId;

  const ApplicationCard({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    
    return FutureBuilder<model.User?>( 
      future: firestoreService.getUser(userId).then((doc) {
        if (!doc.exists) return null;
        return model.User.fromJson(doc.data() as Map<String, dynamic>);
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: ListTile(title: Text('Загрузка...')));
        }
        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? 'Без имени', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (user.bio != null)
                        Text(
                          user.bio!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () async {
                    await ref.read(firestoreServiceProvider).approveApplication(eventId, userId);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () async {
                    await ref.read(firestoreServiceProvider).rejectApplication(eventId, userId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
