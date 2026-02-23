class IslamhouseContentType {
  final String blockName;
  final String type;
  final int itemsCount;
  final String apiUrl;

  const IslamhouseContentType({
    required this.blockName,
    required this.type,
    required this.itemsCount,
    required this.apiUrl,
  });

  factory IslamhouseContentType.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic raw) {
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }

    return IslamhouseContentType(
      blockName: (json['block_name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      itemsCount: parseInt(json['items_count']),
      apiUrl: (json['api_url'] ?? '').toString(),
    );
  }

  static const Set<String> hiddenBrowseBlocks = <String>{
    'quran',
    'poster',
    'apps',
    'favorites',
    'favourites',
    'favorite',
    'selected',
    'مختارات',
  };

  static String normalizeBlockName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  String get normalizedBlockName => normalizeBlockName(blockName);

  String get arabicLabel => switch (normalizedBlockName) {
    'showall' => 'الكل',
    'videos' => 'الفيديوهات',
    'books' => 'الكتب',
    'articles' => 'المقالات',
    'audios' => 'الصوتيات',
    'khotab' => 'خطب الجمعة',
    'fatwa' => 'الفتاوى',
    'favorites' => 'مختارات',
    'favorite' => 'مختارات',
    'favourites' => 'مختارات',
    'selected' => 'مختارات',
    'مختارات' => 'مختارات',
    'quran' => 'القرآن',
    'poster' => 'ملصقات',
    'apps' => 'تطبيقات',
    _ => blockName,
  };

  bool get isBrowsable {
    final key = normalizedBlockName;
    if (key.isEmpty || key == 'showall') {
      return false;
    }
    return !hiddenBrowseBlocks.contains(key);
  }
}
