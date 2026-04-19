import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../shared/app_text_field.dart';
import '../../shared/app_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    // Заполнение текущими данными
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserStreamProvider).valueOrNull;
      if (user != null) {
        if (user.displayName != null) {
          _nameController.text = user.displayName!;
        }
        if (user.bio != null) {
          _bioController.text = user.bio!;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка выбора фото: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Требуется авторизация')),
        );
        return;
      }

      String? photoUrl;

      // Если выбрали новое фото, загружаем его
      if (_imageFile != null) {
        final storageService = ref.read(storageServiceProvider);
        photoUrl = await storageService.uploadProfileImage(userId, _imageFile!);
      }

      await ref
          .read(currentUserProfileNotifierProvider.notifier)
          .updateProfile(
            displayName: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            photoUrl: photoUrl,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профиль успешно обновлен')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Пользователь не найден'),
            );
          }

          final currentPhotoUrl = user.photoUrl;
          final initials = user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim().substring(0, 1).toUpperCase()
              : 'U';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : (currentPhotoUrl != null
                                      ? NetworkImage(currentPhotoUrl)
                                      : null),
                            child:
                                _imageFile == null && currentPhotoUrl == null
                                ? Text(
                                    initials,
                                    style: AppTypography.headingMedium
                                        .copyWith(color: AppColors.primary),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Имя',
                      controller: _nameController,
                      hint: 'Введите ваше имя',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Имя не может быть пустым';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'О себе',
                      controller: _bioController,
                      hint: 'Расскажите немного о себе...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      label: 'Сохранить',
                      isLoading: _isLoading,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Ошибка загрузки профиля: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
