class KhatmahReadingSession {
  const KhatmahReadingSession({
    required this.id,
    required this.planId,
    required this.page,
    required this.recordedAt,
  });

  final String id;
  final String planId;
  final int page;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'page': page,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory KhatmahReadingSession.fromJson(Map<String, dynamic> json) {
    return KhatmahReadingSession(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      page: json['page'] as int,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}
