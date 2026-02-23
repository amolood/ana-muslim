import 'islamhouse_item.dart';

class IslamhousePagedItems {
  final List<IslamhouseItem> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const IslamhousePagedItems({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  bool get hasMore => currentPage < totalPages;

  factory IslamhousePagedItems.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic raw) {
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }

    final parsedItems = <IslamhouseItem>[];
    final rawData = json['data'];
    if (rawData is List) {
      for (final entry in rawData) {
        if (entry is Map<String, dynamic>) {
          parsedItems.add(IslamhouseItem.fromJson(entry));
        }
      }
    }

    final links = json['links'];
    if (links is Map<String, dynamic>) {
      final currentPage = parseInt(links['current_page']);
      final totalPages = parseInt(links['pages_number']);
      final totalItems = parseInt(links['total_items']);
      return IslamhousePagedItems(
        items: parsedItems,
        currentPage: currentPage <= 0 ? 1 : currentPage,
        totalPages: totalPages <= 0 ? 1 : totalPages,
        totalItems: totalItems,
      );
    }

    return IslamhousePagedItems(
      items: parsedItems,
      currentPage: 1,
      totalPages: 1,
      totalItems: parsedItems.length,
    );
  }
}
