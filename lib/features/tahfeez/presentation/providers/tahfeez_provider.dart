import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// حالة التحفيظ
class TahfeezState {
  final int? surahNumber;
  final int? startAyah;
  final int? endAyah;
  final int repeatCount;
  final bool isPlaying;
  final bool hasStarted;
  final int currentAyah;
  final int completedRepeats;
  final Duration sessionDuration;
  final DateTime? sessionStartTime;

  TahfeezState({
    this.surahNumber,
    this.startAyah,
    this.endAyah,
    this.repeatCount = 3,
    this.isPlaying = false,
    this.hasStarted = false,
    this.currentAyah = 0,
    this.completedRepeats = 0,
    this.sessionDuration = Duration.zero,
    this.sessionStartTime,
  });

  bool get hasRange =>
      surahNumber != null && startAyah != null && endAyah != null;

  int get totalAyahs =>
      hasRange ? (endAyah! - startAyah! + 1) : 0;

  TahfeezState copyWith({
    int? surahNumber,
    int? startAyah,
    int? endAyah,
    int? repeatCount,
    bool? isPlaying,
    bool? hasStarted,
    int? currentAyah,
    int? completedRepeats,
    Duration? sessionDuration,
    DateTime? sessionStartTime,
  }) {
    return TahfeezState(
      surahNumber: surahNumber ?? this.surahNumber,
      startAyah: startAyah ?? this.startAyah,
      endAyah: endAyah ?? this.endAyah,
      repeatCount: repeatCount ?? this.repeatCount,
      isPlaying: isPlaying ?? this.isPlaying,
      hasStarted: hasStarted ?? this.hasStarted,
      currentAyah: currentAyah ?? this.currentAyah,
      completedRepeats: completedRepeats ?? this.completedRepeats,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

/// مزود إدارة حالة التحفيظ
class TahfeezNotifier extends Notifier<TahfeezState> {
  Timer? _sessionTimer;

  @override
  TahfeezState build() {
    ref.onDispose(() {
      _sessionTimer?.cancel();
    });
    return TahfeezState();
  }

  /// تعيين نطاق الحفظ
  void setRange(int surahNumber, int startAyah, int endAyah) {
    state = state.copyWith(
      surahNumber: surahNumber,
      startAyah: startAyah,
      endAyah: endAyah,
    );
  }

  /// تعيين نطاق سريع
  void setQuickRange(QuickRange range) {
    state = state.copyWith(
      surahNumber: range.surahNumber,
      startAyah: range.startAyah,
      endAyah: range.endAyah,
    );
  }

  /// تعيين عدد مرات التكرار
  void setRepeatCount(int count) {
    state = state.copyWith(repeatCount: count);
  }

  /// تعيين حالة التشغيل
  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  /// بدء جلسة الحفظ
  void startSession() {
    state = state.copyWith(
      hasStarted: true,
      sessionStartTime: DateTime.now(),
      completedRepeats: 0,
      sessionDuration: Duration.zero,
    );

    // بدء المؤقت
    _startTimer();
  }

  /// إيقاف جلسة الحفظ
  void stopSession() {
    state = state.copyWith(
      isPlaying: false,
      hasStarted: false,
    );

    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// بدء مؤقت الجلسة
  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sessionStartTime != null) {
        final duration = DateTime.now().difference(state.sessionStartTime!);
        state = state.copyWith(sessionDuration: duration);
      }
    });
  }

  /// تحديث الآية الحالية
  void updateCurrentAyah(int ayahNumber) {
    state = state.copyWith(currentAyah: ayahNumber);
  }

  /// زيادة عدد التكرارات المكتملة
  void incrementCompletedRepeats() {
    state = state.copyWith(
      completedRepeats: state.completedRepeats + 1,
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
      title: 'جزء عم',
      subtitle: 'الجزء الثلاثون (سور قصيرة)',
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
