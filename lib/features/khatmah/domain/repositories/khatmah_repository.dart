import '../models/khatmah_daily_task.dart';
import '../models/khatmah_plan.dart';
import '../models/khatmah_reading_session.dart';

abstract class KhatmahRepository {
  Future<KhatmahPlan?> getActivePlan();

  Future<void> savePlan(KhatmahPlan plan);

  Future<void> clearPlan();

  Future<List<KhatmahDailyTask>> getDailyTasks(String planId);

  Future<void> saveDailyTasks(String planId, List<KhatmahDailyTask> tasks);

  Future<void> appendReadingSession(KhatmahReadingSession session);

  Future<List<KhatmahReadingSession>> getReadingSessions(String planId);
}
