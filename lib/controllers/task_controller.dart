import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/default_task_session_state.dart';
import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/models/task_session_state.dart';
import 'package:progress_potion/services/task_service.dart';

class TaskController extends ChangeNotifier {
  TaskController({required TaskService taskService})
    : _taskService = taskService;

  static const int potionCapacity = 3;
  static const int potionRewardXp = 30;
  static const int varietyBonusXpPerCategory = 5;

  final TaskService _taskService;

  bool _isLoading = true;
  Object? _error;
  List<Task> _tasks = const [];
  final Set<String> _completingTaskIds = <String>{};
  bool _isClaimingPotionReward = false;
  List<TaskCategory> _potionChargeCategories = const [];
  int _totalXp = 0;
  CharacterStats _stats = CharacterStats.zero;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  List<Task> get activeTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  int get totalCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get potionChargeCount => _potionChargeCategories.length;
  UnmodifiableListView<TaskCategory> get potionChargeCategories {
    return UnmodifiableListView(_potionChargeCategories);
  }

  UnmodifiableListView<TaskCategory> get currentPotionCategories {
    return UnmodifiableListView(_currentPotionCategories.toList());
  }

  int get totalXp => _totalXp;
  int get xp => totalXp;
  CharacterStats get stats => _stats;
  bool get canDrinkPotion => potionChargeCount >= potionCapacity;
  int get currentPotionUniqueCategoryCount {
    return _currentPotionCategories.toSet().length;
  }

  int get currentPotionVarietyBonusXp {
    return currentPotionUniqueCategoryCount * varietyBonusXpPerCategory;
  }

  double get potionProgress {
    return (potionChargeCount / potionCapacity).clamp(0, 1).toDouble();
  }

  Iterable<TaskCategory> get _currentPotionCategories {
    return _potionChargeCategories.take(potionCapacity);
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final state = await _taskService.loadState();
      _replaceState(state);
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required TaskCategory category,
    String description = '',
  }) async {
    final task = Task(
      id: _slugify(title, _tasks.length + 1),
      title: title.trim(),
      category: category,
      description: description.trim(),
    );

    await _saveAndApplyState(
      TaskSessionState(
        tasks: [task, ..._tasks],
        totalXp: _totalXp,
        stats: _stats,
        potionChargeCategories: _potionChargeCategories,
      ),
    );
  }

  Future<void> completeTask(String id) async {
    final currentIndex = _tasks.indexWhere((task) => task.id == id);
    if (currentIndex == -1 ||
        _tasks[currentIndex].isCompleted ||
        _completingTaskIds.contains(id)) {
      return;
    }

    _completingTaskIds.add(id);

    try {
      final updatedTask = _tasks[currentIndex].copyWith(isCompleted: true);
      final nextTasks = [
        for (final task in _tasks)
          if (task.id == id) updatedTask else task,
      ];
      final nextPotionChargeCategories = [
        ..._potionChargeCategories,
        updatedTask.category,
      ];

      await _saveAndApplyState(
        TaskSessionState(
          tasks: nextTasks,
          totalXp: _totalXp,
          stats: _stats,
          potionChargeCategories: nextPotionChargeCategories,
        ),
      );
    } finally {
      _completingTaskIds.remove(id);
    }
  }

  Future<PotionRewardResult?> drinkPotion() async {
    if (!canDrinkPotion || _isClaimingPotionReward) {
      return null;
    }

    _isClaimingPotionReward = true;

    try {
      final consumedCategories = _currentPotionCategories.toList();
      final uniqueCategoryCount = consumedCategories.toSet().length;
      final statGains = CharacterStats.fromCategories(consumedCategories);
      final result = PotionRewardResult(
        baseXp: potionRewardXp,
        varietyBonusXp: uniqueCategoryCount * varietyBonusXpPerCategory,
        uniqueCategoryCount: uniqueCategoryCount,
        statGains: statGains,
      );

      final nextPotionChargeCategories = _potionChargeCategories
          .skip(potionCapacity)
          .toList();
      await _saveAndApplyState(
        TaskSessionState(
          tasks: _tasks,
          totalXp: _totalXp + result.totalXp,
          stats: _stats.add(statGains),
          potionChargeCategories: nextPotionChargeCategories,
        ),
      );
      return result;
    } finally {
      _isClaimingPotionReward = false;
    }
  }

  Future<void> grantAdminProgress({
    required int xpDelta,
    required CharacterStats statDelta,
  }) async {
    if (xpDelta <= 0 && statDelta.isZero) {
      throw ArgumentError(
        'Admin progress must include a positive XP delta or stat gain.',
      );
    }
    if (xpDelta < 0) {
      throw ArgumentError.value(
        xpDelta,
        'xpDelta',
        'XP delta must be positive.',
      );
    }
    _validateNonNegativeStats(statDelta);

    await _saveAndApplyState(
      TaskSessionState(
        tasks: _tasks,
        totalXp: _totalXp + xpDelta,
        stats: _stats.add(statDelta),
        potionChargeCategories: _potionChargeCategories,
      ),
    );
  }

  Future<void> addAdminPotionCharge(TaskCategory category) async {
    await _saveAndApplyState(
      TaskSessionState(
        tasks: _tasks,
        totalXp: _totalXp,
        stats: _stats,
        potionChargeCategories: [..._potionChargeCategories, category],
      ),
    );
  }

  Future<void> resetProgressToSeedState() async {
    await _saveAndApplyState(createDefaultTaskSessionState());
  }

  void _replaceState(TaskSessionState state) {
    _tasks = state.tasks;
    _potionChargeCategories = state.potionChargeCategories;
    _totalXp = state.totalXp;
    _stats = state.stats;
  }

  Future<void> _saveAndApplyState(TaskSessionState state) async {
    await _taskService.saveState(state);
    _replaceState(state);
    notifyListeners();
  }

  void _validateNonNegativeStats(CharacterStats stats) {
    for (final entry in stats.entries) {
      if (entry.value < 0) {
        throw ArgumentError.value(
          entry.value,
          entry.key.name,
          'Stat delta must be non-negative.',
        );
      }
    }
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

class PotionRewardResult {
  const PotionRewardResult({
    required this.baseXp,
    required this.varietyBonusXp,
    required this.uniqueCategoryCount,
    required this.statGains,
  });

  final int baseXp;
  final int varietyBonusXp;
  final int uniqueCategoryCount;
  final CharacterStats statGains;

  int get totalXp => baseXp + varietyBonusXp;
}
