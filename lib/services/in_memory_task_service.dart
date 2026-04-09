import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/services/task_service.dart';

class InMemoryTaskService implements TaskService {
  InMemoryTaskService() : _tasks = List<Task>.from(_seedTasks);

  static const List<Task> _seedTasks = [
    Task(
      id: 'brew-morning-focus',
      title: 'Brew morning focus',
      description: 'Choose the one win that matters most before opening chat.',
      isCompleted: true,
    ),
    Task(
      id: 'refill-water-flask',
      title: 'Refill water flask',
      description: 'Set yourself up for the next work block with one small reset.',
    ),
    Task(
      id: 'ship-one-tiny-step',
      title: 'Ship one tiny step',
      description: 'Finish something concrete, even if it only takes ten minutes.',
    ),
  ];

  final List<Task> _tasks;

  @override
  Future<Task> addTask({
    required String title,
    String description = '',
  }) async {
    final task = Task(
      id: _slugify(title, _tasks.length + 1),
      title: title,
      description: description,
    );
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<Task?> completeTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return null;
    }

    final current = _tasks[index];
    if (current.isCompleted) {
      return current;
    }

    final updated = current.copyWith(isCompleted: true);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<List<Task>> listTasks() async {
    return List<Task>.unmodifiable(_tasks);
  }

  String _slugify(String title, int fallbackSuffix) {
    final normalized = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    if (normalized.isEmpty) {
      return 'task-$fallbackSuffix';
    }

    if (_tasks.every((task) => task.id != normalized)) {
      return normalized;
    }

    return '$normalized-$fallbackSuffix';
  }
}
