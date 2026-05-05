import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progress_potion/app/progress_potion_app.dart';
import 'package:progress_potion/models/character_stats.dart';
import 'package:progress_potion/models/task.dart';
import 'package:progress_potion/models/task_session_state.dart';
import 'package:progress_potion/services/in_memory_task_service.dart';

void main() {
  testWidgets('calendar keeps a fixed 42-cell grid across month lengths', (
    WidgetTester tester,
  ) async {
    for (final month in [1, 2, 4, 5]) {
      await _pumpCalendarApp(tester);
      await _goToMonth(tester, month);
      expect(_calendarDayCells(), findsNWidgets(42));
    }
  });

  testWidgets('calendar shows muted out-of-month filler cells', (
    WidgetTester tester,
  ) async {
    await _pumpCalendarApp(tester);

    final visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final weekdayFromMonday = firstDayOfMonth.weekday - DateTime.monday;
    final firstVisibleDay = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1 - weekdayFromMonday,
    );
    final lastDayOfMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    );

    final outsideDate = firstVisibleDay.month == visibleMonth.month
        ? DateTime(lastDayOfMonth.year, lastDayOfMonth.month, lastDayOfMonth.day + 1)
        : firstVisibleDay;
    final inMonthDate = DateTime(visibleMonth.year, visibleMonth.month, 1);

    final outsideCell = _calendarCell(outsideDate);
    final inMonthCell = _calendarCell(inMonthDate);
    final outsideColor =
        (tester.widget<Container>(outsideCell).decoration! as BoxDecoration)
            .color!;
    final inMonthColor =
        (tester.widget<Container>(inMonthCell).decoration! as BoxDecoration)
            .color!;

    expect(outsideColor.a, lessThan(inMonthColor.a));
  });

  testWidgets('calendar caps day dots at four unique categories', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final completedDay = DateTime(today.year, today.month, 15, 9);
    final state = TaskSessionState(
      tasks: [
        Task(
          id: 'fitness-task',
          title: 'Fitness task',
          category: TaskCategory.fitness,
          isCompleted: true,
          completedAt: completedDay,
        ),
        Task(
          id: 'study-task',
          title: 'Study task',
          category: TaskCategory.study,
          isCompleted: true,
          completedAt: completedDay,
        ),
        Task(
          id: 'work-task',
          title: 'Work task',
          category: TaskCategory.work,
          isCompleted: true,
          completedAt: completedDay,
        ),
        Task(
          id: 'hobby-task',
          title: 'Hobby task',
          category: TaskCategory.hobby,
          isCompleted: true,
          completedAt: completedDay,
        ),
        Task(
          id: 'home-task',
          title: 'Home task',
          category: TaskCategory.home,
          isCompleted: true,
          completedAt: completedDay,
        ),
      ],
      catalogItems: const [],
      totalXp: 0,
      stats: CharacterStats.zero,
      potionChargeCategories: const [],
    );

    await _pumpCalendarApp(
      tester,
      taskService: InMemoryTaskService(initialState: state),
    );

    final dayKey = _dateKey(completedDay);
    expect(find.byKey(ValueKey('calendar-dot-$dayKey-fitness')), findsOneWidget);
    expect(find.byKey(ValueKey('calendar-dot-$dayKey-study')), findsOneWidget);
    expect(find.byKey(ValueKey('calendar-dot-$dayKey-work')), findsOneWidget);
    expect(find.byKey(ValueKey('calendar-dot-$dayKey-hobby')), findsOneWidget);
    expect(find.byKey(ValueKey('calendar-dot-$dayKey-home')), findsNothing);

    final emptyDayKey = _dateKey(DateTime(today.year, today.month, 16));
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> && key.value.startsWith('calendar-dot-$emptyDayKey-');
      }),
      findsNothing,
    );
  });
}

Future<void> _pumpCalendarApp(
  WidgetTester tester, {
  InMemoryTaskService? taskService,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: ProgressPotionApp(taskService: taskService ?? InMemoryTaskService()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();
}

Future<void> _goToMonth(WidgetTester tester, int targetMonth) async {
  var visibleMonth = DateTime.now().month;
  while (visibleMonth < targetMonth) {
    await tester.tap(find.byKey(const ValueKey('calendar-next-month')));
    await tester.pumpAndSettle();
    visibleMonth += 1;
  }
  while (visibleMonth > targetMonth) {
    await tester.tap(find.byKey(const ValueKey('calendar-previous-month')));
    await tester.pumpAndSettle();
    visibleMonth -= 1;
  }
}

Finder _calendarDayCells() {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('calendar-day-');
  });
}

Finder _calendarCell(DateTime date) {
  return find.byKey(ValueKey('calendar-day-${_dateKey(date)}'));
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
