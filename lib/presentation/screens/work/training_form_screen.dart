import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/data/models/training_model.dart';
import 'package:gym_app/data/models/training_exercise_model.dart';
import 'package:gym_app/data/models/exercise_model.dart';
import 'package:gym_app/domain/entities/training.dart';
import 'package:gym_app/presentation/providers/trainings_provider.dart';
import 'package:gym_app/presentation/providers/exercises_provider.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';

class TrainingFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const TrainingFormScreen({super.key, this.id});

  @override
  ConsumerState<TrainingFormScreen> createState() => _TrainingFormScreenState();
}

class _TrainingFormScreenState extends ConsumerState<TrainingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final List<TrainingExerciseModel> _exercises = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.id != null) {
      _isEditing = true;
      final trainings = ref.read(trainingsProvider).valueOrNull ?? [];
      final training = trainings.where((t) => t.id == widget.id).firstOrNull;
      if (training != null) {
        _nameController.text = training.name;
        _descriptionController.text = training.description ?? '';
        _exercises.addAll(
          training.exercises
              .map((e) => TrainingExerciseModel.fromEntity(e)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final exercises = ref.read(exercisesProvider).valueOrNull ?? [];
    if (exercises.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExercisePickerSheet(
        exercises: exercises,
        onSelected: (exercise) {
          Navigator.pop(ctx);
          _configureExercise(exercise);
        },
      ),
    );
  }

  void _configureExercise(ExerciseModel exercise) {
    int series = 3;
    int reps = 10;
    int restTime = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exercise.name,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Series'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: series > 1
                                  ? () => setModalState(() => series--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$series',
                                style: const TextStyle(fontSize: 20)),
                            IconButton(
                              onPressed: series < 15
                                  ? () => setModalState(() => series++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Reps'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: reps > 1
                                  ? () => setModalState(() => reps--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$reps',
                                style: const TextStyle(fontSize: 20)),
                            IconButton(
                              onPressed: reps < 30
                                  ? () => setModalState(() => reps++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Rest (s)'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: restTime > 0
                                  ? () => setModalState(() => restTime -= 15)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$restTime',
                                style: const TextStyle(fontSize: 20)),
                            IconButton(
                              onPressed: restTime < 120
                                  ? () => setModalState(() => restTime += 15)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _exercises.add(TrainingExerciseModel(
                      exerciseId: exercise.id,
                      exerciseName: exercise.name,
                      orderIndex: _exercises.length,
                      restTime: restTime,
                      reps: reps,
                      series: series,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final training = TrainingModel(
      id: widget.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text.trim(),
      exercises: _exercises,
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(trainingsProvider.notifier);
    if (_isEditing) {
      notifier.updateTraining(training);
    } else {
      notifier.createTraining(training);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Training' : 'New Training'),
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
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises (${_exercises.length}/${Training.maxExercises})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_exercises.length < Training.maxExercises)
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                    for (var i = 0; i < _exercises.length; i++) {
                      _exercises[i] = _exercises[i].copyWith(orderIndex: i) as TrainingExerciseModel;
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final te = _exercises[index];
                  return Card(
                    key: ValueKey(te.exerciseId),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(te.exerciseName),
                      subtitle: Text(
                        '${te.series} × ${te.reps} reps • ${te.restTime}s rest',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_handle),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => _exercises.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

class _ExercisePickerSheet extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final ValueChanged<ExerciseModel> onSelected;

  const _ExercisePickerSheet({
    required this.exercises,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Exercise',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: exercises.length,
                itemBuilder: (ctx, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text(exercise.muscleGroups
                        .map((mg) => mg.label)
                        .join(', ')),
                    onTap: () => onSelected(exercise),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
