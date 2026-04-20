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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Создать сообщество'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _coverImage == null
                            ? const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название сообщества',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Введите название' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Введите описание' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryKey,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
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
                    DropdownButtonFormField<String>(
                      initialValue: _privacyLevel,
                      decoration: const InputDecoration(
                        labelText: 'Приватность',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Вступление по заявкам'),
                      value: _requiresApproval,
                      onChanged: (v) => setState(() => _requiresApproval = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      onPressed: _createCommunity,
                      label: 'Создать',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
