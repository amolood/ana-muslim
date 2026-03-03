import '../../../../core/network/fast_api_client.dart';
import '../../../../core/utils/arabic_utils.dart';

import '../models/reciter.dart';

class AudioRepository {
  static const _base = 'https://www.mp3quran.net/api/v3';
  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anaalmuslim.com/api',
  );
  static const _remoteIslamicApi = String.fromEnvironment(
    'REMOTE_ISLAMIC_API_URL',
    defaultValue: '',
  );
  static const _customArabicRecitersApi = String.fromEnvironment(
    'CUSTOM_RECITERS_API_URL',
    defaultValue: '$_apiBaseUrl/quran/reciters',
  );

  static final Map<String, List<Reciter>> _cache = {};

  /// Fetch reciters for the given language ('ar' or 'eng').
  static Future<List<Reciter>> getReciters(String language) async {
    if (_cache.containsKey(language)) return _cache[language]!;

    final uri = Uri.parse('$_base/reciters?language=$language');
    final decoded = await FastApiClient.instance.getJson(
      uri,
      timeout: const Duration(seconds: 15),
      ttl: const Duration(hours: 8),
    );
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Failed to parse reciters response');
    }
    final json = decoded;
    final baseList = (json['reciters'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Reciter.fromJson)
        .where((r) => r.moshaf.isNotEmpty)
        .toList();

    final list = language == 'ar'
        ? await _appendCustomArabicReciters(baseList)
        : baseList;

    _cache[language] = list;
    return list;
  }

  static Future<List<Reciter>> _appendCustomArabicReciters(
    List<Reciter> source,
  ) async {
    final customReciters = await _fetchCustomArabicReciters();
    if (customReciters.isEmpty) return source;

    final result = List<Reciter>.from(source);
    for (final custom in customReciters) {
      final normalizedTarget = ArabicUtils.normalizeArabic(custom.name);
      final exists = result.any(
        (reciter) =>
            reciter.id == custom.id ||
            ArabicUtils.normalizeArabic(reciter.name) == normalizedTarget,
      );
      if (!exists) {
        result.add(custom);
      }
    }
    return result;
  }

  static Future<List<Reciter>> _fetchCustomArabicReciters() async {
    final uri = _resolveCustomRecitersUri();
    if (uri == null) return const <Reciter>[];

    try {
      final decoded = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(hours: 6),
      );
      final rawReciters = _extractRecitersPayload(decoded);
      if (rawReciters.isEmpty) return const <Reciter>[];

      final parsed = <Reciter>[];
      for (final item in rawReciters) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        try {
          final reciter = Reciter.fromJson(map);
          if (reciter.moshaf.isNotEmpty) {
            parsed.add(reciter);
          }
        } catch (_) {
          // Skip malformed entries from external API.
        }
      }
      return parsed;
    } catch (_) {
      return const <Reciter>[];
    }
  }

  static Uri? _resolveCustomRecitersUri() {
    final endpoint = _customArabicRecitersApi.trim();
    if (endpoint.isNotEmpty) {
      final uri = Uri.tryParse(endpoint);
      if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
        return uri;
      }
    }

    final remoteApi = _remoteIslamicApi.trim();
    if (remoteApi.isNotEmpty) {
      final base = Uri.tryParse(remoteApi);
      if (base != null && (base.isScheme('http') || base.isScheme('https'))) {
        final query = Map<String, String>.from(base.queryParameters);
        query['action'] = 'reciters';
        return base.replace(queryParameters: query);
      }
    }
    return null;
  }

  static List<dynamic> _extractRecitersPayload(dynamic decoded) {
    if (decoded is List<dynamic>) return decoded;
    if (decoded is! Map) return const <dynamic>[];

    final reciters = decoded['reciters'];
    if (reciters is List<dynamic>) return reciters;

    final data = decoded['data'];
    if (data is List<dynamic>) return data;
    if (data is Map) {
      final nested = data['reciters'];
      if (nested is List<dynamic>) return nested;
    }
    return const <dynamic>[];
  }

}
