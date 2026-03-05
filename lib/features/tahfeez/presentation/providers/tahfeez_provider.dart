import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_base.dart';

const Object _unset = Object();

/// حالة التحفيظ
class TahfeezState {
  final int? surahNumber;
  final int? startAyah;
  final int? endAyah;
  final int repeatCount;
  final bool isPlaying;
  final bool hasStarted;
  final int currentAyah;
  final int currentAyahInRange;
  final int completedRepeats;
  final Duration sessionDuration;
  final Duration accumulatedActiveDuration;
  final DateTime? activePlaybackStartedAt;

  TahfeezState({
    this.surahNumber,
    this.startAyah,
    this.endAyah,
    this.repeatCount = 3,
    this.isPlaying = false,
    this.hasStarted = false,
    this.currentAyah = 0,
    this.currentAyahInRange = 0,
    this.completedRepeats = 0,
    this.sessionDuration = Duration.zero,
    this.accumulatedActiveDuration = Duration.zero,
    this.activePlaybackStartedAt,
  });

  bool get hasRange =>
      surahNumber != null && startAyah != null && endAyah != null;

  int get totalAyahs => hasRange ? (endAyah! - startAyah! + 1) : 0;

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'repeatCount': repeatCount,
      'isPlaying': isPlaying,
      'hasStarted': hasStarted,
      'currentAyah': currentAyah,
      'currentAyahInRange': currentAyahInRange,
      'completedRepeats': completedRepeats,
      'sessionDurationMs': sessionDuration.inMilliseconds,
      'accumulatedActiveDurationMs': accumulatedActiveDuration.inMilliseconds,
      'activePlaybackStartedAtMs': activePlaybackStartedAt?.millisecondsSinceEpoch,
    };
  }

  factory TahfeezState.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value == 'true' || value == '1';
      if (value is int) return value == 1;
      return false;
    }

    final surahNumber = asInt(json['surahNumber']);
    final startAyah = asInt(json['startAyah']);
    final endAyah = asInt(json['endAyah']);

    final hasValidRange =
        surahNumber != null &&
        startAyah != null &&
        endAyah != null &&
        startAyah >= 1 &&
        endAyah >= startAyah;

    final repeatCount = (asInt(json['repeatCount']) ?? 3).clamp(1, 20);
    final sessionDurationMs =
        (asInt(json['sessionDurationMs']) ?? 0).clamp(0, 2147483647);
    final accumulatedDurationMs =
        (asInt(json['accumulatedActiveDurationMs']) ?? 0).clamp(0, 2147483647);
    final activeStartedAtMs = asInt(json['activePlaybackStartedAtMs']);

    final currentAyah = asInt(json['currentAyah']) ?? 0;
    final currentAyahInRange = asInt(json['currentAyahInRange']) ?? 0;
    final completedRepeats = (asInt(json['completedRepeats']) ?? 0).clamp(0, 999);

    return TahfeezState(
      surahNumber: hasValidRange ? surahNumber : null,
      startAyah: hasValidRange ? startAyah : null,
      endAyah: hasValidRange ? endAyah : null,
      repeatCount: repeatCount,
      isPlaying: asBool(json['isPlaying']),
      hasStarted: asBool(json['hasStarted']),
      currentAyah: currentAyah,
      currentAyahInRange: currentAyahInRange,
      completedRepeats: completedRepeats,
      sessionDuration: Duration(milliseconds: sessionDurationMs),
      accumulatedActiveDuration: Duration(milliseconds: accumulatedDurationMs),
      activePlaybackStartedAt: activeStartedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(activeStartedAtMs),
    );
  }

  TahfeezState copyWith({
    int? surahNumber,
    int? startAyah,
    int? endAyah,
    int? repeatCount,
    bool? isPlaying,
    bool? hasStarted,
    int? currentAyah,
    int? currentAyahInRange,
    int? completedRepeats,
    Duration? sessionDuration,
    Duration? accumulatedActiveDuration,
    Object? activePlaybackStartedAt = _unset,
  }) {
    return TahfeezState(
      surahNumber: surahNumber ?? this.surahNumber,
      startAyah: startAyah ?? this.startAyah,
      endAyah: endAyah ?? this.endAyah,
      repeatCount: repeatCount ?? this.repeatCount,
      isPlaying: isPlaying ?? this.isPlaying,
      hasStarted: hasStarted ?? this.hasStarted,
      currentAyah: currentAyah ?? this.currentAyah,
      currentAyahInRange: currentAyahInRange ?? this.currentAyahInRange,
      completedRepeats: completedRepeats ?? this.completedRepeats,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      accumulatedActiveDuration:
          accumulatedActiveDuration ?? this.accumulatedActiveDuration,
      activePlaybackStartedAt: activePlaybackStartedAt == _unset
          ? this.activePlaybackStartedAt
          : activePlaybackStartedAt as DateTime?,
    );
  }
}

/// مزود إدارة حالة التحفيظ
class TahfeezNotifier extends Notifier<TahfeezState> {
  static const _snapshotKey = 'tahfeez_session_snapshot';
  Timer? _sessionTimer;

  @override
  TahfeezState build() {
    ref.onDispose(() {
      _sessionTimer?.cancel();
    });

    final hydrated = _hydrateState();
    if (!hydrated.isPlaying) {
      return hydrated;
    }

    // سياسة الاسترجاع: عند إعادة فتح التطبيق لا نفترض استمرار التشغيل الفعلي
    // في الخلفية، لذلك نعيد الجلسة إلى حالة متوقفة مع الاحتفاظ بمدة الممارسة المحفوظة.
    final pausedSnapshot = hydrated.copyWith(
      isPlaying: false,
      activePlaybackStartedAt: null,
      sessionDuration: hydrated.accumulatedActiveDuration,
    );
    _persistSnapshot(pausedSnapshot);
    return pausedSnapshot;
  }

  /// تعيين نطاق الحفظ
  void setRange(int surahNumber, int startAyah, int endAyah) {
    if (surahNumber < 1 || surahNumber > 114 || startAyah < 1 || endAyah < startAyah) {
      return;
    }

    final next = _resetRuntimeState(
      state.copyWith(
        surahNumber: surahNumber,
        startAyah: startAyah,
        endAyah: endAyah,
      ),
    );
    _setState(next);
  }

  /// تعيين نطاق سريع
  void setQuickRange(QuickRange range) {
    setRange(range.surahNumber, range.startAyah, range.endAyah);
  }

  /// تعيين عدد مرات التكرار
  void setRepeatCount(int count) {
    final normalized = count.clamp(1, 20);
    _setState(state.copyWith(repeatCount: normalized));
  }

  /// بدء التشغيل الفعلي (بعد نجاح تشغيل الصوت)
  void onPlaybackStarted({
    required int initialAyah,
    required bool resetSession,
  }) {
    if (!state.hasRange) {
      return;
    }

    final now = DateTime.now();
    TahfeezState next = state;

    if (resetSession || !state.hasStarted) {
      next = next.copyWith(
        hasStarted: true,
        completedRepeats: 0,
        currentAyah: initialAyah,
        currentAyahInRange: _rangeIndexForAyah(initialAyah, next),
        sessionDuration: Duration.zero,
        accumulatedActiveDuration: Duration.zero,
      );
    } else {
      final ayahToUse = initialAyah > 0 ? initialAyah : state.currentAyah;
      next = next.copyWith(
        hasStarted: true,
        currentAyah: ayahToUse,
        currentAyahInRange: _rangeIndexForAyah(ayahToUse, next),
      );
    }

    next = next.copyWith(
      isPlaying: true,
      activePlaybackStartedAt: now,
    );

    _setState(next);
    _startTimer();
  }

  /// إيقاف مؤقت للجلسة (توقف احتساب الوقت النشط)
  void onPlaybackPaused() {
    if (!state.hasStarted) {
      return;
    }
    _finishActiveSegment(keepSession: true);
  }

  /// إنهاء دورة تكرار كاملة
  int completeCurrentCycle() {
    if (!state.hasStarted) {
      return state.completedRepeats;
    }

    final completed = state.completedRepeats + 1;
    final next = state.copyWith(
      completedRepeats: completed,
      currentAyah: state.endAyah ?? state.currentAyah,
      currentAyahInRange:
          state.totalAyahs > 0 ? state.totalAyahs : state.currentAyahInRange,
    );
    _setState(next);
    return completed;
  }

  /// إنهاء جلسة الحفظ وإعادة ضبط بيانات التشغيل فقط
  void stopSession() {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    final next = state.copyWith(
      isPlaying: false,
      hasStarted: false,
      currentAyah: 0,
      currentAyahInRange: 0,
      completedRepeats: 0,
      sessionDuration: Duration.zero,
      accumulatedActiveDuration: Duration.zero,
      activePlaybackStartedAt: null,
    );
    _setState(next);
  }

  /// تحديث الآية الحالية من مستمعات الصوت
  void updateCurrentAyah(int ayahNumber) {
    if (!state.hasRange) {
      return;
    }

    final startAyah = state.startAyah!;
    final endAyah = state.endAyah!;
    if (ayahNumber < startAyah || ayahNumber > endAyah) {
      return;
    }

    final nextInRange = _rangeIndexForAyah(ayahNumber, state);
    if (state.currentAyah == ayahNumber && state.currentAyahInRange == nextInRange) {
      return;
    }

    _setState(
      state.copyWith(
        currentAyah: ayahNumber,
        currentAyahInRange: nextInRange,
      ),
    );
  }

  TahfeezState _resetRuntimeState(TahfeezState base) {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    return base.copyWith(
      isPlaying: false,
      hasStarted: false,
      currentAyah: 0,
      currentAyahInRange: 0,
      completedRepeats: 0,
      sessionDuration: Duration.zero,
      accumulatedActiveDuration: Duration.zero,
      activePlaybackStartedAt: null,
    );
  }

  void _finishActiveSegment({required bool keepSession}) {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    var accumulated = state.accumulatedActiveDuration;
    final startedAt = state.activePlaybackStartedAt;

    if (startedAt != null) {
      final delta = DateTime.now().difference(startedAt);
      if (!delta.isNegative) {
        accumulated += delta;
      }
    }

    final next = state.copyWith(
      isPlaying: false,
      hasStarted: keepSession ? state.hasStarted : false,
      accumulatedActiveDuration: accumulated,
      sessionDuration: accumulated,
      activePlaybackStartedAt: null,
    );

    _setState(next);
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPlaying || state.activePlaybackStartedAt == null) {
        timer.cancel();
        _sessionTimer = null;
        return;
      }

      final nextDuration = _activeSessionDuration();
      if (nextDuration == state.sessionDuration) {
        return;
      }

      _setState(state.copyWith(sessionDuration: nextDuration));
    });
  }

  Duration _activeSessionDuration() {
    final startedAt = state.activePlaybackStartedAt;
    if (startedAt == null) {
      return state.accumulatedActiveDuration;
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed.isNegative) {
      return state.accumulatedActiveDuration;
    }

    return state.accumulatedActiveDuration + elapsed;
  }

  int _rangeIndexForAyah(int ayahNumber, TahfeezState targetState) {
    if (!targetState.hasRange) {
      return 0;
    }

    final startAyah = targetState.startAyah!;
    final endAyah = targetState.endAyah!;

    if (ayahNumber < startAyah || ayahNumber > endAyah) {
      return 0;
    }

    return ayahNumber - startAyah + 1;
  }

  TahfeezState _hydrateState() {
    final raw = ref.read(sharedPreferencesProvider).getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return TahfeezState();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return TahfeezState();
      }
      return TahfeezState.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return TahfeezState();
    }
  }

  void _setState(TahfeezState next) {
    state = next;
    _persistSnapshot(next);
  }

  void _persistSnapshot(TahfeezState snapshot) {
    final encoded = jsonEncode(snapshot.toJson());
    unawaited(
      ref.read(sharedPreferencesProvider).setString(_snapshotKey, encoded),
    );
  }
}

/// نموذج النطاق السريع
class QuickRange {
  final String title;
  final String subtitle;
  final int surahNumber;
  final int startAyah;
  final int endAyah;

  QuickRange({
    required this.title,
    required this.subtitle,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });

  int get ayahCount => endAyah - startAyah + 1;
}

/// Provider للتحفيظ
final tahfeezProvider = NotifierProvider<TahfeezNotifier, TahfeezState>(() {
  return TahfeezNotifier();
});

/// قائمة النطاقات السريعة المشهورة للحفظ
final quickRangesProvider = Provider<List<QuickRange>>((ref) {
  return [
    // الأجزاء المشهورة
    QuickRange(
      title: 'سورة النبأ',
      subtitle: 'سورة النبأ كاملة (40 آية)',
      surahNumber: 78,
      startAyah: 1,
      endAyah: 40,
    ),
    QuickRange(
      title: 'جزء تبارك',
      subtitle: 'الجزء التاسع والعشرون',
      surahNumber: 67,
      startAyah: 1,
      endAyah: 30,
    ),

    // سور مشهورة كاملة
    QuickRange(
      title: 'سورة الكهف',
      subtitle: 'السورة الكاملة (110 آيات)',
      surahNumber: 18,
      startAyah: 1,
      endAyah: 110,
    ),
    QuickRange(
      title: 'سورة يس',
      subtitle: 'قلب القرآن (83 آية)',
      surahNumber: 36,
      startAyah: 1,
      endAyah: 83,
    ),
    QuickRange(
      title: 'سورة الرحمن',
      subtitle: 'عروس القرآن (78 آية)',
      surahNumber: 55,
      startAyah: 1,
      endAyah: 78,
    ),
    QuickRange(
      title: 'سورة الواقعة',
      subtitle: 'المانعة من الفقر (96 آية)',
      surahNumber: 56,
      startAyah: 1,
      endAyah: 96,
    ),
    QuickRange(
      title: 'سورة الملك',
      subtitle: 'المنجية من عذاب القبر (30 آية)',
      surahNumber: 67,
      startAyah: 1,
      endAyah: 30,
    ),

    // نطاقات خاصة للحفظ
    QuickRange(
      title: 'أول 10 آيات من الكهف',
      subtitle: 'حماية من الدجال',
      surahNumber: 18,
      startAyah: 1,
      endAyah: 10,
    ),
    QuickRange(
      title: 'آخر 10 آيات من الكهف',
      subtitle: 'نور بين الجمعتين',
      surahNumber: 18,
      startAyah: 101,
      endAyah: 110,
    ),
    QuickRange(
      title: 'آية الكرسي ومافاتها',
      subtitle: 'البقرة 255-257',
      surahNumber: 2,
      startAyah: 255,
      endAyah: 257,
    ),
    QuickRange(
      title: 'خواتيم البقرة',
      subtitle: 'آخر آيتان من البقرة',
      surahNumber: 2,
      startAyah: 285,
      endAyah: 286,
    ),
    QuickRange(
      title: 'أول البقرة',
      subtitle: 'أول 5 آيات',
      surahNumber: 2,
      startAyah: 1,
      endAyah: 5,
    ),

    // المعوذات
    QuickRange(
      title: 'المعوذتان',
      subtitle: 'الفلق والناس',
      surahNumber: 113,
      startAyah: 1,
      endAyah: 5,
    ),

    // سور قصيرة للمبتدئين
    QuickRange(
      title: 'الفاتحة',
      subtitle: 'أم الكتاب (7 آيات)',
      surahNumber: 1,
      startAyah: 1,
      endAyah: 7,
    ),
    QuickRange(
      title: 'الإخلاص والمعوذتان',
      subtitle: 'ثلث القرآن + الحماية',
      surahNumber: 112,
      startAyah: 1,
      endAyah: 4,
    ),
  ];
});
