class KhatmahDailyTask {
  const KhatmahDailyTask({
    required this.id,
    required this.planId,
    required this.dayIndex,
    required this.date,
    required this.fromPage,
    required this.toPage,
    required this.completed,
    required this.createdAt,
    this.completedAt,
    this.completedByReading = false,
    this.manualCompletion = false,
  });

  final String id;
  final String planId;
  final int dayIndex;
  final DateTime date;
  final int fromPage;
  final int toPage;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool completedByReading;
  final bool manualCompletion;

  int get totalPages => toPage - fromPage + 1;

  KhatmahDailyTask copyWith({
    String? id,
    String? planId,
    int? dayIndex,
    DateTime? date,
    int? fromPage,
    int? toPage,
    bool? completed,
    DateTime? createdAt,
    Object? completedAt = _sentinel,
    bool? completedByReading,
    bool? manualCompletion,
  }) {
    return KhatmahDailyTask(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      date: date ?? this.date,
      fromPage: fromPage ?? this.fromPage,
      toPage: toPage ?? this.toPage,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: identical(completedAt, _sentinel)
          ? this.completedAt
          : completedAt as DateTime?,
      completedByReading: completedByReading ?? this.completedByReading,
      manualCompletion: manualCompletion ?? this.manualCompletion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'day_index': dayIndex,
      'date': date.toIso8601String(),
      'from_page': fromPage,
      'to_page': toPage,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'completed_by_reading': completedByReading,
      'manual_completion': manualCompletion,
    };
  }

  factory KhatmahDailyTask.fromJson(Map<String, dynamic> json) {
    return KhatmahDailyTask(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      dayIndex: json['day_index'] as int,
      date: DateTime.parse(json['date'] as String),
      fromPage: json['from_page'] as int,
      toPage: json['to_page'] as int,
      completed: (json['completed'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      completedByReading: (json['completed_by_reading'] as bool?) ?? false,
      manualCompletion: (json['manual_completion'] as bool?) ?? false,
    );
  }
}

const _sentinel = Object();
