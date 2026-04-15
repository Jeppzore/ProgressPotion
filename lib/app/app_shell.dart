import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/screens/admin_tools/admin_tools_screen.dart';
import 'package:progress_potion/screens/add_task/add_task_screen.dart';
import 'package:progress_potion/screens/home/home_screen.dart';
import 'package:progress_potion/services/task_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final TaskController _taskController;
  late final Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _taskController = TaskController(taskService: widget.taskService);
    _initialLoad = _taskController.loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _openAddTaskScreen() async {
    await _initialLoad;
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddTaskScreen(taskController: _taskController),
      ),
    );
  }

  Future<void> _openAdminTools() async {
    if (!kDebugMode) {
      return;
    }

    await _initialLoad;
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminToolsScreen(taskController: _taskController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: kDebugMode
            ? GestureDetector(
                key: const ValueKey('admin-tools-entry'),
                behavior: HitTestBehavior.opaque,
                onLongPress: _openAdminTools,
                child: const Text('ProgressPotion'),
              )
            : const Text('ProgressPotion'),
      ),
      body: HomeScreen(taskController: _taskController),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskScreen,
        icon: const Icon(Icons.add_task),
        label: const Text('Task library'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
