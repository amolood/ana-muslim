import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';

class WorshipStatsSnapshot {
  const WorshipStatsSnapshot({
    required this.overallScore,
    required this.motivationTitle,
    required this.motivationBody,
    required this.prayerCompleted,
    required this.prayerTotal,
    required this.prayerProgress,
    required this.sebhaTodayCount,
    required this.sebhaTotalCount,
    required this.sebhaCompletedGoals,
    required this.sebhaGoalCount,
    required this.quranLastPage,
    required this.quranProgress,
    required this.khatmahTodayDonePages,
    required this.khatmahTodayTargetPages,
    required this.khatmahOverallProgress,
    required this.khatmahDaysRemaining,
    required this.hasKhatmahPlan,
  });

  final double overallScore; // 0..1
  final String motivationTitle;
  final String motivationBody;

  final int prayerCompleted;
  final int prayerTotal;
  final double prayerProgress;

  final int sebhaTodayCount;
  final int sebhaTotalCount;
  final int sebhaCompletedGoals;
  final int sebhaGoalCount;

  final int quranLastPage;
  final double quranProgress;

  final int khatmahTodayDonePages;
  final int khatmahTodayTargetPages;
  final double khatmahOverallProgress;
  final int? khatmahDaysRemaining;
  final bool hasKhatmahPlan;
}

final worshipStatsProvider = Provider<WorshipStatsSnapshot>((ref) {
  final prayerState = ref.watch(prayerDailyProgressProvider);
  final sebhaState = ref.watch(sebhaStateProvider);
  final lastPage = ref.watch(lastReadPageProvider).clamp(0, 604);
  final khatmahState = ref.watch(khatmahControllerProvider).asData?.value;

  final prayerTotal = PrayerDailyProgress.trackedPrayers.length;
  final prayerCompleted = prayerState.completedCount;
  final prayerProgress = prayerState.completionRatio.clamp(0.0, 1.0);

  final sebhaGoalCount = sebhaState.phrases
      .where((e) => e.dailyGoal > 0)
      .length;
  final sebhaCompletedGoals = sebhaState.completedGoalsCount;
  final sebhaTodayCount = sebhaState.todayTotalCount;
  final sebhaScore = sebhaGoalCount > 0
      ? (sebhaCompletedGoals / sebhaGoalCount).clamp(0.0, 1.0)
      : (sebhaTodayCount / 100).clamp(0.0, 1.0);

  final hasKhatmah = khatmahState?.hasActivePlan == true;
  final khatmahTodayTargetPages = (khatmahState?.todayToPage ?? 0) > 0
      ? ((khatmahState!.todayToPage - khatmahState.todayFromPage + 1).clamp(
          0,
          604,
        ))
      : 0;
  final khatmahTodayDonePages = khatmahState?.completedPagesToday ?? 0;
  final quranProgressFromLastPage = (lastPage / 604).clamp(0.0, 1.0);
  final quranTodayProgress = khatmahTodayTargetPages > 0
      ? (khatmahTodayDonePages / khatmahTodayTargetPages).clamp(0.0, 1.0)
      : quranProgressFromLastPage;

  final overallScore =
      ((prayerProgress * 0.4) +
              (quranTodayProgress * 0.35) +
              (sebhaScore * 0.25))
          .clamp(0.0, 1.0);

  final motivation = _motivationForScore(overallScore);

  return WorshipStatsSnapshot(
    overallScore: overallScore,
    motivationTitle: motivation.$1,
    motivationBody: motivation.$2,
    prayerCompleted: prayerCompleted,
    prayerTotal: prayerTotal,
    prayerProgress: prayerProgress,
    sebhaTodayCount: sebhaTodayCount,
    sebhaTotalCount: sebhaState.totalCount,
    sebhaCompletedGoals: sebhaCompletedGoals,
    sebhaGoalCount: sebhaGoalCount,
    quranLastPage: lastPage,
    quranProgress: quranProgressFromLastPage,
    khatmahTodayDonePages: khatmahTodayDonePages,
    khatmahTodayTargetPages: khatmahTodayTargetPages,
    khatmahOverallProgress: hasKhatmah ? (khatmahState?.progress ?? 0.0) : 0.0,
    khatmahDaysRemaining: khatmahState?.daysRemaining,
    hasKhatmahPlan: hasKhatmah,
  );
});

(String, String) _motivationForScore(double score) {
  if (score >= 0.9) {
    return (
      'ما شاء الله، ثبات عظيم',
      'أداؤك اليوم مميز جدًا. حافظ على هذا الإيقاع المبارك حتى نهاية اليوم.',
    );
  }
  if (score >= 0.7) {
    return (
      'أداء ممتاز',
      'بقي جزء بسيط وتكمل يومك بإتقان. واصل الذكر وورد القرآن.',
    );
  }
  if (score >= 0.45) {
    return (
      'أنت على الطريق',
      'خطواتك جيدة. زد قليلًا في التسبيح أو اقرأ صفحات إضافية الآن.',
    );
  }
  return (
    'ابدأ بخطوة يسيرة',
    'ابدأ الآن بذكر قصير أو صلاة على النبي ﷺ أو صفحة قرآن، والاستمرارية تصنع الفرق.',
  );
}
