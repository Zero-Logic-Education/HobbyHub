import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String _selectedType = 'One-time';
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _types = [
    {'id': 'One-time', 'label': 'Разовое', 'icon': Icons.event_outlined},
    {'id': 'Recurring', 'label': 'Повторяющееся', 'icon': Icons.cached_rounded},
    {'id': 'Series', 'label': 'Серия', 'icon': Icons.assignment_outlined},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'id': 'sports', 'label': 'Спорт', 'icon': '🏃'},
    {'id': 'tech', 'label': 'Технологии', 'icon': '💻'},
    {'id': 'art', 'label': 'Творчество', 'icon': '🎨'},
    {'id': 'music', 'label': 'Музыка', 'icon': '🎵'},
    {'id': 'wellness', 'label': 'Здоровье', 'icon': '🧘'},
    {'id': 'food', 'label': 'Еда и напитки', 'icon': '🍽️'},
    {'id': 'photo', 'label': 'Фотография', 'icon': '📷'},
    {'id': 'books', 'label': 'Книги', 'icon': '📚'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Создать событие',
                        style: AppTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Шаг 1 из 2',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress indicator dot
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ТИП СОБЫТИЯ',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: _types.map((type) {
                        final isSelected = _selectedType == type['id'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedType = type['id']),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: type['id'] != 'Series' ? 12 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFF0F0F0),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    type['label'],
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Название события *',
                      style: AppTypography.subheadingLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Название события',
                      controller: _titleController,
                      hint: 'Дайте вашему событию крутое имя',
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Категория *',
                      style: AppTypography.subheadingLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category['id'];
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory = category['id'],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFF0F0F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category['icon'],
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category['label'],
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Описание *',
                      style: AppTypography.subheadingLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Расскажите людям, о чем ваше событие...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0F0F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0F0F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Продолжить',
                      onPressed: () {
                        // Logic for next step
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
