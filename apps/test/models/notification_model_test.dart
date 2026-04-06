import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_hub/models/notification.dart';

void main() {
  group('NotificationModel.fromJson', () {
    test('parses Timestamp createdAt', () {
      final now = DateTime.now();
      final model = NotificationModel.fromJson({
        'id': 'n1',
        'title': 'T',
        'body': 'B',
        'createdAt': Timestamp.fromDate(now),
        'type': 'system',
      });

      expect(model.id, 'n1');
      expect(model.type, 'system');
      expect(model.createdAt.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      expect(model.createdAt.isAfter(now.subtract(const Duration(seconds: 1))), isTrue);
    });

    test('falls back safely when createdAt is missing', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final model = NotificationModel.fromJson({
        'id': 'n2',
        'title': 'T',
        'body': 'B',
        'type': 'system',
      });

      expect(model.id, 'n2');
      expect(model.createdAt.isAfter(before), isTrue);
    });
  });
}
