import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';
import '../../services/firebase/storage_service.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();

  int _currentStep = 1;
  String _selectedType = 'One-time';
  String? _selectedCategory;
  bool _isSubmitting = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  DateTime? _startDateTime;
  double? _latitude;
  double? _longitude;
  File? _coverImageFile;

  bool _isFree = true;
  bool _requiresApproval = false;
  int _selectedMinAge = 12;

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
    _addressController.dispose();
    _priceController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  String _mapEventType(String type) {
    switch (type) {
      case 'Recurring':
        return 'recurring';
      case 'Series':
        return 'series';
      case 'One-time':
      default:
        return 'single';
    }
  }

  String _categoryLabelById(String? id) {
    if (id == null) return '';
    final category = _categories.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {'label': id},
    );
    return category['label'] as String;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _startDateTime ?? now;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime ?? now),
    );

    if (selectedTime == null) return;

    setState(() {
      _startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _pickCoverImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;
    setState(() {
      _coverImageFile = File(image.path);
    });
  }

  Future<void> _useCurrentLocation() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      _showMessage('Включите геолокацию на устройстве');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Нужен доступ к геолокации для автоопределения адреса');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String autoAddress = '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        autoAddress = <String?>[
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        if (autoAddress.isNotEmpty) {
          _addressController.text = autoAddress;
        }
      });
    } catch (_) {
      _showMessage('Не удалось определить текущее местоположение');
    }
  }

  Future<void> _resolveCoordinatesFromAddress() async {
    if (_latitude != null && _longitude != null) {
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      throw Exception('Укажите адрес события');
    }

    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        throw Exception('Не удалось определить координаты по адресу. Уточните адрес.');
      }

      _latitude = locations.first.latitude;
      _longitude = locations.first.longitude;
    } catch (e) {
      if (e.toString().contains('Не удалось определить координаты')) {
        rethrow;
      }
      throw Exception('Не удалось определить координаты по адресу. Уточните адрес.');
    }
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Введите название';
    if (title.length > AppConstants.maxEventTitleLength) {
      return 'Максимум ${AppConstants.maxEventTitleLength} символов';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) return 'Введите описание';
    if (description.length > AppConstants.maxEventDescriptionLength) {
      return 'Максимум ${AppConstants.maxEventDescriptionLength} символов';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Введите адрес';
    return null;
  }

  String? _validatePrice(String? value) {
    if (_isFree) return null;
    final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (parsed == null) return 'Введите корректную цену';
    if (parsed <= 0) return 'Цена должна быть больше 0';
    return null;
  }

  String? _validateMaxParticipants(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final parsed = int.tryParse(raw);
    if (parsed == null) return 'Введите целое число';
    if (parsed < 0) return 'Не может быть отрицательным';
    return null;
  }

  void _goToStepTwo() {
    final isValid = _stepOneFormKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedCategory == null) {
      _showMessage('Выберите категорию');
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submitEvent() async {
    final isStepTwoValid = _stepTwoFormKey.currentState?.validate() ?? false;
    if (!isStepTwoValid) return;

    if (_startDateTime == null) {
      _showMessage('Выберите дату и время');
      return;
    }

    if (_startDateTime!.isBefore(DateTime.now())) {
      _showMessage('Дата события не может быть в прошлом');
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      _showMessage('Вы не авторизованы');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _resolveCoordinatesFromAddress();

      String? imageUrl;
      final eventId = _uuid.v4();
      if (_coverImageFile != null) {
        imageUrl = await _storageService.uploadEventImage(eventId, _coverImageFile!);
      }

      final parsedPrice = _isFree
          ? 0.0
          : double.parse(_priceController.text.trim().replaceAll(',', '.'));
      final maxParticipants =
          int.tryParse(_maxParticipantsController.text.trim()) ?? 0;

      final event = Event(
        id: eventId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        organizerId: userId,
        startTime: _startDateTime!,
        latitude: _latitude ?? AppConstants.defaultLatitude,
        longitude: _longitude ?? AppConstants.defaultLongitude,
        address: _addressController.text.trim(),
        coverImageUrl: imageUrl,
        categories: [_categoryLabelById(_selectedCategory)],
        maxParticipants: maxParticipants,
        price: parsedPrice,
        isFree: _isFree,
        visibility: AppConstants.privacyPublic,
        minAge: _selectedMinAge,
        requiresApproval: _requiresApproval,
        eventType: _mapEventType(_selectedType),
        createdAt: DateTime.now(),
        status: 'published',
      );

      await ref.read(eventsProvider.notifier).createEvent(event);

      if (!mounted) return;
      _showMessage('Событие создано');
      context.go(AppRoutes.home);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is Exception) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      _showMessage('Не удалось создать событие: $errorMessage');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStepOne() {
    return Form(
      key: _stepOneFormKey,
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
                  onTap: () => setState(() => _selectedType = type['id']),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: type['id'] != 'Series' ? 12 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF0F0F0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
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
          AppTextField(
            label: 'Название события *',
            controller: _titleController,
            hint: 'Дайте вашему событию крутое имя',
            maxLength: AppConstants.maxEventTitleLength,
            validator: _validateTitle,
          ),
          const SizedBox(height: 24),
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                onTap: () => setState(() => _selectedCategory = category['id']),
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
                      Text(category['icon'], style: const TextStyle(fontSize: 18)),
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
          const SizedBox(height: 24),
          Text(
            'Описание *',
            style: AppTypography.subheadingLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: AppConstants.maxEventDescriptionLength,
            validator: _validateDescription,
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
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(label: 'Продолжить', onPressed: _goToStepTwo),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return Form(
      key: _stepTwoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дата и время *',
            style: AppTypography.subheadingLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _startDateTime == null
                          ? 'Выберите дату и время'
                          : '${_startDateTime!.day.toString().padLeft(2, '0')}.${_startDateTime!.month.toString().padLeft(2, '0')}.${_startDateTime!.year} ${_startDateTime!.hour.toString().padLeft(2, '0')}:${_startDateTime!.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Адрес *',
            controller: _addressController,
            hint: 'Введите адрес вручную или используйте геолокацию',
            validator: _validateAddress,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Определить мой адрес',
            onPressed: _useCurrentLocation,
            leftIcon: const Icon(Icons.my_location_rounded),
          ),
          const SizedBox(height: 24),
          Text(
            'Обложка события',
            style: AppTypography.subheadingLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickCoverImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: _coverImageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 36,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Выбрать фото',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_coverImageFile!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            value: _isFree,
            onChanged: (value) => setState(() {
              _isFree = value;
              if (value) {
                _priceController.clear();
              }
            }),
            title: Text(
              'Бесплатное событие',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
          ),
          if (!_isFree) ...[
            const SizedBox(height: 12),
            AppTextField(
              label: 'Цена, ₽ *',
              controller: _priceController,
              hint: 'Например, 500',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validatePrice,
            ),
          ],
          const SizedBox(height: 20),
          AppTextField(
            label: 'Лимит участников',
            controller: _maxParticipantsController,
            hint: '0 = без ограничений',
            keyboardType: TextInputType.number,
            validator: _validateMaxParticipants,
          ),
          const SizedBox(height: 20),
          Text(
            'Возрастное ограничение *',
            style: AppTypography.subheadingLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [12, 18, 25].map((age) {
              final isSelected = _selectedMinAge == age;
              return ChoiceChip(
                label: Text('$age+'),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMinAge = age),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile.adaptive(
            value: _requiresApproval,
            onChanged: (value) => setState(() => _requiresApproval = value),
            title: Text(
              'Требовать одобрение заявок',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Назад',
                  onPressed: () => setState(() => _currentStep = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Создать',
                  isLoading: _isSubmitting,
                  onPressed: _submitEvent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
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
                        'Шаг $_currentStep из 2',
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
                        width: _currentStep >= 1 ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: _currentStep == 2 ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentStep == 2
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(10),
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
                child: _currentStep == 1 ? _buildStepOne() : _buildStepTwo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
