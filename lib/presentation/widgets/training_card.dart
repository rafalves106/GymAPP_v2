import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gym_app/domain/entities/training.dart';

class TrainingCard extends StatelessWidget {
  final Training training;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TrainingCard({
    super.key,
    required this.training,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(training.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(CupertinoIcons.trash, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: onTap,
          title: Text(training.name),
          subtitle: Text(
            '${training.exercises.length} exercises',
          ),
          trailing: const Icon(CupertinoIcons.chevron_right),
        ),
      ),
    );
  }
}
