import 'package:flutter/material.dart';

/// نوع الاقتراح
enum SuggestionType {
  // Time-based
  morningAzkar,
  eveningAzkar,
  ishraq,
  duha,
  witr,
  qiyamAlLayl,

  // Weekly
  kahfFriday,
  salawatFriday,

  // Seasonal
  ramadan,
  ashrMubarakah,
  whiteDays,

  // Behavior-based
  continueDailyWird,
  reviewMemorization,
  completeTafsir,

  // Knowledge-based
  relatedAyah,
  relatedHadith,
  explainConcept,

  // Worship-based
  afterPrayerAzkar,
  tasbihCounter,
  ayatAlKursi,

  // Quran-based
  continueKhatmah,
  newKhatmah,
  listenRecitation,

  // General
  custom,
}

/// مستوى الأولوية
enum SuggestionPriority {
  critical, // فورية مهمة جدًا
  high, // مهمة
  medium, // متوسطة
  low, // منخفضة
}

/// نموذج الاقتراح
class Suggestion {
  final String id;
  final SuggestionType type;
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final Color color;
  final SuggestionPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final bool isDismissible;

  Suggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    required this.color,
    this.priority = SuggestionPriority.medium,
    DateTime? createdAt,
    this.expiresAt,
    this.metadata,
    this.onTap,
    this.onDismiss,
    this.actionLabel,
    this.isDismissible = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// هل الاقتراح منتهي؟
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// هل الاقتراح ساري؟
  bool get isValid => !isExpired;

  Suggestion copyWith({
    String? id,
    SuggestionType? type,
    String? title,
    String? subtitle,
    String? description,
    IconData? icon,
    Color? color,
    SuggestionPriority? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
    String? actionLabel,
    bool? isDismissible,
  }) {
    return Suggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      onTap: onTap ?? this.onTap,
      onDismiss: onDismiss ?? this.onDismiss,
      actionLabel: actionLabel ?? this.actionLabel,
      isDismissible: isDismissible ?? this.isDismissible,
    );
  }
}

/// سياق الاقتراح - معلومات إضافية عن حالة المستخدم
class SuggestionContext {
  final DateTime currentTime;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final bool isRamadan;
  final bool isWhiteDays; // الأيام البيض
  final bool isFriday;
  final bool isLastTenDays; // العشر الأواخر من رمضان
  final int? lastReadSurah;
  final int? lastReadPage;
  final DateTime? lastQuranReadTime;
  final DateTime? lastWirdTime;
  final int consecutiveDaysOfWird;
  final bool hasActiveKhatmah;
  final Map<String, dynamic>? additionalData;

  const SuggestionContext({
    required this.currentTime,
    required this.dayOfWeek,
    this.isRamadan = false,
    this.isWhiteDays = false,
    this.isFriday = false,
    this.isLastTenDays = false,
    this.lastReadSurah,
    this.lastReadPage,
    this.lastQuranReadTime,
    this.lastWirdTime,
    this.consecutiveDaysOfWird = 0,
    this.hasActiveKhatmah = false,
    this.additionalData,
  });

  /// الوقت بالساعات (0-23)
  int get hourOfDay => currentTime.hour;

  /// هل الوقت صباحًا؟ (5:00-12:00)
  bool get isMorning => hourOfDay >= 5 && hourOfDay < 12;

  /// هل الوقت مساءً؟ (17:00-20:00)
  bool get isEvening => hourOfDay >= 17 && hourOfDay < 20;

  /// هل الوقت ليلاً؟ (20:00-5:00)
  bool get isNight => hourOfDay >= 20 || hourOfDay < 5;

  /// هل المستخدم توقف عن الورد؟
  bool get hasStoppedWird {
    if (lastWirdTime == null) return false;
    final daysSinceLastWird = currentTime.difference(lastWirdTime!).inDays;
    return daysSinceLastWird >= 3;
  }

  /// هل قرأ القرآن مؤخرًا؟
  bool get hasRecentQuranActivity {
    if (lastQuranReadTime == null) return false;
    final hoursSinceLastRead = currentTime.difference(lastQuranReadTime!).inHours;
    return hoursSinceLastRead < 24;
  }
}
