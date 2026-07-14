import 'package:flutter/material.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';

class DifficultyBadge extends StatelessWidget {
  final DifficultyLevel level;
  const DifficultyBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (level) {
      DifficultyLevel.beginner => (Colors.green, 'Beginner'),
      DifficultyLevel.intermediate => (Colors.orange, 'Intermediate'),
      DifficultyLevel.advanced => (Colors.red, 'Advanced'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
