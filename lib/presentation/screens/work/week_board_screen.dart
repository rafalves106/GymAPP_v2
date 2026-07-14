import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/domain/entities/training.dart';
import 'package:gym_app/presentation/providers/trainings_provider.dart';
import 'package:gym_app/presentation/widgets/workout_chip.dart';
import 'package:gym_app/presentation/widgets/empty_state.dart';
import 'package:gym_app/presentation/widgets/error_state.dart';
import 'package:gym_app/presentation/widgets/loading_shimmer.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class WeekBoardScreen extends ConsumerStatefulWidget {
  const WeekBoardScreen({super.key});

  @override
  ConsumerState<WeekBoardScreen> createState() => _WeekBoardScreenState();
}

class _WeekBoardScreenState extends ConsumerState<WeekBoardScreen> {
  int _selectedDayIndex = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final trainingsAsync = ref.watch(trainingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.calendar_badge_plus),
            onPressed: () => context.push('/home/work/trainings/new'),
            tooltip: 'New Training',
          ),
        ],
      ),
      body: trainingsAsync.when(
        data: (trainings) {
          if (trainings.isEmpty) {
            return EmptyState(
              icon: CupertinoIcons.calendar,
              title: 'No trainings yet',
              subtitle: 'Create a training to schedule your week',
              actionLabel: 'Create Training',
              onAction: () => context.push('/home/work/trainings/new'),
            );
          }

          return Column(
            children: [
              _DaySelector(
                selectedIndex: _selectedDayIndex,
                onDaySelected: (index) {
                  setState(() => _selectedDayIndex = index);
                  HapticFeedbackHelper.selection();
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedbackHelper.light();
                    await ref.read(trainingsProvider.notifier).refresh();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _SelectedDaySection(
                        dayIndex: _selectedDayIndex,
                        trainings: trainings,
                      ),
                      const SizedBox(height: 16),
                      _UnassignedSection(
                        trainings: trainings,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.read(trainingsProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const _DaySelector({
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          final isSelected = index == selectedIndex;
          final isToday = index == now;

          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : isToday
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      Training.dayLabelsShort[index].substring(0, 1),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : isToday
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Training.dayLabelsShort[index],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : isToday
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SelectedDaySection extends ConsumerWidget {
  final int dayIndex;
  final List<Training> trainings;

  const _SelectedDaySection({
    required this.dayIndex,
    required this.trainings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now().weekday - 1;
    final dayTrainings = trainings.where((t) => t.scheduledDay == dayIndex).toList();

    return DragTarget<Training>(
      onAcceptWithDetails: (details) {
        HapticFeedbackHelper.medium();
        ref.read(trainingsProvider.notifier).assignDay(details.data.id, dayIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovering
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    Training.dayLabels[dayIndex],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (dayIndex == now) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'today',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${dayTrainings.length} training${dayTrainings.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isHovering) ...[
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.add_circled,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (dayTrainings.isNotEmpty)
                ...dayTrainings.map(
                  (training) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: WorkoutChip(
                      training: training,
                      onTap: () {
                        HapticFeedbackHelper.selection();
                        context.push('/home/work/trainings/${training.id}');
                      },
                      onEdit: () {
                        context.push('/home/work/trainings/${training.id}/edit');
                      },
                      onDelete: () async {
                        HapticFeedbackHelper.medium();
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Unassign Training'),
                            content: Text(
                              'Remove "${training.name}" from ${Training.dayLabels[dayIndex]}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          ref
                              .read(trainingsProvider.notifier)
                              .assignDay(training.id, null);
                        }
                      },
                    ),
                  ),
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      isHovering
                          ? 'Drop training here'
                          : 'Drag a training here or tap + to create',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UnassignedSection extends ConsumerWidget {
  final List<Training> trainings;

  const _UnassignedSection({required this.trainings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unassigned = trainings.where((t) => t.scheduledDay == null).toList();

    if (unassigned.isEmpty) return const SizedBox.shrink();

    return DragTarget<Training>(
      onAcceptWithDetails: (details) {
        HapticFeedbackHelper.medium();
        ref.read(trainingsProvider.notifier).assignDay(details.data.id, null);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovering
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.tray,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unassigned',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${unassigned.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unassigned.map((training) {
                  return LongPressDraggable<Training>(
                    data: training,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: WorkoutChip(
                        training: training,
                        isDragging: true,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.4,
                      child: WorkoutChip(training: training),
                    ),
                    onDragStarted: () => HapticFeedbackHelper.medium(),
                    child: WorkoutChip(
                      training: training,
                      onTap: () {
                        HapticFeedbackHelper.selection();
                        context.push('/home/work/trainings/${training.id}');
                      },
                      onEdit: () {
                        context
                            .push('/home/work/trainings/${training.id}/edit');
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
