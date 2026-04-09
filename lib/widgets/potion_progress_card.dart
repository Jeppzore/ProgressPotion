import 'package:flutter/material.dart';

class PotionProgressCard extends StatelessWidget {
  const PotionProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.xp,
    required this.progress,
  });

  final int completedCount;
  final int totalCount;
  final int xp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (progress * 100).round();

    return Semantics(
      label:
          'Potion progress, $completedCount of $totalCount tasks complete, $progressPercent percent',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF24584A), Color(0xFFDB9C42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Potion progress',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount tasks complete',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$xp XP earned',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete tasks to fill the potion and gain 10 XP each.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 18,
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$progressPercent% filled',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
