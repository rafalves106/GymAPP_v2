import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gym_app/domain/entities/training.dart';
import 'package:gym_app/presentation/widgets/workout_chip.dart';

class DayBox extends StatelessWidget {
  final String dayLabel;
  final bool isToday;
  final List<Training> trainings;
  final bool isHighlighted;
  final VoidCallback? onTrainingTap;
  final void Function(Training)? onTrainingEdit;
  final void Function(Training)? onTrainingDelete;
  final void Function(Training)? onTrainingDropped;

  const DayBox({
    super.key,
    required this.dayLabel,
    this.isToday = false,
    this.trainings = const [],
    this.isHighlighted = false,
    this.onTrainingTap,
    this.onTrainingEdit,
    this.onTrainingDelete,
    this.onTrainingDropped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DragTarget<Training>(
      onAcceptWithDetails: (details) {
        onTrainingDropped?.call(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : isToday
                    ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                    : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering
                  ? colorScheme.primary
                  : isToday
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    dayLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (isToday) ...[
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
                  if (isHovering)
                    Icon(
                      CupertinoIcons.add_circled,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
              if (trainings.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...trainings.map(
                  (training) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: WorkoutChip(
                      training: training,
                      onTap: () => onTrainingTap?.call(),
                      onEdit: () => onTrainingEdit?.call(training),
                      onDelete: () => onTrainingDelete?.call(training),
                    ),
                  ),
                ),
              ] else if (!isHovering) ...[
                const SizedBox(height: 8),
                Text(
                  'No trainings',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
