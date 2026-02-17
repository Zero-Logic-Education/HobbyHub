import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';

/// Сервис для работы с Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== PROFILE IMAGES ====================

  /// Загрузить фото профиля
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.profileImagesPath}/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Ошибка загрузки фото профиля: $e');
    }
  }

  /// Удалить фото профиля
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Ошибка удаления фото профиля: $e');
    }
  }

  // ==================== EVENT IMAGES ====================

  /// Загрузить обложку события
  Future<String> uploadEventImage(String eventId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.eventImagesPath}/$eventId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Ошибка загрузки фото события: $e');
    }
  }

  /// Загрузить несколько фото для события
  Future<List<String>> uploadEventImages(
      String eventId, List<File> imageFiles) async {
    final urls = <String>[];

    for (final file in imageFiles) {
      final url = await uploadEventImage(eventId, file);
      urls.add(url);
    }

    return urls;
  }

  /// Удалить фото события
  Future<void> deleteEventImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Ошибка удаления фото события: $e');
    }
  }

  // ==================== COMMUNITY IMAGES ====================

  /// Загрузить обложку сообщества
  Future<String> uploadCommunityImage(
      String communityId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
          '${AppConstants.communityImagesPath}/$communityId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Ошибка загрузки фото сообщества: $e');
    }
  }

  // ==================== UPLOAD WITH PROGRESS ====================

  /// Загрузить файл с отслеживанием прогресса
  Stream<TaskSnapshot> uploadFileWithProgress(String path, File file) {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    return uploadTask.snapshotEvents;
  }

  /// Получить прогресс загрузки в процентах
  double getUploadProgress(TaskSnapshot snapshot) {
    return (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
  }

  // ==================== UTILS ====================

  /// Проверить, существует ли файл
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Получить метаданные файла
  Future<FullMetadata> getFileMetadata(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getMetadata();
  }

  /// Получить размер файла в байтах
  Future<int> getFileSize(String path) async {
    final metadata = await getFileMetadata(path);
    return metadata.size ?? 0;
  }
}
