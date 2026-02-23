class Moshaf {
  final int id;
  final String name;
  final String server;
  final List<int> surahList;
  final int surahTotal;
  final Map<int, String> directSurahUrls;

  const Moshaf({
    required this.id,
    required this.name,
    required this.server,
    required this.surahList,
    required this.surahTotal,
    this.directSurahUrls = const <int, String>{},
  });

  factory Moshaf.fromJson(Map<String, dynamic> json) {
    final parsed = _parseSurahList(json['surah_list']);
    final directUrls = _parseDirectSurahUrls(json['direct_surah_urls']);
    return Moshaf(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      server: json['server'] as String? ?? '',
      surahList: parsed,
      surahTotal: _parseInt(json['surah_total'], fallback: parsed.length),
      directSurahUrls: Map<int, String>.unmodifiable(directUrls),
    );
  }

  bool hasSurah(int surahNumber) => surahList.contains(surahNumber);

  /// Full URL for a specific surah (e.g. 001.mp3 for Fatiha)
  String surahUrl(int surahNumber) {
    final directUrl = directSurahUrls[surahNumber];
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      return directUrl;
    }
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$server$padded.mp3';
  }
}

class Reciter {
  final int id;
  final String name;
  final String letter;
  final List<Moshaf> moshaf;

  const Reciter({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshaf,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    final rawMoshaf = json['moshaf'] ?? json['moshafs'] ?? const <dynamic>[];
    final moshafList = rawMoshaf is List ? rawMoshaf : const <dynamic>[];
    final moshafs = moshafList
        .whereType<Map>()
        .map((m) => Moshaf.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return Reciter(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      letter: json['letter'] as String? ?? '',
      moshaf: moshafs,
    );
  }

  /// Returns the first moshaf that contains the given surah.
  Moshaf? moshafForSurah(int surahNumber) {
    for (final m in moshaf) {
      if (m.hasSurah(surahNumber)) return m;
    }
    return null;
  }

  /// Returns all moshaf entries that contain the given surah.
  List<Moshaf> moshafsForSurah(int surahNumber) {
    return moshaf.where((m) => m.hasSurah(surahNumber)).toList();
  }

  /// Returns a preferred moshaf for the surah if available, otherwise first.
  Moshaf? preferredMoshafForSurah(int surahNumber, {int? preferredMoshafId}) {
    final available = moshafsForSurah(surahNumber);
    if (available.isEmpty) return null;
    if (preferredMoshafId == null) return available.first;

    for (final m in available) {
      if (m.id == preferredMoshafId) return m;
    }
    return available.first;
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<int> _parseSurahList(dynamic value) {
  final parsed = <int>{};
  if (value is String) {
    for (final token in value.split(',')) {
      final number = int.tryParse(token.trim());
      if (number != null && number >= 1 && number <= 114) {
        parsed.add(number);
      }
    }
  } else if (value is List) {
    for (final token in value) {
      final number = _parseInt(token, fallback: -1);
      if (number >= 1 && number <= 114) {
        parsed.add(number);
      }
    }
  }

  final sorted = parsed.toList()..sort();
  return List<int>.unmodifiable(sorted);
}

Map<int, String> _parseDirectSurahUrls(dynamic value) {
  if (value is! Map) return const <int, String>{};

  final urls = <int, String>{};
  for (final entry in value.entries) {
    final surah = int.tryParse(entry.key.toString());
    final url = entry.value?.toString().trim() ?? '';
    if (surah == null || surah < 1 || surah > 114 || url.isEmpty) {
      continue;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      continue;
    }
    urls[surah] = uri.toString();
  }
  return urls;
}
