import 'package:flutter_test/flutter_test.dart';
import 'package:im_muslim/features/khatmah/domain/models/khatmah_enums.dart';
import 'package:im_muslim/features/khatmah/domain/services/khatmah_planner_service.dart';

void main() {
  group('KhatmahPlannerService', () {
    const service = KhatmahPlannerService();

    test('caps days to remaining pages to avoid zero-page tasks', () {
      final tasks = service.generateDailyTasks(
        planId: 'plan_test',
        startDate: DateTime(2026, 2, 21),
        type: KhatmahPlanType.fixedDays,
        startPage: 604,
        endPage: 604,
        targetDays: 30,
      );

      expect(tasks, hasLength(1));
      expect(tasks.first.fromPage, 604);
      expect(tasks.first.toPage, 604);
      expect(tasks.first.totalPages, 1);
    });

    test('distributes pages continuously with no gaps or overlaps', () {
      final tasks = service.generateDailyTasks(
        planId: 'plan_full',
        startDate: DateTime(2026, 2, 21),
        type: KhatmahPlanType.fixedDays,
        startPage: 1,
        endPage: 604,
        targetDays: 30,
      );

      expect(tasks, hasLength(30));
      expect(tasks.first.fromPage, 1);
      expect(tasks.last.toPage, 604);

      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        expect(task.fromPage <= task.toPage, isTrue);
        if (i == 0) continue;
        final prev = tasks[i - 1];
        expect(task.fromPage, prev.toPage + 1);
      }

      final coveredPages = tasks.fold<int>(
        0,
        (sum, task) => sum + task.totalPages,
      );
      expect(coveredPages, 604);
    });
  });
}
