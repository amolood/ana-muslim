import 'dart:collection';

import '../../../../core/network/fast_api_client.dart';

import '../models/islamhouse_content_type.dart';
import '../models/islamhouse_item.dart';
import '../models/islamhouse_paged_items.dart';

class IslamhouseRepository {
  IslamhouseRepository({FastApiClient? apiClient})
    : _apiClient = apiClient ?? FastApiClient.instance;

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anaalmuslim.com/api',
  );
  static const String defaultLanguage = 'ar';
  static const String defaultSourceLanguage = 'ar';
  static const Duration _typesCacheTtl = Duration(hours: 8);
  static const Duration _highlightsCacheTtl = Duration(minutes: 20);
  static const Duration _pagedCacheTtl = Duration(minutes: 10);
  static const Duration _detailsCacheTtl = Duration(hours: 12);
  static const int _maxPagedCacheEntries = 48;
  static const int _maxDetailsCacheEntries = 120;

  final FastApiClient _apiClient;

  List<IslamhouseContentType>? _typesCache;
  DateTime? _typesCacheAt;
  List<IslamhouseItem>? _highlightsCache;
  DateTime? _highlightsCacheAt;
  final LinkedHashMap<String, _TimedCacheEntry<IslamhousePagedItems>>
  _pagedCache = LinkedHashMap<String, _TimedCacheEntry<IslamhousePagedItems>>();
  final LinkedHashMap<int, _TimedCacheEntry<IslamhouseItem>> _detailsCache =
      LinkedHashMap<int, _TimedCacheEntry<IslamhouseItem>>();

  bool _hasOnlyHttpAttachments(IslamhouseItem item) {
    for (final attachment in item.attachments) {
      final uri = Uri.tryParse(attachment.url.trim());
      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }
    }
    return true;
  }

  Future<List<IslamhouseContentType>> fetchTypes({
    String language = defaultLanguage,
    String sourceLanguage = defaultSourceLanguage,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _typesCache != null &&
        _isFresh(_typesCacheAt, _typesCacheTtl)) {
      return _typesCache!;
    }

    final uri = _buildApiUri(
      '/islamic-content/types',
      queryParameters: {
        'language': language,
        'source_language': sourceLanguage,
      },
    );
    final payload = await _getJson(uri);

    final rows = _extractListPayload(payload);
    if (rows == null) {
      throw IslamhouseApiException('صيغة الأنواع غير متوقعة');
    }

    final types = rows
        .whereType<Map<String, dynamic>>()
        .map(IslamhouseContentType.fromJson)
        .where((t) => t.itemsCount > 0)
        .toList();

    types.sort((a, b) {
      if (a.blockName == 'showall') return -1;
      if (b.blockName == 'showall') return 1;
      return b.itemsCount.compareTo(a.itemsCount);
    });

    _typesCache = types;
    _typesCacheAt = DateTime.now();
    return types;
  }

  Future<List<IslamhouseItem>> fetchHighlights({
    String language = defaultLanguage,
    String sourceLanguage = defaultSourceLanguage,
    int limit = 12,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _highlightsCache != null &&
        _isFresh(_highlightsCacheAt, _highlightsCacheTtl)) {
      return _highlightsCache!.take(limit).toList();
    }

    final uri = _buildApiUri(
      '/islamic-content/highlights',
      queryParameters: {
        'language': language,
        'source_language': sourceLanguage,
        'limit': '$limit',
      },
    );
    final payload = await _getJson(uri);

    final rows = _extractListPayload(payload);
    if (rows == null) {
      throw IslamhouseApiException('صيغة المحتوى المميز غير متوقعة');
    }

    final items = rows
        .whereType<Map<String, dynamic>>()
        .map(IslamhouseItem.fromJson)
        .where(
          (item) =>
              item.id > 0 && item.title.trim().isNotEmpty && !item.isHiddenType,
        )
        .toList();

    _highlightsCache = items;
    _highlightsCacheAt = DateTime.now();
    return items.take(limit).toList();
  }

  Future<IslamhousePagedItems> fetchLatestItems({
    String period = 'month',
    String language = defaultLanguage,
    String sourceLanguage = defaultSourceLanguage,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 50);
    final cacheKey =
        'latest:$period:$language:$sourceLanguage:$safePage:$safeLimit';

    if (!forceRefresh) {
      final cached = _getPagedCache(cacheKey);
      if (cached != null) return cached;
    }

    final uri = _buildApiUri(
      '/islamic-content/latest',
      queryParameters: {
        'period': period,
        'language': language,
        'source_language': sourceLanguage,
        'page': '$safePage',
        'limit': '$safeLimit',
      },
    );

    final payload = await _getJson(uri);
    if (payload is! Map<String, dynamic>) {
      throw IslamhouseApiException('صيغة أحدث المحتويات غير متوقعة');
    }

    final parsed = IslamhousePagedItems.fromJson(payload);
    final visibleItems = parsed.items
        .where((item) => !item.isHiddenType)
        .toList(growable: false);
    final result = IslamhousePagedItems(
      items: visibleItems,
      currentPage: parsed.currentPage,
      totalPages: parsed.totalPages,
      totalItems: visibleItems.length,
    );
    _setPagedCache(cacheKey, result);
    return result;
  }

  Future<IslamhousePagedItems> fetchItemsByType({
    required String type,
    String language = defaultLanguage,
    String sourceLanguage = defaultSourceLanguage,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final normalizedInputType = IslamhouseItem.normalizeTypeKey(type);
    final safeType = normalizedInputType.isEmpty
        ? 'showall'
        : normalizedInputType;
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 50);
    final cacheKey =
        'type:$safeType:$language:$sourceLanguage:$safePage:$safeLimit';

    if (IslamhouseContentType.hiddenBrowseBlocks.contains(safeType)) {
      return const IslamhousePagedItems(
        items: [],
        currentPage: 1,
        totalPages: 1,
        totalItems: 0,
      );
    }

    if (!forceRefresh) {
      final cached = _getPagedCache(cacheKey);
      if (cached != null) return cached;
    }

    final uri = _buildApiUri(
      '/islamic-content/items/$safeType',
      queryParameters: {
        'language': language,
        'source_language': sourceLanguage,
        'page': '$safePage',
        'limit': '$safeLimit',
      },
    );

    final payload = await _getJson(uri);
    if (payload is! Map<String, dynamic>) {
      throw IslamhouseApiException('صيغة قائمة المحتوى غير متوقعة');
    }

    final parsed = IslamhousePagedItems.fromJson(payload);
    final filteredItems = safeType == 'showall'
        ? parsed.items
              .where((item) => !item.isHiddenType)
              .toList(growable: false)
        : parsed.items
              .where(
                (item) => !item.isHiddenType && item.normalizedType == safeType,
              )
              .toList(growable: false);

    final result = IslamhousePagedItems(
      items: filteredItems,
      currentPage: parsed.currentPage,
      totalPages: parsed.totalPages,
      totalItems: filteredItems.length,
    );
    _setPagedCache(cacheKey, result);
    return result;
  }

  Future<IslamhouseItem> fetchItemDetails({
    required int itemId,
    String language = defaultLanguage,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _getDetailsCache(itemId);
      if (cached != null && _hasOnlyHttpAttachments(cached)) {
        return cached;
      }
    }

    final uri = _buildApiUri(
      '/islamic-content/items/details/$itemId',
      queryParameters: {'language': language},
    );
    final payload = await _getJson(uri);
    if (payload is! Map<String, dynamic>) {
      throw IslamhouseApiException('صيغة تفاصيل المحتوى غير متوقعة');
    }

    final details = IslamhouseItem.fromJson(payload);
    _setDetailsCache(itemId, details);
    return details;
  }

  bool _isFresh(DateTime? cachedAt, Duration ttl) {
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) <= ttl;
  }

  IslamhousePagedItems? _getPagedCache(String key) {
    final entry = _pagedCache[key];
    if (entry == null) return null;
    if (!_isFresh(entry.cachedAt, _pagedCacheTtl)) {
      _pagedCache.remove(key);
      return null;
    }
    _pagedCache.remove(key);
    _pagedCache[key] = entry;
    return entry.value;
  }

  void _setPagedCache(String key, IslamhousePagedItems value) {
    _pagedCache.removeWhere(
      (_, entry) => !_isFresh(entry.cachedAt, _pagedCacheTtl),
    );
    _pagedCache.remove(key);
    _pagedCache[key] = _TimedCacheEntry(value: value, cachedAt: DateTime.now());
    while (_pagedCache.length > _maxPagedCacheEntries) {
      _pagedCache.remove(_pagedCache.keys.first);
    }
  }

  IslamhouseItem? _getDetailsCache(int itemId) {
    final entry = _detailsCache[itemId];
    if (entry == null) return null;
    if (!_isFresh(entry.cachedAt, _detailsCacheTtl)) {
      _detailsCache.remove(itemId);
      return null;
    }
    _detailsCache.remove(itemId);
    _detailsCache[itemId] = entry;
    return entry.value;
  }

  void _setDetailsCache(int itemId, IslamhouseItem value) {
    _detailsCache.removeWhere(
      (_, entry) => !_isFresh(entry.cachedAt, _detailsCacheTtl),
    );
    _detailsCache.remove(itemId);
    _detailsCache[itemId] = _TimedCacheEntry(
      value: value,
      cachedAt: DateTime.now(),
    );
    while (_detailsCache.length > _maxDetailsCacheEntries) {
      _detailsCache.remove(_detailsCache.keys.first);
    }
  }

  Future<dynamic> _getJson(Uri uri) async {
    try {
      return await _apiClient.getJson(
        uri,
        timeout: const Duration(seconds: 18),
        ttl: const Duration(minutes: 2),
      );
    } on FastApiClientException catch (e) {
      if (e.statusCode != null) {
        throw IslamhouseApiException(
          'فشل تحميل البيانات (رمز الحالة ${e.statusCode})',
        );
      }
      throw IslamhouseApiException('تعذر الاتصال بالخدمة: ${e.message}');
    } catch (e) {
      throw IslamhouseApiException('تعذر الاتصال بالخدمة: $e');
    }
  }

  Uri _buildApiUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$_apiBaseUrl$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }

  List<dynamic>? _extractListPayload(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final rows = payload['data'];
      if (rows is List) return rows;
    }
    return null;
  }
}

class _TimedCacheEntry<T> {
  const _TimedCacheEntry({required this.value, required this.cachedAt});

  final T value;
  final DateTime cachedAt;
}

class IslamhouseApiException implements Exception {
  final String message;
  IslamhouseApiException(this.message);

  @override
  String toString() => message;
}
