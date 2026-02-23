import 'khatmah_enums.dart';

class KhatmahPlan {
  const KhatmahPlan({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.targetDays,
    required this.startPage,
    required this.endPage,
    required this.divisionMode,
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.carryMissedWird,
    required this.currentPage,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final String id;
  final KhatmahPlanType type;
  final KhatmahPlanStatus status;
  final DateTime startDate;
  final int? targetDays;
  final int startPage;
  final int endPage;
  final String divisionMode;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool carryMissedWird;
  final int currentPage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  int get totalPages => endPage - startPage + 1;

  KhatmahPlan copyWith({
    String? id,
    KhatmahPlanType? type,
    KhatmahPlanStatus? status,
    DateTime? startDate,
    Object? targetDays = _sentinel,
    int? startPage,
    int? endPage,
    String? divisionMode,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? carryMissedWird,
    int? currentPage,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? completedAt = _sentinel,
  }) {
    return KhatmahPlan(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      targetDays: identical(targetDays, _sentinel)
          ? this.targetDays
          : targetDays as int?,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      divisionMode: divisionMode ?? this.divisionMode,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      carryMissedWird: carryMissedWird ?? this.carryMissedWird,
      currentPage: currentPage ?? this.currentPage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: identical(completedAt, _sentinel)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.key,
      'status': status.key,
      'start_date': startDate.toIso8601String(),
      'target_days': targetDays,
      'start_page': startPage,
      'end_page': endPage,
      'division_mode': divisionMode,
      'daily_reminder_enabled': dailyReminderEnabled,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'carry_missed_wird': carryMissedWird,
      'current_page': currentPage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory KhatmahPlan.fromJson(Map<String, dynamic> json) {
    return KhatmahPlan(
      id: json['id'] as String,
      type: KhatmahPlanTypeX.fromKey(json['type'] as String?),
      status: KhatmahPlanStatusX.fromKey(json['status'] as String?),
      startDate: DateTime.parse(json['start_date'] as String),
      targetDays: json['target_days'] as int?,
      startPage: (json['start_page'] as int?) ?? 1,
      endPage: (json['end_page'] as int?) ?? 604,
      divisionMode: (json['division_mode'] as String?) ?? 'pages',
      dailyReminderEnabled: (json['daily_reminder_enabled'] as bool?) ?? false,
      reminderHour: (json['reminder_hour'] as int?) ?? 9,
      reminderMinute: (json['reminder_minute'] as int?) ?? 0,
      carryMissedWird: (json['carry_missed_wird'] as bool?) ?? false,
      currentPage: (json['current_page'] as int?) ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );
  }
}

class KhatmahPlanDraft {
  const KhatmahPlanDraft({
    required this.type,
    required this.targetDays,
    required this.startDate,
    required this.startPoint,
    required this.customStartPage,
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.carryMissedWird,
    this.divisionMode = 'pages',
  });

  final KhatmahPlanType type;
  final int? targetDays;
  final DateTime startDate;
  final KhatmahStartPointOption startPoint;
  final int? customStartPage;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool carryMissedWird;
  final String divisionMode;
}

const _sentinel = Object();
