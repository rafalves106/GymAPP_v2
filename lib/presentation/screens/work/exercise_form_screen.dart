import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/data/models/exercise_model.dart';
import 'package:gym_app/presentation/providers/exercises_provider.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';
import 'package:gym_app/domain/enums/equipment_type.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const ExerciseFormScreen({super.key, this.id});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  MuscleGroupType _selectedMuscleGroup = MuscleGroupType.chest;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.beginner;
  final Set<EquipmentType> _selectedEquipments = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _videoUrlController = TextEditingController();

    if (widget.id != null) {
      _isEditing = true;
      final exercises = ref.read(exercisesProvider).valueOrNull ?? [];
      final exercise = exercises.where((e) => e.id == widget.id).firstOrNull;
      if (exercise != null) {
        _nameController.text = exercise.name;
        _descriptionController.text = exercise.description;
        _videoUrlController.text = exercise.videoUrl ?? '';
        _selectedMuscleGroup = exercise.muscleGroups.first;
        _selectedDifficulty = exercise.difficultyLevel;
        _selectedEquipments.addAll(exercise.equipments);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final exercise = ExerciseModel(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      muscleGroups: [_selectedMuscleGroup],
      equipments: _selectedEquipments.toList(),
      difficultyLevel: _selectedDifficulty,
      videoUrl: _videoUrlController.text.isEmpty
          ? null
          : _videoUrlController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(exercisesProvider.notifier);
    if (_isEditing) {
      notifier.updateExercise(exercise);
    } else {
      notifier.createExercise(exercise);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Exercise' : 'New Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MuscleGroupType>(
                initialValue: _selectedMuscleGroup,
                decoration: const InputDecoration(
                  labelText: 'Muscle Group',
                  border: OutlineInputBorder(),
                ),
                items: MuscleGroupType.values
                    .map((mg) => DropdownMenuItem(
                          value: mg,
                          child: Text(mg.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMuscleGroup = v);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DifficultyLevel>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: DifficultyLevel.values
                    .map((dl) => DropdownMenuItem(
                          value: dl,
                          child: Text(dl.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDifficulty = v);
                },
              ),
              const SizedBox(height: 16),
              Text('Equipment',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: EquipmentType.values.map((eq) {
                  final selected = _selectedEquipments.contains(eq);
                  return FilterChip(
                    label: Text(eq.label),
                    selected: selected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipments.add(eq);
                        } else {
                          _selectedEquipments.remove(eq);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
