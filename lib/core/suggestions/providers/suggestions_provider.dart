import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/preferences_provider.dart';
import '../models/suggestion.dart';
import '../suggestions_engine.dart';

/// Provider لإدارة الاقتراحات
class SuggestionsNotifier extends Notifier<List<Suggestion>> {
  static const String _dismissedKey = 'dismissed_suggestions';

  @override
  List<Suggestion> build() {
    _refreshSuggestions();
    return [];
  }

  /// تحديث الاقتراحات بناءً على السياق الحالي
  Future<void> _refreshSuggestions() async {
    final context = await _buildContext();
    final suggestions = SuggestionsEngine.generateSuggestions(context);

    // تصفية الاقتراحات المرفوضة
    final dismissedIds = await _getDismissedSuggestions();
    final filteredSuggestions = suggestions
        .where((s) => !dismissedIds.contains(s.id))
        .toList();

    state = filteredSuggestions;
  }

  /// بناء سياق الاقتراحات
  Future<SuggestionContext> _buildContext() async {
    final now = DateTime.now();
    final prefs = ref.read(sharedPreferencesProvider);

    // قراءة البيانات من SharedPreferences
    final lastReadSurah = prefs.getInt('last_read_surah');
    final lastReadPage = prefs.getInt('last_read_page');
    final lastQuranReadTimestamp = prefs.getInt('last_quran_read_time');
    final lastWirdTimestamp = prefs.getInt('last_wird_time');
    final consecutiveDays = prefs.getInt('consecutive_wird_days') ?? 0;
    final hasActiveKhatmah = prefs.getBool('has_active_khatmah') ?? false;

    return SuggestionContext(
      currentTime: now,
      dayOfWeek: now.weekday,
      isFriday: now.weekday == 5,
      // يمكن إضافة منطق رمضان والأيام البيض هنا
      isRamadan: _isRamadan(now),
      isWhiteDays: _isWhiteDays(now),
      lastReadSurah: lastReadSurah,
      lastReadPage: lastReadPage,
      lastQuranReadTime: lastQuranReadTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(lastQuranReadTimestamp)
          : null,
      lastWirdTime: lastWirdTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(lastWirdTimestamp)
          : null,
      consecutiveDaysOfWird: consecutiveDays,
      hasActiveKhatmah: hasActiveKhatmah,
    );
  }

  /// التحقق من رمضان (تقريبي - يحتاج حساب دقيق)
  bool _isRamadan(DateTime date) {
    // يمكن استخدام مكتبة hijri لحساب الشهر الهجري
    // هذا تنفيذ مؤقت
    return false;
  }

  /// التحقق من الأيام البيض (13، 14، 15 هجري)
  bool _isWhiteDays(DateTime date) {
    // يمكن استخدام مكتبة hijri لحساب اليوم الهجري
    // هذا تنفيذ مؤقت
    return false;
  }

  /// إضافة اقتراح يدوياً
  void addSuggestion(Suggestion suggestion) {
    final currentSuggestions = [...state];
    currentSuggestions.insert(0, suggestion);
    state = currentSuggestions;
  }

  /// رفض اقتراح
  Future<void> dismissSuggestion(String suggestionId) async {
    // إزالة من القائمة الحالية
    state = state.where((s) => s.id != suggestionId).toList();

    // حفظ في قائمة المرفوضة
    final prefs = ref.read(sharedPreferencesProvider);
    final dismissed = await _getDismissedSuggestions();
    dismissed.add(suggestionId);
    await prefs.setStringList(_dismissedKey, dismissed.toList());
  }

  /// الحصول على قائمة الاقتراحات المرفوضة
  Future<Set<String>> _getDismissedSuggestions() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final list = prefs.getStringList(_dismissedKey) ?? [];
    return Set.from(list);
  }

  /// مسح قائمة المرفوضة
  Future<void> clearDismissed() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_dismissedKey);
    await _refreshSuggestions();
  }

  /// تحديث يدوي
  Future<void> refresh() async {
    await _refreshSuggestions();
  }

  /// تسجيل حدث وإضافة اقتراح مرتبط
  Future<void> logEvent(String eventType, [Map<String, dynamic>? data]) async {
    final suggestion = SuggestionsEngine.getSuggestionAfterEvent(
      eventType: eventType,
      eventData: data,
    );

    if (suggestion != null) {
      addSuggestion(suggestion);
    }

    // تحديث البيانات ذات الصلة
    final prefs = ref.read(sharedPreferencesProvider);
    switch (eventType) {
      case 'quran_read':
        await prefs.setInt(
          'last_quran_read_time',
          DateTime.now().millisecondsSinceEpoch,
        );
        if (data?['surah'] != null) {
          await prefs.setInt('last_read_surah', data!['surah'] as int);
        }
        if (data?['page'] != null) {
          await prefs.setInt('last_read_page', data!['page'] as int);
        }
        break;

      case 'wird_completed':
        await prefs.setInt(
          'last_wird_time',
          DateTime.now().millisecondsSinceEpoch,
        );
        final consecutive = prefs.getInt('consecutive_wird_days') ?? 0;
        await prefs.setInt('consecutive_wird_days', consecutive + 1);
        break;

      case 'khatmah_started':
        await prefs.setBool('has_active_khatmah', true);
        break;

      case 'khatmah_completed':
        await prefs.setBool('has_active_khatmah', false);
        break;
    }

    // تحديث الاقتراحات
    await _refreshSuggestions();
  }
}

/// Provider للاقتراحات
final suggestionsProvider =
    NotifierProvider<SuggestionsNotifier, List<Suggestion>>(
  SuggestionsNotifier.new,
);

/// Provider للاقتراحات ذات الأولوية العالية فقط
final prioritySuggestionsProvider = Provider<List<Suggestion>>((ref) {
  final allSuggestions = ref.watch(suggestionsProvider);
  return allSuggestions
      .where((s) =>
          s.priority == SuggestionPriority.critical ||
          s.priority == SuggestionPriority.high)
      .toList();
});

/// Provider لعدد الاقتراحات
final suggestionsCountProvider = Provider<int>((ref) {
  return ref.watch(suggestionsProvider).length;
});
