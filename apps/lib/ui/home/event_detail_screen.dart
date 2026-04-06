import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/category_colors.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/chat_service.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event? event;
  final String? eventId;

  const EventDetailScreen({super.key, this.event, this.eventId});

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(dateTime);
  }

  String _formatPrice(double price, bool isFree) {
    if (isFree || price <= 0) return 'Бесплатно';
    final hasFraction = price % 1 != 0;
    return '${price.toStringAsFixed(hasFraction ? 2 : 0)} ₽';
  }

  String _categoryLabel(Event event) {
    if (event.categories.isEmpty) return 'Разное';
    return event.categories.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedEvent = _resolveEvent(ref) ?? event;

    if (resolvedEvent == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Событие'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Событие не найдено')),
      );
    }

    final currentUserId = ref.watch(currentUserIdProvider);
    final participationState = ref.watch(eventParticipationProvider);
    final organizerAsync = ref.watch(
      userProfileProvider(resolvedEvent.organizerId),
    );
    final categoryColor = getCategoryColor(_categoryLabel(resolvedEvent));
    final location = (resolvedEvent.address ?? '').trim().isNotEmpty
        ? resolvedEvent.address!
        : 'Локация не указана';
    final visibleParticipantIds = resolvedEvent.participants.take(3).toList();
    final isParticipating =
        currentUserId != null &&
        resolvedEvent.participants.contains(currentUserId);
    final isOrganizer = currentUserId == resolvedEvent.organizerId;
    final eventFinished =
        (resolvedEvent.endTime ?? resolvedEvent.startTime).isBefore(
          DateTime.now(),
        ) ||
        resolvedEvent.status == 'completed';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: () => _shareEvent(context, resolvedEvent),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                resolvedEvent.coverImageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: categoryColor.withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(Icons.image, size: 60, color: categoryColor),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedEvent.title,
                    style: AppTypography.headingLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Дата и время',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(resolvedEvent.startTime),
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Цена',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(
                              resolvedEvent.price,
                              resolvedEvent.isFree,
                            ),
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (resolvedEvent.latitude != 0 ||
                                resolvedEvent.longitude != 0)
                              Text(
                                '${resolvedEvent.latitude.toStringAsFixed(4)}, ${resolvedEvent.longitude.toStringAsFixed(4)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.map, extra: resolvedEvent),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Показать на карте'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'О событии',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedEvent.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          currentUserId == null || participationState.isLoading
                          ? null
                          : () => _toggleParticipation(
                              context,
                              ref,
                              resolvedEvent,
                              currentUserId,
                              isParticipating,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: participationState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              isParticipating
                                  ? 'Покинуть событие'
                                  : 'Присоединиться',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/events/${resolvedEvent.id}/reviews'),
                        icon: const Icon(Icons.reviews_outlined),
                        label: const Text('Все отзывы'),
                      ),
                      if (eventFinished && isParticipating)
                        FilledButton.icon(
                          onPressed: () =>
                              context.push('/events/${resolvedEvent.id}/review'),
                          icon: const Icon(Icons.star_outline),
                          label: const Text('Оставить отзыв'),
                        ),
                      if (resolvedEvent.requiresApproval && isOrganizer)
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/events/${resolvedEvent.id}/moderation',
                          ),
                          icon: const Icon(Icons.verified_user_outlined),
                          label: const Text('Модерация заявок'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _categoryLabel(resolvedEvent),
                      style: AppTypography.bodyMedium.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Организатор',
                    style: AppTypography.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        backgroundImage: organizerAsync.value?.photoUrl != null
                            ? NetworkImage(organizerAsync.value!.photoUrl!)
                            : null,
                        child: organizerAsync.value?.photoUrl == null
                            ? Text(
                                _avatarLabel(
                                  organizerAsync.value?.displayName ??
                                      organizerAsync.value?.username ??
                                      'HobbyHub',
                                ),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              organizerAsync.value?.displayName
                                          ?.trim()
                                          .isNotEmpty ==
                                      true
                                  ? organizerAsync.value!.displayName!
                                  : organizerAsync.value?.username ??
                                        'Команда HobbyHub',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Смотреть профиль →',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: currentUserId == null
                            ? null
                            : () => _openOrganizerChat(
                                context,
                                ref,
                                resolvedEvent,
                                currentUserId,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Участники (${resolvedEvent.participants.length})',
                        style: AppTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _showAttendees(context, ref, resolvedEvent),
                        child: Text(
                          'Смотреть всех →',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: Stack(
                          children: [
                            for (
                              var index = 0;
                              index < visibleParticipantIds.length;
                              index++
                            )
                              Positioned(
                                left: index * 34.0,
                                child: _buildParticipantAvatar(
                                  ref: ref,
                                  userId: visibleParticipantIds[index],
                                ),
                              ),
                            if (resolvedEvent.participants.length >
                                visibleParticipantIds.length)
                              Positioned(
                                left: visibleParticipantIds.length * 34.0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    '+${resolvedEvent.participants.length - visibleParticipantIds.length}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Event? _resolveEvent(WidgetRef ref) {
    final id = eventId;
    if (id == null || id.isEmpty) {
      return null;
    }

    final eventsAsync = ref.watch(eventsStreamProvider);
    return eventsAsync.maybeWhen(
      data: (events) {
        for (final candidate in events) {
          if (candidate.id == id) {
            return candidate;
          }
        }
        return null;
      },
      orElse: () => null,
    );
  }

  Future<void> _toggleParticipation(
    BuildContext context,
    WidgetRef ref,
    Event event,
    String userId,
    bool isParticipating,
  ) async {
    try {
      await ref
          .read(eventParticipationProvider.notifier)
          .toggleParticipation(event, userId);

      if (!context.mounted) return;

      _showSnackBar(
        context,
        isParticipating ? 'Вы покинули событие' : 'Вы присоединились к событию',
      );
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Не удалось обновить участие. Попробуйте позже.');
    }
  }

  Future<void> _shareEvent(BuildContext context, Event event) async {
    final shareText = [
      event.title,
      _formatDate(event.startTime),
      if ((event.address ?? '').trim().isNotEmpty) event.address!,
      event.description,
    ].join('\n');

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: event.title),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Не удалось поделиться событием.');
    }
  }

  Future<void> _openOrganizerChat(
    BuildContext context,
    WidgetRef ref,
    Event event,
    String currentUserId,
  ) async {
    try {
      final chatId = await ref.read(chatServiceProvider).createChat([
        currentUserId,
        event.organizerId,
      ]);

      if (!context.mounted) return;

      context.push('${AppRoutes.chats}/$chatId', extra: event.organizerId);
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Чат с организатором временно недоступен.');
    }
  }

  Future<void> _showAttendees(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    if (event.participants.isEmpty) {
      _showSnackBar(context, 'У этого события пока нет участников.');
      return;
    }

    final profiles = await Future.wait(
      event.participants
          .map(
            (participantId) =>
                ref.read(userProfileProvider(participantId).future),
          )
          .toList(),
    );

    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: profiles.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final profile = profiles[index];
              final displayName =
                  profile?.displayName?.trim().isNotEmpty == true
                  ? profile!.displayName!
                  : profile?.username ?? 'Участник';
              final photoUrl = profile?.photoUrl;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            _avatarLabel(displayName),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildParticipantAvatar({
    required WidgetRef ref,
    required String userId,
  }) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    final profile = profileAsync.value;
    final displayName = profile?.displayName?.trim().isNotEmpty == true
        ? profile!.displayName!
        : profile?.username ?? 'Участник';
    final photoUrl = profile?.photoUrl;
    final palette = [
      const Color(0xFFFF8A7A),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
    ];

    return CircleAvatar(
      radius: 20,
      backgroundColor: palette[userId.hashCode.abs() % palette.length],
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              _avatarLabel(displayName),
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _avatarLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.toUpperCase();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
