import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../domain/models/khatmah_daily_task.dart';
import '../../domain/models/khatmah_plan.dart';
import '../../domain/models/khatmah_reading_session.dart';
import '../../domain/repositories/khatmah_repository.dart';

const _khatmahPlanKey = 'khatmah_active_plan_v1';
const _khatmahTasksKey = 'khatmah_daily_tasks_v1';
const _khatmahSessionsKey = 'khatmah_reading_sessions_v1';

final khatmahRepositoryProvider = Provider<KhatmahRepository>((ref) {
  return LocalKhatmahRepository(ref);
});

class LocalKhatmahRepository implements KhatmahRepository {
  LocalKhatmahRepository(this._ref);

  final Ref _ref;

  @override
  Future<KhatmahPlan?> getActivePlan() async {
    final raw = _prefs.getString(_khatmahPlanKey);
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return KhatmahPlan.fromJson(json);
  }

  @override
  Future<void> savePlan(KhatmahPlan plan) async {
    await _prefs.setString(_khatmahPlanKey, jsonEncode(plan.toJson()));
  }

  @override
  Future<void> clearPlan() async {
    await _prefs.remove(_khatmahPlanKey);
    await _prefs.remove(_khatmahTasksKey);
    await _prefs.remove(_khatmahSessionsKey);
  }

  @override
  Future<List<KhatmahDailyTask>> getDailyTasks(String planId) async {
    final raw = _prefs.getString(_khatmahTasksKey);
    if (raw == null || raw.isEmpty) return const [];

    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => KhatmahDailyTask.fromJson(e as Map<String, dynamic>))
        .where((task) => task.planId == planId)
        .toList();

    list.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    return list;
  }

  @override
  Future<void> saveDailyTasks(
    String planId,
    List<KhatmahDailyTask> tasks,
  ) async {
    final encoded = tasks
        .where((task) => task.planId == planId)
        .map((task) => task.toJson())
        .toList();
    await _prefs.setString(_khatmahTasksKey, jsonEncode(encoded));
  }

  @override
  Future<void> appendReadingSession(KhatmahReadingSession session) async {
    final sessions = (await getReadingSessions(
      session.planId,
    )).toList(growable: true);
    sessions.add(session);
    final last90 = sessions.length > 90
        ? sessions.sublist(sessions.length - 90)
        : sessions;
    await _prefs.setString(
      _khatmahSessionsKey,
      jsonEncode(last90.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<KhatmahReadingSession>> getReadingSessions(String planId) async {
    final raw = _prefs.getString(_khatmahSessionsKey);
    if (raw == null || raw.isEmpty) return <KhatmahReadingSession>[];
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => KhatmahReadingSession.fromJson(e as Map<String, dynamic>))
        .where((session) => session.planId == planId)
        .toList();
    list.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return list;
  }

  SharedPreferences get _prefs => _ref.read(sharedPreferencesProvider);
}
