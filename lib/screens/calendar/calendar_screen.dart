import 'package:flutter/material.dart';
import 'package:progress_potion/controllers/task_controller.dart';
import 'package:progress_potion/core/theme/task_category_palette.dart';
import 'package:progress_potion/models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.taskController});

  final TaskController taskController;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final int _currentYear;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _currentYear = today.year;
    _visibleMonth = DateTime(today.year, today.month);
  }

  bool get _canGoToPreviousMonth => _visibleMonth.month > DateTime.january;
  bool get _canGoToNextMonth => _visibleMonth.month < DateTime.december;

  void _showPreviousMonth() {
    if (!_canGoToPreviousMonth) {
      return;
    }

    setState(() {
      _visibleMonth = DateTime(_currentYear, _visibleMonth.month - 1);
    });
  }

  void _showNextMonth() {
    if (!_canGoToNextMonth) {
      return;
    }

    setState(() {
      _visibleMonth = DateTime(_currentYear, _visibleMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.taskController,
      builder: (context, _) {
        if (widget.taskController.error != null) {
          return const _AsyncStateMessage(
            icon: Icons.warning_amber_rounded,
            title: 'The calendar rune fizzled out.',
            message: 'We could not load activity for this session.',
          );
        }

        if (widget.taskController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final monthSummary = widget.taskController.calendarMonthSummary(
          _visibleMonth,
        );

        return DecoratedBox(
          key: const ValueKey('calendar-screen'),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F2E9), Color(0xFFF1E8DA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                left: -50,
                child: _BackdropGlow(
                  size: 260,
                  color: const Color(0x224878D9),
                ),
              ),
              Positioned(
                top: 120,
                right: -60,
                child: _BackdropGlow(
                  size: 240,
                  color: const Color(0x224F9770),
                ),
              ),
              SafeArea(
                top: false,
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 700;
                    final gridHeight = _calendarGridHeight(
                      constraints.maxWidth - 32,
                      compact: compact,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        compact ? 12 : 16,
                        16,
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CalendarHeader(
                            visibleMonth: _visibleMonth,
                            canGoToPreviousMonth: _canGoToPreviousMonth,
                            canGoToNextMonth: _canGoToNextMonth,
                            onPreviousMonth: _showPreviousMonth,
                            onNextMonth: _showNextMonth,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 10 : 12),
                          _WeekdayHeader(compact: compact),
                          SizedBox(height: compact ? 8 : 10),
                          SizedBox(
                            height: gridHeight,
                            child: _CalendarMonthGrid(
                              summaries: monthSummary,
                              compact: compact,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 12),
                          _CalendarLegend(compact: compact),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.visibleMonth,
    required this.canGoToPreviousMonth,
    required this.canGoToNextMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.compact,
  });

  final DateTime visibleMonth;
  final bool canGoToPreviousMonth;
  final bool canGoToNextMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);

    return Row(
      children: [
        IconButton.filledTonal(
          key: const ValueKey('calendar-previous-month'),
          onPressed: canGoToPreviousMonth ? onPreviousMonth : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous month',
        ),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: compact ? 22 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: compact ? 2 : 4),
              Text(
                localizations.formatMonthYear(visibleMonth),
                key: const ValueKey('calendar-month-label'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: compact ? 15 : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        IconButton.filledTonal(
          key: const ValueKey('calendar-next-month'),
          onPressed: canGoToNextMonth ? onNextMonth : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next month',
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdayLabels = _mondayFirstWeekdayLabels(
      MaterialLocalizations.of(context),
    );

    return Row(
      children: [
        for (final label in weekdayLabels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: compact ? 11 : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.summaries,
    required this.compact,
  });

  final List<CalendarDaySummary> summaries;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('calendar-grid'),
      children: [
        for (var row = 0; row < 6; row += 1)
          Expanded(
            child: Row(
              children: [
                for (var column = 0; column < 7; column += 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: _CalendarDayCell(
                        summary: summaries[(row * 7) + column],
                        compact: compact,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.summary,
    required this.compact,
  });

  final CalendarDaySummary summary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final isToday = summary.date == normalizedToday;
    final isVisibleMonth = summary.isInDisplayedMonth;
    final dotCategories = summary.categories.take(4).toList();
    final keySuffix = _calendarDateKey(summary.date);

    return Semantics(
      label: _semanticLabel(context),
      container: true,
      child: Container(
        key: ValueKey('calendar-day-$keySuffix'),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 6,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: isVisibleMonth
              ? Colors.white.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          border: Border.all(
            color: isToday
                ? theme.colorScheme.primary.withValues(alpha: 0.55)
                : theme.colorScheme.outline.withValues(
                    alpha: isVisibleMonth ? 0.22 : 0.12,
                  ),
            width: isToday ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${summary.date.day}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: compact ? 13 : 14,
                color: isVisibleMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.82,
                      ),
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            if (dotCategories.isNotEmpty)
              Align(
                alignment: Alignment.bottomLeft,
                child: Wrap(
                  spacing: compact ? 2 : 3,
                  runSpacing: compact ? 2 : 3,
                  children: [
                    for (final category in dotCategories)
                      Container(
                        key: ValueKey(
                          'calendar-dot-$keySuffix-${category.name}',
                        ),
                        width: compact ? 5.5 : 6.5,
                        height: compact ? 5.5 : 6.5,
                        decoration: BoxDecoration(
                          color: taskCategoryColor(category),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _semanticLabel(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatFullDate(summary.date);

    if (!summary.isInDisplayedMonth) {
      return '$dateLabel, outside the displayed month';
    }

    if (summary.categories.isEmpty) {
      return '$dateLabel, no completed tasks';
    }

    final categories = summary.categories
        .map((category) => category.displayName)
        .join(', ');
    return '$dateLabel, ${summary.completedTasks.length} completed tasks, '
        '$categories';
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'Legend',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          for (final category in TaskCategory.values) ...[
            _LegendChip(category: category, compact: compact),
            SizedBox(width: compact ? 6 : 8),
          ],
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.category,
    required this.compact,
  });

  final TaskCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: taskCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            category.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: compact ? 11 : null,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

List<String> _mondayFirstWeekdayLabels(MaterialLocalizations localizations) {
  final labels = localizations.narrowWeekdays;
  return [
    labels[DateTime.monday % 7],
    labels[DateTime.tuesday % 7],
    labels[DateTime.wednesday % 7],
    labels[DateTime.thursday % 7],
    labels[DateTime.friday % 7],
    labels[DateTime.saturday % 7],
    labels[DateTime.sunday % 7],
  ];
}

String _calendarDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

double _calendarGridHeight(double width, {required bool compact}) {
  final normalizedWidth = width.clamp(280.0, 560.0);
  final cellWidth = normalizedWidth / 7;
  final cellHeight = compact ? cellWidth * 0.9 : cellWidth;
  return cellHeight * 6;
}
