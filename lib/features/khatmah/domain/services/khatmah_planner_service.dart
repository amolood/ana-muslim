import '../models/khatmah_daily_task.dart';
import '../models/khatmah_enums.dart';

class KhatmahPlannerService {
  const KhatmahPlannerService();

  static const int mushafPagesCount = 604;
  static const int openPlanDailyPages = 20;

  List<KhatmahDailyTask> generateDailyTasks({
    required String planId,
    required DateTime startDate,
    required KhatmahPlanType type,
    required int startPage,
    required int endPage,
    required int? targetDays,
  }) {
    final normalizedStartDate = _dateOnly(startDate);
    final clampedStartPage = startPage.clamp(1, mushafPagesCount);
    final clampedEndPage = endPage.clamp(clampedStartPage, mushafPagesCount);

    final totalPages = clampedEndPage - clampedStartPage + 1;
    if (totalPages <= 0) return const [];

    int days;

    if (type == KhatmahPlanType.open) {
      days = (totalPages / openPlanDailyPages).ceil();
      if (days < 1) days = 1;
    } else {
      days = (targetDays ?? 30).clamp(1, 365);
    }

    if (days > totalPages) {
      // Prevent zero-page tasks when requested days exceed remaining pages.
      days = totalPages;
    }

    final base = totalPages ~/ days;
    final remainder = totalPages % days;

    final tasks = <KhatmahDailyTask>[];
    var currentFromPage = clampedStartPage;
    final now = DateTime.now();

    for (var dayIndex = 0; dayIndex < days; dayIndex++) {
      final pagesForDay = base + (dayIndex < remainder ? 1 : 0);
      final toPage = currentFromPage + pagesForDay - 1;
      final taskDate = normalizedStartDate.add(Duration(days: dayIndex));
      final task = KhatmahDailyTask(
        id: _taskId(planId, dayIndex + 1, taskDate),
        planId: planId,
        dayIndex: dayIndex + 1,
        date: taskDate,
        fromPage: currentFromPage,
        toPage: toPage,
        completed: false,
        createdAt: now,
      );
      tasks.add(task);
      currentFromPage = toPage + 1;
    }

    return tasks;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _taskId(String planId, int dayIndex, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${planId}_$dayIndex-$y$m$d';
  }
}
