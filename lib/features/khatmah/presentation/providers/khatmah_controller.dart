import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../data/repositories/local_khatmah_repository.dart';
import '../../domain/models/khatmah_daily_task.dart';
import '../../domain/models/khatmah_enums.dart';
import '../../domain/models/khatmah_plan.dart';
import '../../domain/models/khatmah_reading_session.dart';
import '../../domain/repositories/khatmah_repository.dart';
import '../../domain/services/khatmah_notification_service.dart';
import '../../domain/services/khatmah_planner_service.dart';

final khatmahPlannerServiceProvider = Provider<KhatmahPlannerService>(
  (ref) => const KhatmahPlannerService(),
);

final khatmahNotificationServiceProvider = Provider<KhatmahNotificationService>(
  (ref) => const KhatmahNotificationService(),
);

final khatmahControllerProvider =
    AsyncNotifierProvider<KhatmahController, KhatmahViewState>(
      KhatmahController.new,
    );

class KhatmahController extends AsyncNotifier<KhatmahViewState> {
  Timer? _dayRolloverTimer;

  KhatmahRepository get _repo => ref.read(khatmahRepositoryProvider);
  KhatmahPlannerService get _planner => ref.read(khatmahPlannerServiceProvider);
  KhatmahNotificationService get _notifications =>
      ref.read(khatmahNotificationServiceProvider);

  @override
  Future<KhatmahViewState> build() async {
    _scheduleDayRolloverRefresh();
    ref.onDispose(() => _dayRolloverTimer?.cancel());
    return _loadState();
  }

  Future<void> refreshState() async {
    state = AsyncData(await _loadState());
  }

  void _scheduleDayRolloverRefresh() {
    _dayRolloverTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now) + const Duration(seconds: 1);
    _dayRolloverTimer = Timer(delay, () async {
      await refreshState();
      _scheduleDayRolloverRefresh();
    });
  }

  Future<void> createPlan(KhatmahPlanDraft draft) async {
    final now = DateTime.now();
    final startDate = _dateOnly(draft.startDate);
    final lastReadPage = ref.read(lastReadPageProvider).clamp(1, 604);

    final startPage = switch (draft.startPoint) {
      KhatmahStartPointOption.firstPage => 1,
      KhatmahStartPointOption.lastReadPage => lastReadPage,
      KhatmahStartPointOption.customPage => (draft.customStartPage ?? 1).clamp(
        1,
        604,
      ),
    };

    int? targetDays = draft.targetDays;
    if (draft.type == KhatmahPlanType.ramadanPreset) {
      targetDays = 30;
    }
    if (draft.type == KhatmahPlanType.open) {
      targetDays = null;
    } else {
      targetDays = (targetDays ?? 30).clamp(1, 365);
      final totalPagesFromStart = 604 - startPage + 1;
      if (targetDays > totalPagesFromStart) {
        targetDays = totalPagesFromStart;
      }
    }

    final planId = 'kp_${now.millisecondsSinceEpoch}';
    final plan = KhatmahPlan(
      id: planId,
      type: draft.type,
      status: KhatmahPlanStatus.active,
      startDate: startDate,
      targetDays: targetDays,
      startPage: startPage,
      endPage: 604,
      divisionMode: draft.divisionMode,
      dailyReminderEnabled: draft.dailyReminderEnabled,
      reminderHour: draft.reminderHour,
      reminderMinute: draft.reminderMinute,
      carryMissedWird: draft.carryMissedWird,
      currentPage: startPage,
      createdAt: now,
      updatedAt: now,
    );

    final tasks = _planner.generateDailyTasks(
      planId: plan.id,
      startDate: plan.startDate,
      type: plan.type,
      startPage: plan.startPage,
      endPage: plan.endPage,
      targetDays: plan.targetDays,
    );

    await _repo.savePlan(plan);
    await _repo.saveDailyTasks(plan.id, tasks);
    await _notifications.scheduleDailyReminder(
      enabled: plan.dailyReminderEnabled,
      hour: plan.reminderHour,
      minute: plan.reminderMinute,
    );

    state = AsyncData(_computeViewState(plan, tasks));
  }

  Future<void> clearPlan() async {
    await _repo.clearPlan();
    await _notifications.cancelReminder();
    state = AsyncData(KhatmahViewState.empty());
  }

  Future<void> updateDurationFromCurrent(int targetDays) async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return;

    final tasks = current!.tasks;
    final now = DateTime.now();
    final today = _dateOnly(now);

    final completedTasks = tasks.where((task) => task.completed).toList();
    var highestCompletedPage = plan.startPage - 1;
    if (completedTasks.isNotEmpty) {
      completedTasks.sort((a, b) => a.toPage.compareTo(b.toPage));
      highestCompletedPage = completedTasks.last.toPage;
    }
    final currentReadPage = plan.currentPage > highestCompletedPage
        ? plan.currentPage
        : highestCompletedPage;
    final hasProgress =
        completedTasks.isNotEmpty || plan.currentPage > plan.startPage;
    final startFromPage = hasProgress
        ? (currentReadPage + 1).clamp(1, 604)
        : plan.startPage.clamp(1, 604);

    final totalPagesFromStart = 604 - startFromPage + 1;
    final normalizedTargetDays = targetDays.clamp(1, 365);
    final effectiveTargetDays = normalizedTargetDays > totalPagesFromStart
        ? totalPagesFromStart
        : normalizedTargetDays;

    final updatedPlan = plan.copyWith(
      type: KhatmahPlanType.fixedDays,
      targetDays: effectiveTargetDays,
      startDate: today,
      startPage: startFromPage,
      status: KhatmahPlanStatus.active,
      updatedAt: now,
      completedAt: null,
    );

    final regenerated = _planner.generateDailyTasks(
      planId: updatedPlan.id,
      startDate: updatedPlan.startDate,
      type: updatedPlan.type,
      startPage: updatedPlan.startPage,
      endPage: updatedPlan.endPage,
      targetDays: updatedPlan.targetDays,
    );

    await _repo.savePlan(updatedPlan);
    await _repo.saveDailyTasks(updatedPlan.id, regenerated);
    await _notifications.scheduleDailyReminder(
      enabled: updatedPlan.dailyReminderEnabled,
      hour: updatedPlan.reminderHour,
      minute: updatedPlan.reminderMinute,
    );

    state = AsyncData(_computeViewState(updatedPlan, regenerated));
  }

  Future<void> updateReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return;

    final updated = plan.copyWith(
      dailyReminderEnabled: enabled,
      reminderHour: hour.clamp(0, 23),
      reminderMinute: minute.clamp(0, 59),
      updatedAt: DateTime.now(),
    );

    await _repo.savePlan(updated);
    await _notifications.scheduleDailyReminder(
      enabled: enabled,
      hour: updated.reminderHour,
      minute: updated.reminderMinute,
    );
    state = AsyncData(_computeViewState(updated, current!.tasks));
  }

  Future<void> updateCarryMissedWird(bool enabled) async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return;

    final updated = plan.copyWith(
      carryMissedWird: enabled,
      updatedAt: DateTime.now(),
    );
    await _repo.savePlan(updated);
    state = AsyncData(_computeViewState(updated, current!.tasks));
  }

  Future<bool> syncFromReadingPage(int page) async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return false;

    final clampedPage = page.clamp(1, 604);
    final now = DateTime.now();
    final today = _dateOnly(now);

    var reachedTodayTarget = false;
    var changed = false;

    final updatedTasks = current!.tasks.map((task) {
      if (!task.completed && clampedPage >= task.toPage) {
        changed = true;
        if (_dateOnly(task.date) == today) {
          reachedTodayTarget = true;
        }
        return task.copyWith(
          completed: true,
          completedAt: now,
          completedByReading: true,
          manualCompletion: false,
        );
      }
      return task;
    }).toList();

    final highestRead = clampedPage > plan.currentPage
        ? clampedPage
        : plan.currentPage;
    var updatedPlan = plan.copyWith(currentPage: highestRead, updatedAt: now);

    if (highestRead >= updatedPlan.endPage) {
      updatedPlan = updatedPlan.copyWith(
        status: KhatmahPlanStatus.completed,
        completedAt: now,
      );
      changed = true;
    }

    if (changed || highestRead != plan.currentPage) {
      await _repo.savePlan(updatedPlan);
      await _repo.saveDailyTasks(updatedPlan.id, updatedTasks);
      await _repo.appendReadingSession(
        KhatmahReadingSession(
          id: 'ks_${now.microsecondsSinceEpoch}',
          planId: updatedPlan.id,
          page: clampedPage,
          recordedAt: now,
        ),
      );
      state = AsyncData(_computeViewState(updatedPlan, updatedTasks));
    }

    return reachedTodayTarget;
  }

  Future<bool> markTodayCompletedManual() async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return false;

    final today = _dateOnly(DateTime.now());
    var changed = false;
    var reachedPage = plan.currentPage;
    final now = DateTime.now();

    final updatedTasks = current!.tasks.map((task) {
      final taskDate = _dateOnly(task.date);
      final shouldComplete =
          !task.completed &&
          (plan.carryMissedWird ? !taskDate.isAfter(today) : taskDate == today);
      if (shouldComplete) {
        changed = true;
        reachedPage = task.toPage > reachedPage ? task.toPage : reachedPage;
        return task.copyWith(
          completed: true,
          completedAt: now,
          completedByReading: false,
          manualCompletion: true,
        );
      }
      return task;
    }).toList();

    if (!changed) return false;

    var updatedPlan = plan.copyWith(currentPage: reachedPage, updatedAt: now);

    if (reachedPage >= updatedPlan.endPage) {
      updatedPlan = updatedPlan.copyWith(
        status: KhatmahPlanStatus.completed,
        completedAt: now,
      );
    }

    await _repo.savePlan(updatedPlan);
    await _repo.saveDailyTasks(updatedPlan.id, updatedTasks);
    state = AsyncData(_computeViewState(updatedPlan, updatedTasks));
    return true;
  }

  Future<bool> markTaskCompletedById(String taskId) async {
    final current = state.asData?.value;
    final plan = current?.plan;
    if (plan == null) return false;

    final today = _dateOnly(DateTime.now());
    final now = DateTime.now();
    var changed = false;
    var reachedPage = plan.currentPage;

    final updatedTasks = current!.tasks.map((task) {
      if (task.id != taskId || task.completed) return task;
      final taskDate = _dateOnly(task.date);
      if (taskDate.isAfter(today)) return task;

      changed = true;
      reachedPage = task.toPage > reachedPage ? task.toPage : reachedPage;
      return task.copyWith(
        completed: true,
        completedAt: now,
        completedByReading: false,
        manualCompletion: true,
      );
    }).toList();

    if (!changed) return false;

    var updatedPlan = plan.copyWith(currentPage: reachedPage, updatedAt: now);
    if (reachedPage >= updatedPlan.endPage) {
      updatedPlan = updatedPlan.copyWith(
        status: KhatmahPlanStatus.completed,
        completedAt: now,
      );
    }

    await _repo.savePlan(updatedPlan);
    await _repo.saveDailyTasks(updatedPlan.id, updatedTasks);
    state = AsyncData(_computeViewState(updatedPlan, updatedTasks));
    return true;
  }

  Future<KhatmahViewState> _loadState() async {
    final plan = await _repo.getActivePlan();
    if (plan == null) {
      return KhatmahViewState.empty();
    }

    final tasks = await _repo.getDailyTasks(plan.id);
    final ensured = await _ensureOpenPlanTodayTask(plan, tasks);
    return _computeViewState(ensured.plan, ensured.tasks);
  }

  Future<_PlanAndTasks> _ensureOpenPlanTodayTask(
    KhatmahPlan plan,
    List<KhatmahDailyTask> tasks,
  ) async {
    if (plan.type != KhatmahPlanType.open ||
        plan.status != KhatmahPlanStatus.active) {
      return _PlanAndTasks(plan: plan, tasks: tasks);
    }

    final today = _dateOnly(DateTime.now());
    if (today.isBefore(_dateOnly(plan.startDate))) {
      return _PlanAndTasks(plan: plan, tasks: tasks);
    }
    final hasToday = tasks.any((task) => _dateOnly(task.date) == today);
    if (hasToday || plan.currentPage >= plan.endPage) {
      return _PlanAndTasks(plan: plan, tasks: tasks);
    }

    final nextDayIndex = tasks.isEmpty
        ? 1
        : tasks.map((e) => e.dayIndex).reduce((a, b) => a > b ? a : b) + 1;
    final pending = tasks.where((task) => !task.completed).toList()
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    final startFrom = pending.isNotEmpty
        ? pending.first.fromPage
        : (plan.currentPage + 1);
    final minReadablePage = (plan.currentPage + 1).clamp(1, plan.endPage);
    final safeFrom = (startFrom > minReadablePage ? startFrom : minReadablePage)
        .clamp(1, plan.endPage);
    final toPage = (safeFrom + KhatmahPlannerService.openPlanDailyPages - 1)
        .clamp(safeFrom, plan.endPage);
    final now = DateTime.now();
    final y = today.year.toString().padLeft(4, '0');
    final m = today.month.toString().padLeft(2, '0');
    final d = today.day.toString().padLeft(2, '0');
    final task = KhatmahDailyTask(
      id: '${plan.id}_$nextDayIndex-$y$m$d',
      planId: plan.id,
      dayIndex: nextDayIndex,
      date: today,
      fromPage: safeFrom,
      toPage: toPage,
      completed: false,
      createdAt: now,
    );
    final updatedTasks = [...tasks, task];
    await _repo.saveDailyTasks(plan.id, updatedTasks);
    return _PlanAndTasks(plan: plan, tasks: updatedTasks);
  }

  KhatmahViewState _computeViewState(
    KhatmahPlan plan,
    List<KhatmahDailyTask> tasks,
  ) {
    final today = _dateOnly(DateTime.now());
    final sorted = [...tasks]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    final completedTasks = sorted.where((task) => task.completed).toList();
    final completedPages = completedTasks.fold<int>(
      0,
      (sum, task) => sum + task.totalPages,
    );
    final totalPages = plan.totalPages;
    final progress = totalPages <= 0
        ? 0.0
        : (completedPages / totalPages).clamp(0.0, 1.0);

    KhatmahDailyTask? todayTask;
    KhatmahDailyTask? nextPendingTask;
    for (final task in sorted) {
      if (nextPendingTask == null && !task.completed) {
        nextPendingTask = task;
      }
      if (_dateOnly(task.date) == today) {
        todayTask = task;
      }
    }

    final pendingToToday = sorted
        .where(
          (task) => !task.completed && !_dateOnly(task.date).isAfter(today),
        )
        .toList();
    final missedTasks = pendingToToday
        .where((task) => _dateOnly(task.date).isBefore(today))
        .toList();

    var hasTodayRange = false;
    var todayFromPage = 0;
    var todayToPage = 0;

    if (plan.carryMissedWird && pendingToToday.isNotEmpty) {
      hasTodayRange = true;
      todayFromPage = pendingToToday
          .map((task) => task.fromPage)
          .reduce((a, b) => a < b ? a : b);
      todayToPage = pendingToToday
          .map((task) => task.toPage)
          .reduce((a, b) => a > b ? a : b);
    } else if (todayTask != null) {
      hasTodayRange = true;
      todayFromPage = todayTask.fromPage;
      todayToPage = todayTask.toPage;
    }

    final completedPagesToday = hasTodayRange
        ? _completedPagesInsideRange(
            currentPage: plan.currentPage,
            fromPage: todayFromPage,
            toPage: todayToPage,
          )
        : 0;
    final pagesRangeToday = hasTodayRange
        ? (todayToPage - todayFromPage + 1)
        : 0;
    final remainingPagesToday = hasTodayRange
        ? (pagesRangeToday - completedPagesToday).clamp(0, pagesRangeToday)
        : 0;
    final totalRemainingPages = (totalPages - completedPages).clamp(
      0,
      totalPages,
    );
    final remainingDays = plan.targetDays == null
        ? null
        : sorted.where((task) => !task.completed).length;
    final missedPagesCount = missedTasks.fold<int>(
      0,
      (sum, task) => sum + task.totalPages,
    );
    final todayProgress = pagesRangeToday <= 0
        ? 0.0
        : (completedPagesToday / pagesRangeToday).clamp(0.0, 1.0);
    final currentStreakDays = _calculateStreakDays(sorted, today: today);
    final hasTodayCompleted = todayTask?.completed ?? false;

    return KhatmahViewState(
      plan: plan,
      tasks: sorted,
      todayTask: todayTask,
      progress: progress,
      completedPages: completedPages,
      totalPages: totalPages,
      remainingPages: totalRemainingPages,
      todayFromPage: todayFromPage,
      todayToPage: todayToPage,
      completedPagesToday: completedPagesToday,
      remainingPagesToday: remainingPagesToday,
      daysRemaining: remainingDays,
      todayProgress: todayProgress,
      missedTasksCount: missedTasks.length,
      missedPagesCount: missedPagesCount,
      completedTasksCount: completedTasks.length,
      totalTasksCount: sorted.length,
      currentStreakDays: currentStreakDays,
      isTodayCompleted: hasTodayCompleted,
      nextPendingTask: nextPendingTask,
      debugDate: today,
    );
  }

  int _completedPagesInsideRange({
    required int currentPage,
    required int fromPage,
    required int toPage,
  }) {
    if (fromPage <= 0 || toPage <= 0 || currentPage < fromPage) {
      return 0;
    }
    final clampedCurrent = currentPage > toPage ? toPage : currentPage;
    return (clampedCurrent - fromPage + 1).clamp(0, toPage - fromPage + 1);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _calculateStreakDays(
    List<KhatmahDailyTask> tasks, {
    required DateTime today,
  }) {
    final completedDays = <DateTime>{};
    for (final task in tasks) {
      if (task.completed) {
        completedDays.add(_dateOnly(task.date));
      }
    }
    if (completedDays.isEmpty) return 0;

    var cursor = completedDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class KhatmahViewState {
  const KhatmahViewState({
    required this.plan,
    required this.tasks,
    required this.todayTask,
    required this.progress,
    required this.completedPages,
    required this.totalPages,
    required this.remainingPages,
    required this.todayFromPage,
    required this.todayToPage,
    required this.completedPagesToday,
    required this.remainingPagesToday,
    required this.daysRemaining,
    required this.todayProgress,
    required this.missedTasksCount,
    required this.missedPagesCount,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.currentStreakDays,
    required this.isTodayCompleted,
    required this.nextPendingTask,
    required this.debugDate,
  });

  KhatmahViewState.empty()
    : plan = null,
      tasks = const [],
      todayTask = null,
      progress = 0,
      completedPages = 0,
      totalPages = 0,
      remainingPages = 0,
      todayFromPage = 0,
      todayToPage = 0,
      completedPagesToday = 0,
      remainingPagesToday = 0,
      daysRemaining = null,
      todayProgress = 0,
      missedTasksCount = 0,
      missedPagesCount = 0,
      completedTasksCount = 0,
      totalTasksCount = 0,
      currentStreakDays = 0,
      isTodayCompleted = false,
      nextPendingTask = null,
      debugDate = DateTime.fromMillisecondsSinceEpoch(0);

  final KhatmahPlan? plan;
  final List<KhatmahDailyTask> tasks;
  final KhatmahDailyTask? todayTask;
  final double progress;
  final int completedPages;
  final int totalPages;
  final int remainingPages;
  final int todayFromPage;
  final int todayToPage;
  final int completedPagesToday;
  final int remainingPagesToday;
  final int? daysRemaining;
  final double todayProgress;
  final int missedTasksCount;
  final int missedPagesCount;
  final int completedTasksCount;
  final int totalTasksCount;
  final int currentStreakDays;
  final bool isTodayCompleted;
  final KhatmahDailyTask? nextPendingTask;
  final DateTime debugDate;

  bool get hasActivePlan => plan != null;
}

class _PlanAndTasks {
  const _PlanAndTasks({required this.plan, required this.tasks});

  final KhatmahPlan plan;
  final List<KhatmahDailyTask> tasks;
}
