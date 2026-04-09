import 'package:flutter/material.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/widgets/potion_progress_card.dart';
import 'package:progress_potion/widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.taskController});

  final TaskController taskController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskController,
      builder: (context, _) {
        if (taskController.error != null) {
          return const _AsyncStateMessage(
            icon: Icons.warning_amber_rounded,
            title: 'The cauldron needs a reset.',
            message: 'We could not load tasks for this session.',
          );
        }

        if (taskController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeTasks = taskController.activeTasks;
        final completedTasks = taskController.completedTasks;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            PotionProgressCard(
              completedCount: taskController.completedCount,
              totalCount: taskController.totalCount,
              xp: taskController.xp,
              progress: taskController.potionProgress,
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Active Tasks',
              subtitle: activeTasks.isEmpty
                  ? 'No active tasks yet. Add one to start brewing.'
                  : 'Complete tasks to fill the potion and gain 10 XP each.',
            ),
            const SizedBox(height: 12),
            if (activeTasks.isEmpty)
              const _EmptyStateCard(
                title: 'No active tasks',
                message: 'Tap Add task to brew a fresh objective for this session.',
              )
            else
              for (final task in activeTasks) ...[
                TaskTile(
                  task: task,
                  onComplete: () => taskController.completeTask(task.id),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Completed Tasks',
              subtitle: 'Completed tasks will appear here once you finish one.',
            ),
            const SizedBox(height: 12),
            if (completedTasks.isEmpty)
              const _EmptyStateCard(
                title: 'Nothing completed yet',
                message: 'Complete an active task to earn XP and bottle progress.',
              )
            else
              for (final task in completedTasks) ...[
                TaskTile(task: task),
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AsyncStateMessage extends StatelessWidget {
  const _AsyncStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
