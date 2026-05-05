import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/task_session_state.dart';

TaskSessionState createDefaultTaskSessionState({DateTime? now}) {
  final seedTasks = buildDefaultSeedTasks(now: now);

  return TaskSessionState(
    tasks: seedTasks,
    catalogItems: defaultSeedCatalogItems,
    totalXp: 0,
    stats: CharacterStats.zero,
    potionChargeCategories: [
      for (final task in seedTasks)
        if (task.isCompleted) task.category,
    ],
  );
}
