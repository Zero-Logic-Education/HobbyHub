import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/community.dart';
import 'user_provider.dart';
import 'auth_provider.dart';

/// Provider for user's communities stream
final userCommunitiesProvider = StreamProvider<List<Community>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return Stream.value([]);

  return firestoreService.userCommunitiesStream(userId).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // ensure ID is passed
      return Community.fromJson(data);
    }).toList();
  });
});

/// Provider for all communities
final allCommunitiesProvider = FutureProvider<List<Community>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final snapshot = await firestoreService.getCommunities();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Community.fromJson(data);
  }).toList();
});

/// Провайдер для получения конкретного сообщества
final communityStreamProvider = StreamProvider.family<Community?, String>((
  ref,
  communityId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCommunityStream(communityId).map((doc) {
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Community.fromJson(data);
  });
});
