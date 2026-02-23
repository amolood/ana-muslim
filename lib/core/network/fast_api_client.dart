import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

class FastApiClientException implements Exception {
  final String message;
  final int? statusCode;

  const FastApiClientException(this.message, {this.statusCode});

  @override
  String toString() => 'FastApiClientException($statusCode): $message';
}

/// Lightweight shared API client with:
/// - in-flight request de-duplication
/// - short-lived memory cache
/// - retry for transient failures
class FastApiClient {
  FastApiClient._();

  static final FastApiClient instance = FastApiClient._();

  static const int _maxCacheEntries = 220;
  static const Duration _defaultTtl = Duration(minutes: 3);
  static const Duration _defaultTimeout = Duration(seconds: 20);

  final http.Client _client = http.Client();
  final Map<String, _CacheEntry<dynamic>> _cache =
      <String, _CacheEntry<dynamic>>{};
  final Map<String, Future<dynamic>> _inFlight = <String, Future<dynamic>>{};
  final math.Random _random = math.Random();

  Future<dynamic> getJson(
    Uri uri, {
    Duration timeout = _defaultTimeout,
    Duration ttl = _defaultTtl,
    bool forceRefresh = false,
    int maxRetries = 2,
  }) async {
    final key = uri.toString();
    _evictExpired();

    if (!forceRefresh) {
      final cached = _cache[key];
      if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
        return cached.value;
      }
    }

    if (_inFlight.containsKey(key)) {
      return _inFlight[key]!;
    }

    final future = _fetchAndDecode(
      uri,
      timeout: timeout,
      ttl: ttl,
      maxRetries: maxRetries,
    );
    _inFlight[key] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<dynamic> _fetchAndDecode(
    Uri uri, {
    required Duration timeout,
    required Duration ttl,
    required int maxRetries,
  }) async {
    Object? lastError;
    int? lastStatusCode;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _client.get(uri).timeout(timeout);
        final code = response.statusCode;

        if (code >= 200 && code < 300) {
          final decoded = _decodePayload(response.body);
          _setCache(uri.toString(), decoded, ttl);
          return decoded;
        }

        lastStatusCode = code;
        if (!_isRetriableStatus(code) || attempt == maxRetries) {
          throw FastApiClientException('API request failed', statusCode: code);
        }
      } catch (error) {
        lastError = error;
        if (attempt == maxRetries) break;
      }

      await _retryDelay(attempt);
    }

    if (lastError is FastApiClientException) {
      throw lastError;
    }

    if (lastStatusCode != null) {
      throw FastApiClientException(
        'API request failed',
        statusCode: lastStatusCode,
      );
    }

    throw FastApiClientException('API request failed: $lastError');
  }

  dynamic _decodePayload(String body) {
    if (body.isEmpty) {
      return const <String, dynamic>{};
    }
    return jsonDecode(body);
  }

  bool _isRetriableStatus(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  Future<void> _retryDelay(int attempt) {
    final baseMs = 220 * (1 << attempt);
    final jitterMs = _random.nextInt(140);
    return Future<void>.delayed(Duration(milliseconds: baseMs + jitterMs));
  }

  void _setCache(String key, dynamic value, Duration ttl) {
    _cache[key] = _CacheEntry<dynamic>(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );

    if (_cache.length <= _maxCacheEntries) return;

    final oldestKey = _cache.entries
        .reduce((a, b) => a.value.expiresAt.isBefore(b.value.expiresAt) ? a : b)
        .key;
    _cache.remove(oldestKey);
  }

  void _evictExpired() {
    if (_cache.isEmpty) return;
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => entry.expiresAt.isBefore(now));
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  const _CacheEntry({required this.value, required this.expiresAt});
}
