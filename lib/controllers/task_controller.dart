import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/services/task_service.dart';

class TaskController extends ChangeNotifier {
  TaskController({required TaskService taskService}) : _taskService = taskService;

  static const int xpPerCompletedTask = 10;

  final TaskService _taskService;

  bool _isLoading = true;
  Object? _error;
  List<Task> _tasks = const [];

  bool get isLoading => _isLoading;
  Object? get error => _error;
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  List<Task> get activeTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  int get totalCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get xp => completedCount * xpPerCompletedTask;
  double get potionProgress => totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.listTasks();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String description = '',
  }) async {
    final task = await _taskService.addTask(
      title: title.trim(),
      description: description.trim(),
    );
    _tasks = [task, ..._tasks];
    notifyListeners();
  }

  Future<void> completeTask(String id) async {
    final currentIndex = _tasks.indexWhere((task) => task.id == id);
    if (currentIndex == -1 || _tasks[currentIndex].isCompleted) {
      return;
    }

    final updatedTask = await _taskService.completeTask(id);
    if (updatedTask == null) {
      return;
    }

    _tasks = [
      for (final task in _tasks)
        if (task.id == id) updatedTask else task,
    ];
    notifyListeners();
  }
}
