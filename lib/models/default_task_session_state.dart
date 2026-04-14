import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/models/task_session_state.dart';

const List<Task> _defaultTasks = [
  Task(
    id: 'brew-morning-focus',
    title: 'Brew morning focus',
    category: TaskCategory.work,
    description: 'Choose the one win that matters most before opening chat.',
    isCompleted: true,
  ),
  Task(
    id: 'refill-water-flask',
    title: 'Refill water flask',
    category: TaskCategory.fitness,
    description:
        'Set yourself up for the next work block with one small reset.',
  ),
  Task(
    id: 'ship-one-tiny-step',
    title: 'Ship one tiny step',
    category: TaskCategory.hobby,
    description:
        'Finish something concrete, even if it only takes ten minutes.',
  ),
];

TaskSessionState createDefaultTaskSessionState() {
  return TaskSessionState(
    tasks: _defaultTasks,
    totalXp: 0,
    stats: CharacterStats.zero,
    potionChargeCategories: [
      for (final task in _defaultTasks)
        if (task.isCompleted) task.category,
    ],
  );
}
