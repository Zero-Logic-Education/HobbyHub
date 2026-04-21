import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_colors.dart';
import '../../shared/app_button.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/community.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  static const List<String> _availableCategoryKeys = <String>[
    'sports',
    'tech',
    'arts',
    'music',
    'health',
    'gaming',
    'cooking',
    'travel',
    'other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _coverImage;
  bool _isLoading = false;
  String? _selectedCategoryKey;
  String _privacyLevel = 'public';
  bool _requiresApproval = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      String? coverUrl;
      if (_coverImage != null) {
        final storageService = ref.read(storageServiceProvider);
        // We might want to save it after creating the doc and then update the doc,
        // but uploading it with a unique ID is fine for now.
        coverUrl = await storageService.uploadCommunityImage(
          'temp_${DateTime.now().millisecondsSinceEpoch}',
          _coverImage!,
        );
      }

      final firestoreService = ref.read(firestoreServiceProvider);

      final communityData = Community(
        id: '', // Firestore auto-generates when adding
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: userId,
        members: [userId],
        moderators: [userId],
        categories: _selectedCategoryKey == null
            ? const []
            : <String>[_selectedCategoryKey!],
        privacyLevel: _privacyLevel,
        requiresApproval: _requiresApproval,
        createdAt: DateTime.now(),
        coverImageUrl: coverUrl,
      ).toJson();

      // Remove empty id for Firestore to create a new one
      communityData.remove('id');

      await firestoreService.createCommunity(communityData);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сообщество успешно создано')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка при создании: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Создать сообщество',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover image picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: _coverImage == null
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.1),
                                    AppColors.primary.withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _coverImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Добавить обложку',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Название сообщества',
                        hintText: 'Например, Любители бега',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Введите название' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Описание',
                        hintText: 'Расскажите о вашем сообществе',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Введите описание' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryKey,
                      decoration: InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      items: _availableCategoryKeys
                          .map(
                            (key) => DropdownMenuItem<String>(
                              value: key,
                              child: Text(getCategoryDisplayLabelByKey(key)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryKey = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Выберите категорию';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Privacy dropdown
                    DropdownButtonFormField<String>(
                      value: _privacyLevel,
                      decoration: InputDecoration(
                        labelText: 'Приватность',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('Открытое'),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('Закрытое'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _privacyLevel = v!),
                    ),
                    const SizedBox(height: 20),

                    // Approval switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Вступление по заявкам',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Модерация новых участников',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _requiresApproval,
                            onChanged: (v) => setState(() => _requiresApproval = v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createCommunity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Создать сообщество',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
