import '../../../../core/network/fast_api_client.dart';
import '../models/ramadan_model.dart';

class RamadanRepository {
  RamadanRepository._();
  static final RamadanRepository instance = RamadanRepository._();

  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://anaalmuslim.com/api',
  );

  RamadanSchedule? _cached;
  String? _lastLang;

  Future<RamadanSchedule?> getSchedule({
    double lat = 21.3891,
    double lon = 39.8579,
    String lang = 'ar',
  }) async {
    if (_cached != null && _lastLang == lang) return _cached;
    if (_lastLang != lang) _cached = null;

    final uri = Uri.parse('$_apiBaseUrl/ramadan').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'lang': lang,
      },
    );

    try {
      final payload = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 20),
        ttl: const Duration(hours: 12),
      );

      if (payload is! Map) return null;
      final data = payload['data'];
      if (data is! Map) return null;

      _lastLang = lang;
      _cached = RamadanSchedule.fromMap(Map<String, dynamic>.from(data));
      return _cached;
    } catch (_) {
      return null;
    }
  }

  Future<RamadanDay?> getToday({
    double lat = 21.3891,
    double lon = 39.8579,
    String lang = 'ar',
  }) async {
    // Try local cache first
    final schedule = _cached;
    if (schedule != null && _lastLang == lang) {
      return schedule.today;
    }

    final uri = Uri.parse('$_apiBaseUrl/ramadan/today').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'lang': lang,
      },
    );

    try {
      final payload = await FastApiClient.instance.getJson(
        uri,
        timeout: const Duration(seconds: 15),
        ttl: const Duration(hours: 6),
      );

      if (payload is! Map) return null;
      final data = payload['data'];
      if (data is! Map) return null;
      if ((payload['code'] as int?) != 200) return null;

      return RamadanDay.fromMap(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  void clearCache() => _cached = null;
}
