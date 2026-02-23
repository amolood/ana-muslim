import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hadith/hadith.dart';

import '../../../core/network/fast_api_client.dart';

/// Metadata for one hadith collection.
class HadithCollectionInfo {
  final String slug;
  final String titleAr;
  final String titleEn;
  final int totalChapters;
  final int totalHadith;

  const HadithCollectionInfo({
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    required this.totalChapters,
    required this.totalHadith,
  });

  String get displayName {
    if (titleAr.trim().isNotEmpty) {
      return titleAr.trim();
    }
    if (titleEn.trim().isNotEmpty) {
      return titleEn.trim();
    }
    return slug;
  }
}

/// Search result carrying the hadith + its source collection.
class HadithSearchResult {
  final Hadith hadith;
  final String collectionSlug;
  final String collectionTitle;

  const HadithSearchResult({
    required this.hadith,
    required this.collectionSlug,
    required this.collectionTitle,
  });
}

/// One lazy-loaded page of hadith rows.
class HadithPage {
  final List<Hadith> hadiths;
  final bool hasMore;
  final int nextOffset;

  const HadithPage({
    required this.hadiths,
    required this.hasMore,
    required this.nextOffset,
  });
}

class HadithRepository {
  HadithRepository._();

  static const _remoteIslamicApi = String.fromEnvironment(
    'REMOTE_ISLAMIC_API_URL',
    defaultValue: '',
  );
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anaalmuslim.com/api',
  );
  static const _hadithApiBase = String.fromEnvironment(
    'HADITH_API_BASE_URL',
    defaultValue: '$_apiBaseUrl/hadith',
  );

  static final Map<String, List<Book>> _booksCache = {};
  static final Map<String, List<Hadith>> _hadithsCache = {};
  static final Map<String, HadithPage> _hadithPagesCache = {};
  static List<HadithCollectionInfo>? _collectionsCache;

  static const Map<String, String> _fallbackArabicNames = {
    'bukhari': 'صحيح البخاري',
    'muslim': 'صحيح مسلم',
    'nasai': 'سنن النسائي',
    'abudawud': 'سنن أبي داود',
    'tirmidhi': 'جامع الترمذي',
    'ibnmajah': 'سنن ابن ماجه',
    'malik': 'موطأ مالك',
    'ahmed': 'مسند الإمام أحمد بن حنبل',
    'darimi': 'سنن الدارمي',
    'nawawi40': 'الأربعون النووية',
    'qudsi40': 'الأربعون القدسية',
    'shahwaliullah40': 'أربعون ولي الله الدهلوي',
    'riyad_assalihin': 'رياض الصالحين',
    'mishkat_almasabih': 'مشكاة المصابيح',
    'aladab_almufrad': 'الأدب المفرد',
    'shamail_muhammadiyah': 'الشمائل المحمدية',
    'bulugh_almaram': 'بلوغ المرام',
  };

  static const List<HadithCollectionInfo> _fallbackCollections = [
    HadithCollectionInfo(
      slug: 'bukhari',
      titleAr: 'صحيح البخاري',
      titleEn: 'Sahih al-Bukhari',
      totalChapters: 0,
      totalHadith: 0,
    ),
    HadithCollectionInfo(
      slug: 'muslim',
      titleAr: 'صحيح مسلم',
      titleEn: 'Sahih Muslim',
      totalChapters: 0,
      totalHadith: 0,
    ),
    HadithCollectionInfo(
      slug: 'nasai',
      titleAr: 'سنن النسائي',
      titleEn: 'Sunan al-Nasa\'i',
      totalChapters: 0,
      totalHadith: 0,
    ),
    HadithCollectionInfo(
      slug: 'abudawud',
      titleAr: 'سنن أبي داود',
      titleEn: 'Sunan Abi Dawud',
      totalChapters: 0,
      totalHadith: 0,
    ),
    HadithCollectionInfo(
      slug: 'tirmidhi',
      titleAr: 'جامع الترمذي',
      titleEn: 'Jami\' al-Tirmidhi',
      totalChapters: 0,
      totalHadith: 0,
    ),
    HadithCollectionInfo(
      slug: 'ibnmajah',
      titleAr: 'سنن ابن ماجه',
      titleEn: 'Sunan Ibn Majah',
      totalChapters: 0,
      totalHadith: 0,
    ),
  ];

  static String collectionArabicName(String slug) {
    final normalized = _normalizeCollectionSlug(slug);

    final cached = _collectionsCache;
    if (cached != null) {
      for (final c in cached) {
        if (c.slug == normalized) {
          return c.displayName;
        }
      }
    }

    return _fallbackArabicNames[normalized] ?? normalized;
  }

  // ── Collections ───────────────────────────────────────────────────────────
  static Future<List<HadithCollectionInfo>> getCollections() async {
    final cached = _collectionsCache;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final uri = _resolveCollectionsUri();
    if (uri == null) {
      _collectionsCache = List<HadithCollectionInfo>.from(_fallbackCollections);
      return _collectionsCache!;
    }

    try {
      final decoded = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 25),
        ttl: const Duration(minutes: 10),
      );
      final collections = await compute(_parseCollections, jsonEncode(decoded));
      if (collections.isNotEmpty) {
        _collectionsCache = collections;
        return collections;
      }
    } catch (_) {
      // Fall back below.
    }

    _collectionsCache = List<HadithCollectionInfo>.from(_fallbackCollections);
    return _collectionsCache!;
  }

  static List<HadithCollectionInfo> _parseCollections(String jsonStr) {
    final decoded = jsonDecode(jsonStr);

    List<dynamic> raw;
    if (decoded is Map && decoded['collections'] is List) {
      raw = decoded['collections'] as List<dynamic>;
    } else if (decoded is List) {
      raw = decoded;
    } else {
      return const <HadithCollectionInfo>[];
    }

    final results = <HadithCollectionInfo>[];
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final slug = _normalizeCollectionSlug(
        (map['slug'] ?? map['name'] ?? '').toString(),
      );
      if (slug.isEmpty) {
        continue;
      }
      final titleAr = (map['title_ar'] ?? map['titleAr'] ?? '').toString();
      final titleEn = (map['title_en'] ?? map['titleEn'] ?? '').toString();
      final totalChapters =
          int.tryParse(
            '${map['total_chapters'] ?? map['totalChapters'] ?? 0}',
          ) ??
          0;
      final totalHadith =
          int.tryParse('${map['total_hadith'] ?? map['totalHadith'] ?? 0}') ??
          0;
      results.add(
        HadithCollectionInfo(
          slug: slug,
          titleAr: titleAr,
          titleEn: titleEn,
          totalChapters: totalChapters,
          totalHadith: totalHadith,
        ),
      );
    }

    return results;
  }

  // ── Books ─────────────────────────────────────────────────────────────────
  static Future<List<Book>> getBooks(String collectionSlug) async {
    final normalized = _normalizeCollectionSlug(collectionSlug);
    if (_booksCache.containsKey(normalized)) {
      return _booksCache[normalized]!;
    }

    final payload = await _fetchRemoteData(
      action: 'hadith_books',
      collection: normalized,
    );
    final books = await compute(_parseBooks, jsonEncode(payload));
    _booksCache[normalized] = books;
    return books;
  }

  static List<Book> _parseBooks(String jsonStr) {
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data
        .whereType<Map>()
        .map((j) => Book.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  // ── Hadiths in a book ─────────────────────────────────────────────────────
  static Future<List<Hadith>> getHadithsForBook(
    String collectionSlug,
    String bookNumber,
  ) async {
    final normalized = _normalizeCollectionSlug(collectionSlug);
    final key = '${normalized}_$bookNumber';
    if (_hadithsCache.containsKey(key)) return _hadithsCache[key]!;

    const pageSize = 120;
    final all = <Hadith>[];
    var offset = 0;
    var hasMore = true;

    while (hasMore) {
      final page = await getHadithsForBookPage(
        normalized,
        bookNumber,
        offset: offset,
        limit: pageSize,
      );

      if (page.hadiths.isEmpty) break;

      all.addAll(page.hadiths);
      offset = page.nextOffset;
      hasMore = page.hasMore;
    }

    _hadithsCache[key] = all;
    return all;
  }

  static Future<HadithPage> getHadithsForBookPage(
    String collectionSlug,
    String bookNumber, {
    int offset = 0,
    int limit = 40,
  }) async {
    final normalized = _normalizeCollectionSlug(collectionSlug);
    final normalizedOffset = offset < 0 ? 0 : offset;
    final normalizedLimit = limit.clamp(1, 200).toInt();
    final pageKey =
        '${normalized}_$bookNumber:$normalizedOffset:$normalizedLimit';
    if (_hadithPagesCache.containsKey(pageKey)) {
      return _hadithPagesCache[pageKey]!;
    }

    final uri = _resolveUri(
      action: 'hadith_book',
      collection: normalized,
      bookNumber: bookNumber,
      offset: normalizedOffset,
      limit: normalizedLimit,
    );
    if (uri == null) {
      return HadithPage(
        hadiths: const <Hadith>[],
        hasMore: false,
        nextOffset: normalizedOffset,
      );
    }

    try {
      final decoded = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 25),
        ttl: const Duration(minutes: 4),
      );
      final payload = _extractPayload(decoded, 'hadith_book');
      final hadiths = await compute(_parseHadithList, jsonEncode(payload));
      final hasMore = _extractHasMore(decoded, hadiths.length, normalizedLimit);

      final page = HadithPage(
        hadiths: hadiths,
        hasMore: hasMore,
        nextOffset: normalizedOffset + hadiths.length,
      );
      _hadithPagesCache[pageKey] = page;
      return page;
    } catch (_) {
      return HadithPage(
        hadiths: const <Hadith>[],
        hasMore: false,
        nextOffset: normalizedOffset,
      );
    }
  }

  static List<Hadith> _parseHadithList(String jsonStr) {
    final data = jsonDecode(jsonStr);
    if (data is! List) return const <Hadith>[];
    return data
        .whereType<Map>()
        .map((j) => Hadith.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  static Future<dynamic> _fetchRemoteData({
    required String action,
    required String collection,
    String? bookNumber,
    String? searchQuery,
    int? offset,
    int? limit,
  }) async {
    final uri = _resolveUri(
      action: action,
      collection: collection,
      bookNumber: bookNumber,
      searchQuery: searchQuery,
      offset: offset,
      limit: limit,
    );
    if (uri == null) {
      return const <dynamic>[];
    }

    try {
      final decoded = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 25),
        ttl: const Duration(minutes: 4),
      );
      return _extractPayload(decoded, action);
    } catch (_) {
      return const <dynamic>[];
    }
  }

  static Uri? _resolveCollectionsUri() {
    final apiBase = _apiBaseUrl.trim();
    if (apiBase.isNotEmpty) {
      final base = Uri.tryParse(apiBase);
      if (base != null && (base.isScheme('http') || base.isScheme('https'))) {
        final cleanedPath = base.path.endsWith('/')
            ? base.path.substring(0, base.path.length - 1)
            : base.path;
        return base.replace(path: '$cleanedPath/hadith/collections');
      }
    }

    final hadithBase = _hadithApiBase.trim();
    if (hadithBase.isEmpty) {
      return null;
    }
    final base = Uri.tryParse(hadithBase);
    if (base == null || !(base.isScheme('http') || base.isScheme('https'))) {
      return null;
    }

    final cleanedPath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(path: '$cleanedPath/collections', queryParameters: {});
  }

  static Uri? _resolveUri({
    required String action,
    required String collection,
    String? bookNumber,
    String? searchQuery,
    int? offset,
    int? limit,
  }) {
    final normalizedCollection = _normalizeCollectionSlug(collection);
    Uri? base;

    final remoteApi = _remoteIslamicApi.trim();
    if (remoteApi.isNotEmpty) {
      base = Uri.tryParse(remoteApi);
      if (base != null && (base.isScheme('http') || base.isScheme('https'))) {
        final query = Map<String, String>.from(base.queryParameters);
        query['action'] = action;
        query['collection'] = normalizedCollection;
        if (bookNumber != null && bookNumber.isNotEmpty) {
          query['book'] = bookNumber;
        }
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query['q'] = searchQuery;
        }
        if (offset != null && offset >= 0) {
          query['offset'] = '$offset';
        }
        if (limit != null && limit > 0) {
          query['limit'] = '$limit';
        }
        return base.replace(queryParameters: query);
      }
    }

    final hadithApi = _hadithApiBase.trim();
    if (hadithApi.isEmpty) return null;
    base = Uri.tryParse(hadithApi);
    if (base == null || !(base.isScheme('http') || base.isScheme('https'))) {
      return null;
    }
    final query = Map<String, String>.from(base.queryParameters);
    query['action'] = action;
    query['collection'] = normalizedCollection;
    if (bookNumber != null && bookNumber.isNotEmpty) {
      query['book'] = bookNumber;
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query['q'] = searchQuery;
    }
    if (offset != null && offset >= 0) {
      query['offset'] = '$offset';
    }
    if (limit != null && limit > 0) {
      query['limit'] = '$limit';
    }
    return base.replace(queryParameters: query);
  }

  static bool _extractHasMore(dynamic decoded, int returnedCount, int limit) {
    if (decoded is Map) {
      final pagination = decoded['pagination'];
      if (pagination is Map && pagination['hasMore'] is bool) {
        return pagination['hasMore'] as bool;
      }
    }
    return returnedCount >= limit;
  }

  static dynamic _extractPayload(dynamic decoded, String action) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return const <dynamic>[];

    final byAction = decoded[action];
    if (byAction is List) return byAction;

    final data = decoded['data'];
    if (data is List) return data;
    if (data is Map) {
      final nestedAction = data[action];
      if (nestedAction is List) return nestedAction;
      if (action == 'hadith_books' && data['books'] is List) {
        return data['books'] as List;
      }
      if ((action == 'hadith_book' ||
              action == 'hadith_all' ||
              action == 'hadith_search') &&
          data['hadiths'] is List) {
        return data['hadiths'] as List;
      }
    }

    if (action == 'hadith_books' && decoded['books'] is List) {
      return decoded['books'] as List;
    }
    if ((action == 'hadith_book' ||
            action == 'hadith_all' ||
            action == 'hadith_search') &&
        decoded['hadiths'] is List) {
      return decoded['hadiths'] as List;
    }
    return const <dynamic>[];
  }

  /// Strips Arabic tashkeel (harakat/diacritics) so search works regardless
  /// of whether the query or stored text has diacritics.
  /// Covers U+064B–U+065F (fathatan … wavy hamza below) and U+0670 (superscript alef).
  static String _stripTashkeel(String text) =>
      text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

  static String _normalizeCollectionSlug(String slug) {
    final value = slug.trim().toLowerCase();
    if (value.isEmpty) {
      return '';
    }

    return switch (value) {
      'abu_dawud' || 'abu-dawud' => 'abudawud',
      'ibn_majah' || 'ibn-majah' => 'ibnmajah',
      'nawawi_40' || 'nawawi-40' => 'nawawi40',
      _ => value,
    };
  }

  // ── Search ────────────────────────────────────────────────────────────────
  static Future<List<HadithSearchResult>> search(
    String collectionSlug,
    String query,
  ) async {
    final normalized = _normalizeCollectionSlug(collectionSlug);
    final q = _stripTashkeel(query.trim());
    if (normalized.isEmpty || q.isEmpty) {
      return [];
    }

    final payload = await _fetchRemoteData(
      action: 'hadith_search',
      collection: normalized,
      searchQuery: q,
    );
    final hadiths = await compute(_parseHadithList, jsonEncode(payload));

    final collectionTitle = collectionArabicName(normalized);
    return hadiths
        .map(
          (hadith) => HadithSearchResult(
            hadith: hadith,
            collectionSlug: normalized,
            collectionTitle: collectionTitle,
          ),
        )
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Arabic text from a [Hadith] (lang == 'ar').
  static String? arabicBody(Hadith h) {
    final ar = h.hadith.where((d) => d.lang == 'ar').firstOrNull;
    if (ar == null) return null;
    return _cleanBody(ar.body);
  }

  /// English text from a [Hadith] (lang == 'en').
  static String? englishBody(Hadith h) {
    final en = h.hadith.where((d) => d.lang == 'en').firstOrNull;
    if (en == null) return null;
    return _cleanBody(en.body);
  }

  /// Strips HTML/XML tags, custom [bracket] tags, HTML entities, and extra whitespace.
  static String _cleanBody(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '') // <html tags>
        .replaceAll(RegExp(r'\[[^\]]*\]'), '') // [bracket tags]
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ') // normalise whitespace
        .trim();
  }

  /// Arabic book name from a [Book].
  static String arabicBookName(Book b) {
    final ar = b.book.where((d) => d.lang == 'ar').firstOrNull;
    return ar?.name.trim() ?? b.book.first.name.trim();
  }

  /// Chapter title in Arabic (or English fallback) from the first HadithData.
  static String chapterTitle(Hadith h) {
    final ar = h.hadith.where((d) => d.lang == 'ar').firstOrNull;
    return ar?.chapterTitle.trim() ?? h.hadith.first.chapterTitle.trim();
  }
}
