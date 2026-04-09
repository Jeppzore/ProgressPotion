import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progress_potion/app/progress_potion_app.dart';
import 'package:progress_potion/screens/home/home_screen.dart';

void main() {
  testWidgets('renders the home loop with potion progress and tasks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ProgressPotionApp());
    await tester.pumpAndSettle();

    expect(find.text('ProgressPotion'), findsOneWidget);
    expect(find.text('Potion progress'), findsOneWidget);
    expect(find.text('Active Tasks'), findsOneWidget);
    expect(find.text('10 XP earned'), findsOneWidget);
  });

  testWidgets('adds a task from the add task screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ProgressPotionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Add task'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task title'),
      'Write release summary',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Keep the update crisp.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Write release summary'), findsOneWidget);

    final homeScreen = tester.widget<HomeScreen>(find.byType(HomeScreen));
    expect(homeScreen.taskController.totalCount, 4);
    expect(
      homeScreen.taskController.activeTasks.first.title,
      'Write release summary',
    );
  });

  testWidgets('completing a task moves it to completed and updates progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ProgressPotionApp());
    await tester.pumpAndSettle();

    final homeScreen = tester.widget<HomeScreen>(find.byType(HomeScreen));
    expect(homeScreen.taskController.xp, 10);

    final completeButton = find.widgetWithText(FilledButton, 'Complete').first;
    await tester.ensureVisible(completeButton);
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(homeScreen.taskController.completedCount, 2);
    expect(homeScreen.taskController.xp, 20);
    expect(
      homeScreen.taskController.completedTasks.any(
        (task) => task.title == 'Refill water flask',
      ),
      isTrue,
    );
  });

  testWidgets('shows empty state when all active tasks are completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ProgressPotionApp());
    await tester.pumpAndSettle();

    final homeScreen = tester.widget<HomeScreen>(find.byType(HomeScreen));

    while (find.widgetWithText(FilledButton, 'Complete').evaluate().isNotEmpty) {
      final completeButton = find.widgetWithText(FilledButton, 'Complete').first;
      await tester.ensureVisible(completeButton);
      await tester.tap(completeButton);
      await tester.pumpAndSettle();
    }

    expect(homeScreen.taskController.activeTasks, isEmpty);
    expect(homeScreen.taskController.xp, 30);

    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(find.text('No active tasks'), findsOneWidget);
  });
}
