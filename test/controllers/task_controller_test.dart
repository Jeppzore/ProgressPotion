import 'package:flutter_test/flutter_test.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/services/in_memory_task_service.dart';

void main() {
  late TaskController controller;

  setUp(() {
    controller = TaskController(taskService: InMemoryTaskService());
  });

  test('loadTasks exposes seeded progress metrics', () async {
    await controller.loadTasks();

    expect(controller.totalCount, 3);
    expect(controller.completedCount, 1);
    expect(controller.xp, 10);
    expect(controller.potionProgress, closeTo(1 / 3, 0.0001));
  });

  test('addTask grows the active task list', () async {
    await controller.loadTasks();

    await controller.addTask(
      title: 'Draft release notes',
      description: 'Keep the summary short and clear.',
    );

    expect(controller.totalCount, 4);
    expect(
      controller.activeTasks.any((task) => task.title == 'Draft release notes'),
      isTrue,
    );
  });

  test('completeTask updates completion metrics only once', () async {
    await controller.loadTasks();

    await controller.completeTask('refill-water-flask');
    await controller.completeTask('refill-water-flask');

    expect(controller.completedCount, 2);
    expect(controller.xp, 20);
    expect(controller.potionProgress, closeTo(2 / 3, 0.0001));
  });
}
