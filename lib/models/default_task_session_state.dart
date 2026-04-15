import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/task_session_state.dart';

TaskSessionState createDefaultTaskSessionState() {
  return TaskSessionState(
    tasks: defaultSeedTasks,
    catalogItems: defaultSeedCatalogItems,
    totalXp: 0,
    stats: CharacterStats.zero,
    potionChargeCategories: [
      for (final task in defaultSeedTasks)
        if (task.isCompleted) task.category,
    ],
  );
}
