import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/network/fast_api_client.dart';

import '../models/azkar_model.dart';

/// Single source of truth for Azkar data, backed by remote API.
class AzkarRepository {
  AzkarRepository._();

  static final AzkarRepository instance = AzkarRepository._();

  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anaalmuslim.com/api',
  );
  static const _azkarApi = String.fromEnvironment(
    'AZKAR_API_URL',
    defaultValue: '$_apiBaseUrl/azkar',
  );
  static const _azkarCategoriesApi = String.fromEnvironment(
    'AZKAR_CATEGORIES_API_URL',
    defaultValue: '$_apiBaseUrl/azkar/categories',
  );
  static const _azkarItemsApi = String.fromEnvironment(
    'AZKAR_ITEMS_API_URL',
    defaultValue: '$_apiBaseUrl/azkar/items',
  );
  static const _asmaApi = String.fromEnvironment(
    'ASMA_ALLAH_API_URL',
    defaultValue: '$_apiBaseUrl/asma-allah',
  );
  static const _bundledAzkarAssetPath = 'assets/azkar.json';

  bool _ready = false;
  List<AzkarItem> _items = const <AzkarItem>[];
  List<AzkarCategoryEntry> _categories = const <AzkarCategoryEntry>[];
  Map<int, String> _chapterIdToName = const <int, String>{};
  List<AsmaEntry> _asmaAllah = const <AsmaEntry>[];
  final Map<int, List<AzkarItem>> _chapterItemsCache = <int, List<AzkarItem>>{};

  Future<void> init() async {
    if (_ready) return;

    try {
      final payload = await _fetchAzkarPayloadWithFallback();
      _ingestAzkarPayload(payload);
      _asmaAllah = await _fetchAsmaAllah(payload);
    } catch (_) {
      _items = const <AzkarItem>[];
      _categories = const <AzkarCategoryEntry>[];
      _chapterIdToName = const <int, String>{};
      _asmaAllah = const <AsmaEntry>[];
    }

    _ready = true;
  }

  Future<dynamic> _fetchAzkarPayloadWithFallback() async {
    final remotePayload = await _tryFetchAzkarPayload();
    if (_extractAzkarItems(remotePayload).isNotEmpty) {
      return remotePayload;
    }

    final localPayload = await _loadBundledAzkarPayload();
    if (_extractAzkarItems(localPayload).isNotEmpty) {
      return localPayload;
    }

    return const <String, dynamic>{'items': <dynamic>[]};
  }

  Future<dynamic> _loadBundledAzkarPayload() async {
    try {
      final raw = await rootBundle.loadString(_bundledAzkarAssetPath);
      return jsonDecode(raw);
    } catch (_) {
      return const <String, dynamic>{'items': <dynamic>[]};
    }
  }

  Future<dynamic> _tryFetchAzkarPayload() async {
    final uri = _resolveAzkarUri();
    if (uri == null) return const <String, dynamic>{'items': <dynamic>[]};
    final query = Map<String, String>.from(uri.queryParameters);
    query['limit'] = '5000';
    query['page'] = '1';
    final requestUri = uri.replace(queryParameters: query);

    try {
      return await FastApiClient.instance.getJson(
        requestUri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(minutes: 30),
      );
    } catch (_) {
      return const <String, dynamic>{'items': <dynamic>[]};
    }
  }

  Uri? _resolveAzkarUri() {
    final azkarEndpoint = _azkarApi.trim();
    if (azkarEndpoint.isEmpty) return null;
    final uri = Uri.tryParse(azkarEndpoint);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return uri;
  }

  Uri? _resolveAzkarCategoriesUri() {
    final endpoint = _azkarCategoriesApi.trim();
    if (endpoint.isEmpty) return null;
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return uri;
  }

  Uri? _resolveAzkarItemsUri() {
    final endpoint = _azkarItemsApi.trim();
    if (endpoint.isEmpty) return null;
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return uri;
  }

  void _ingestAzkarPayload(dynamic payload) {
    final rawItems = _extractAzkarItems(payload);
    final parsedItems = <AzkarItem>[];

    var nextId = 1;
    for (final row in rawItems) {
      final item = _parseAzkarItemRow(row, id: nextId);
      if (item == null) continue;
      parsedItems.add(item);
      nextId++;
    }

    final categoryOrder = <String>[];
    final seenCategory = <String>{};
    for (final item in parsedItems) {
      final category = item.category.trim();
      if (category.isEmpty || seenCategory.contains(category)) continue;
      seenCategory.add(category);
      categoryOrder.add(category);
    }

    final explicitCategories = _extractCategories(payload);
    final categories = <AzkarCategoryEntry>[];
    final chapterIdToName = <int, String>{};

    if (explicitCategories.isNotEmpty) {
      for (final category in explicitCategories) {
        categories.add(category);
        chapterIdToName[category.id] = category.name;
      }
    } else {
      for (var i = 0; i < categoryOrder.length; i++) {
        final id = i + 1;
        final name = categoryOrder[i];
        categories.add(AzkarCategoryEntry(id: id, name: name));
        chapterIdToName[id] = name;
      }
    }

    _items = List<AzkarItem>.unmodifiable(parsedItems);
    _categories = List<AzkarCategoryEntry>.unmodifiable(categories);
    _chapterIdToName = Map<int, String>.unmodifiable(chapterIdToName);
  }

  List<dynamic> _extractAzkarItems(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload;
    }
    if (payload is! Map) {
      return const <dynamic>[];
    }

    final rows = payload['rows'];
    if (rows is List<dynamic>) return rows;

    final items = payload['items'];
    if (items is List<dynamic>) return items;

    final data = payload['data'];
    if (data is List<dynamic>) return data;
    if (data is Map) {
      final nestedRows = data['rows'];
      if (nestedRows is List<dynamic>) return nestedRows;
      final nestedItems = data['items'];
      if (nestedItems is List<dynamic>) return nestedItems;
    }
    return const <dynamic>[];
  }

  AzkarItem? _parseAzkarItemRow(dynamic row, {required int id}) {
    if (row is List<dynamic>) {
      if (row.length < 6) return null;
      final base = AzkarItem.fromList(row);
      return AzkarItem(
        id: id,
        category: base.category,
        zekr: base.zekr,
        description: base.description,
        count: base.count,
        reference: base.reference,
        search: base.search,
      );
    }

    if (row is! Map) return null;
    final map = Map<String, dynamic>.from(row);
    final category = (map['category'] ?? '').toString().trim();
    final zekr = (map['zekr'] ?? map['text'] ?? '').toString().trim();
    if (category.isEmpty || zekr.isEmpty) return null;

    final description = (map['description'] ?? '').toString();
    final count = _parseInt(map['count'], fallback: 1);
    final reference = (map['reference'] ?? '').toString();
    final search =
        (map['search'] ?? map['search_text'] ?? map['keywords'] ?? '')
            .toString();

    return AzkarItem(
      id: _parseInt(map['id'], fallback: id),
      category: category,
      zekr: zekr,
      description: description,
      count: count <= 0 ? 1 : count,
      reference: reference,
      search: search,
    );
  }

  List<AzkarCategoryEntry> _extractCategories(dynamic payload) {
    if (payload is! Map) return const <AzkarCategoryEntry>[];
    final raw = payload['categories'];
    if (raw is! List) return const <AzkarCategoryEntry>[];

    final parsed = <AzkarCategoryEntry>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      parsed.add(
        AzkarCategoryEntry(
          id: _parseInt(map['id'], fallback: i + 1),
          name: name,
        ),
      );
    }
    return parsed;
  }

  Future<List<AsmaEntry>> _fetchAsmaAllah(dynamic azkarPayload) async {
    final inline = _extractAsmaEntries(azkarPayload);
    if (inline.isNotEmpty) {
      return List<AsmaEntry>.unmodifiable(inline);
    }

    final uri = _resolveAsmaUri();
    if (uri == null) {
      return const <AsmaEntry>[];
    }

    try {
      final decoded = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(hours: 6),
      );
      return List<AsmaEntry>.unmodifiable(_extractAsmaEntries(decoded));
    } catch (_) {
      return const <AsmaEntry>[];
    }
  }

  Uri? _resolveAsmaUri() {
    final endpoint = _asmaApi.trim();
    if (endpoint.isEmpty) return null;
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return uri;
  }

  List<AsmaEntry> _extractAsmaEntries(dynamic payload) {
    List<dynamic> rows = const <dynamic>[];
    if (payload is List<dynamic>) {
      rows = payload;
    } else if (payload is Map) {
      final direct = payload['asma_allah'];
      if (direct is List<dynamic>) {
        rows = direct;
      } else {
        final data = payload['data'];
        if (data is List<dynamic>) {
          rows = data;
        } else if (data is Map) {
          final nested = data['asma_allah'];
          if (nested is List<dynamic>) {
            rows = nested;
          }
        }
      }
    }

    final parsed = <AsmaEntry>[];
    for (var i = 0; i < rows.length; i++) {
      final item = rows[i];
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      parsed.add(
        AsmaEntry(
          id: _parseInt(map['id'], fallback: i + 1),
          number: _parseInt(map['number'] ?? map['id'], fallback: i + 1),
          name: name,
          transliteration: (map['transliteration'] ?? '').toString(),
          meaning:
              (map['meaning'] ?? map['description'] ?? map['explain'] ?? '')
                  .toString(),
        ),
      );
    }
    return parsed;
  }

  int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<List<AzkarCategoryEntry>> _tryFetchCategoriesFromApi() async {
    final uri = _resolveAzkarCategoriesUri();
    if (uri == null) return const <AzkarCategoryEntry>[];

    try {
      final payload = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(hours: 6),
      );
      final parsed = _extractCategories(payload);
      if (parsed.isEmpty) {
        return const <AzkarCategoryEntry>[];
      }

      _categories = List<AzkarCategoryEntry>.unmodifiable(parsed);
      _chapterIdToName = Map<int, String>.unmodifiable({
        for (final entry in parsed) entry.id: entry.name,
      });
      return _categories;
    } catch (_) {
      return const <AzkarCategoryEntry>[];
    }
  }

  Future<List<AzkarItem>> _tryFetchItemsByChapterFromApi(int chapterId) async {
    final uri = _resolveAzkarItemsUri();
    if (uri == null) return const <AzkarItem>[];

    final query = Map<String, String>.from(uri.queryParameters);
    query['chapter_id'] = '$chapterId';
    query['limit'] = '5000';
    query['page'] = '1';
    final requestUri = uri.replace(queryParameters: query);

    try {
      final payload = await FastApiClient.instance.getJson(
        requestUri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(minutes: 30),
      );
      final rawItems = _extractAzkarItems(payload);
      if (rawItems.isEmpty) {
        return const <AzkarItem>[];
      }

      final parsed = <AzkarItem>[];
      var nextId = 1;
      for (final row in rawItems) {
        final item = _parseAzkarItemRow(row, id: nextId);
        if (item == null) continue;
        parsed.add(item);
        nextId++;
      }

      final immutable = List<AzkarItem>.unmodifiable(parsed);
      _chapterItemsCache[chapterId] = immutable;
      return immutable;
    } catch (_) {
      return const <AzkarItem>[];
    }
  }

  /// Returns all chapters (displayed as category cards) in Arabic.
  Future<List<AzkarCategoryEntry>> getCategories() async {
    if (_categories.isNotEmpty) return _categories;

    final categories = await _tryFetchCategoriesFromApi();
    if (categories.isNotEmpty) {
      return categories;
    }

    await init();
    return _categories;
  }

  /// Returns dhikr items for the given chapter [id].
  Future<List<AzkarItem>> getItemsByChapterId(int id) async {
    final cached = _chapterItemsCache[id];
    if (cached != null) return cached;

    final remoteItems = await _tryFetchItemsByChapterFromApi(id);
    if (remoteItems.isNotEmpty) {
      return remoteItems;
    }

    await init();
    final categoryName = _chapterIdToName[id];
    if (categoryName == null) {
      return const <AzkarItem>[];
    }
    final items = _items
        .where((item) => item.category == categoryName)
        .toList();
    final immutable = List<AzkarItem>.unmodifiable(items);
    _chapterItemsCache[id] = immutable;
    return immutable;
  }

  /// Returns the 99 names of Allah in Arabic.
  Future<List<AsmaEntry>> getAsmaAllah() async {
    if (_asmaAllah.isNotEmpty) return _asmaAllah;

    _asmaAllah = await _fetchAsmaAllah(const <String, dynamic>{});
    if (_asmaAllah.isNotEmpty) {
      return _asmaAllah;
    }

    await init();
    return _asmaAllah;
  }
}

/// Thin model for a category entry.
class AzkarCategoryEntry {
  final int id;
  final String name;

  const AzkarCategoryEntry({required this.id, required this.name});
}

/// Thin model for one of the 99 names of Allah.
class AsmaEntry {
  final int id;
  final int number;
  final String name;
  final String transliteration;
  final String meaning;

  const AsmaEntry({
    required this.id,
    this.number = 0,
    required this.name,
    this.transliteration = '',
    required this.meaning,
  });
}
