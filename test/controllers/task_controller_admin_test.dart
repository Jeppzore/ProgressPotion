import 'package:flutter_test/flutter_test.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/default_task_session_state.dart';
import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/services/in_memory_task_service.dart';

void main() {
  test('grantAdminProgress adds XP without changing potion or tasks', () async {
    final controller = TaskController(taskService: InMemoryTaskService());
    await controller.loadTasks();

    final originalTaskIds = controller.tasks.map((task) => task.id).toList();
    final originalPotionCategories = controller.potionChargeCategories.toList();

    await controller.grantAdminProgress(
      xpDelta: 25,
      statDelta: CharacterStats.zero,
    );

    expect(controller.totalXp, 25);
    expect(controller.stats, CharacterStats.zero);
    expect(controller.tasks.map((task) => task.id), originalTaskIds);
    expect(controller.potionChargeCategories, originalPotionCategories);
    expect(controller.catalogItems, hasLength(3));
  });

  test(
    'grantAdminProgress adds stats and persists across controllers',
    () async {
      final service = InMemoryTaskService();
      final firstController = TaskController(taskService: service);
      await firstController.loadTasks();

      await firstController.grantAdminProgress(
        xpDelta: 10,
        statDelta: const CharacterStats(
          strength: 2,
          vitality: 1,
          wisdom: 3,
          mindfulness: 4,
        ),
      );
      await firstController.grantAdminProgress(
        xpDelta: 5,
        statDelta: const CharacterStats(
          strength: 1,
          vitality: 0,
          wisdom: 0,
          mindfulness: 2,
        ),
      );

      final secondController = TaskController(taskService: service);
      await secondController.loadTasks();

      expect(secondController.totalXp, 15);
      expect(
        secondController.stats,
        const CharacterStats(
          strength: 3,
          vitality: 1,
          wisdom: 3,
          mindfulness: 6,
        ),
      );
      expect(secondController.potionChargeCategories, [TaskCategory.work]);
      expect(secondController.catalogItems, hasLength(3));
    },
  );

  test(
    'addAdminPotionCharge appends one category without granting XP',
    () async {
      final controller = TaskController(taskService: InMemoryTaskService());
      await controller.loadTasks();

      await controller.addAdminPotionCharge(TaskCategory.home);
      await controller.addAdminPotionCharge(TaskCategory.study);

      expect(controller.totalXp, 0);
      expect(controller.stats, CharacterStats.zero);
      expect(controller.potionChargeCategories, [
        TaskCategory.work,
        TaskCategory.home,
        TaskCategory.study,
      ]);
      expect(controller.canDrinkPotion, isTrue);
    },
  );

  test(
    'resetProgressToSeedState restores the shared seeded baseline',
    () async {
      final controller = TaskController(taskService: InMemoryTaskService());
      await controller.loadTasks();

      await controller.grantAdminProgress(
        xpDelta: 40,
        statDelta: const CharacterStats(
          strength: 1,
          vitality: 2,
          wisdom: 3,
          mindfulness: 4,
        ),
      );
      await controller.addAdminPotionCharge(TaskCategory.home);

      await controller.resetProgressToSeedState();

      final seedState = createDefaultTaskSessionState();
      expect(controller.tasks, seedState.tasks);
      expect(controller.totalXp, seedState.totalXp);
      expect(controller.stats, seedState.stats);
      expect(controller.catalogItems, seedState.catalogItems);
      expect(
        controller.potionChargeCategories,
        seedState.potionChargeCategories,
      );
    },
  );

  test('grantAdminProgress rejects negative or empty deltas', () async {
    final controller = TaskController(taskService: InMemoryTaskService());
    await controller.loadTasks();

    expect(
      () => controller.grantAdminProgress(
        xpDelta: -1,
        statDelta: CharacterStats.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => controller.grantAdminProgress(
        xpDelta: 0,
        statDelta: CharacterStats.zero,
      ),
      throwsArgumentError,
    );
  });
}
