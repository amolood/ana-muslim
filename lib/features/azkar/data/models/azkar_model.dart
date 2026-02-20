class AzkarItem {
  final int id;
  final String category;
  final String zekr;
  final String description;
  final int count;
  final String reference;
  final String search;

  AzkarItem({
    this.id = 0,
    required this.category,
    required this.zekr,
    required this.description,
    required this.count,
    required this.reference,
    required this.search,
  });

  /// Legacy factory for the old azkar.json format (kept for migration fallback).
  factory AzkarItem.fromList(List<dynamic> list) {
    int parsedCount = 1;
    if (list[3] is int) {
      parsedCount = list[3] as int;
    } else if (list[3] is String) {
      parsedCount = int.tryParse(list[3] as String) ?? 1;
    }

    return AzkarItem(
      category: list[0] as String,
      zekr: list[1] as String,
      description: list[2] as String,
      count: parsedCount,
      reference: list[4] as String? ?? '',
      search: list[5] as String? ?? '',
    );
  }
}
