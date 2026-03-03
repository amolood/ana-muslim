import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/reciter.dart';

/// Progress callback: receives bytes downloaded and total bytes.
typedef DownloadProgressCallback = void Function(int received, int total);

class AudioDownloadService {
  static const Set<String> _forceHttpHosts = {
    'naqaa.studio',
    'www.naqaa.studio',
  };

  static Future<Directory> _audioDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/quran_audio');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static String _safeMoshafKey(Moshaf moshaf) {
    final raw = moshaf.server.trim().isNotEmpty
        ? moshaf.server
        : 'moshaf_${moshaf.id}';
    final safe = raw
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (safe.isEmpty) return 'moshaf_${moshaf.id}';
    return safe;
  }

  static Future<Directory> _moshafDir(Moshaf moshaf) async {
    final base = await _audioDir();
    final folder = Directory('${base.path}/${_safeMoshafKey(moshaf)}');
    if (!folder.existsSync()) folder.createSync(recursive: true);
    return folder;
  }

  // ── Local file path ─────────────────────────────────────────────────────
  static Future<String> localPath(Moshaf moshaf, int surahNumber) async {
    final folder = await _moshafDir(moshaf);
    final padded = surahNumber.toString().padLeft(3, '0');
    return '${folder.path}/$padded.mp3';
  }

  // ── Check if a surah is already downloaded ──────────────────────────────
  static Future<bool> isDownloaded(Moshaf moshaf, int surahNumber) async {
    final path = await localPath(moshaf, surahNumber);
    return File(path).existsSync();
  }

  // ── Download a single surah ──────────────────────────────────────────────
  static Future<String> downloadSurah(
    Moshaf moshaf,
    int surahNumber, {
    DownloadProgressCallback? onProgress,
  }) async {
    final path = await localPath(moshaf, surahNumber);
    final file = File(path);

    if (file.existsSync()) return path;

    final sourceUrl = _normalizeNetworkUrl(moshaf.surahUrl(surahNumber));
    final candidates = _withHttpFallbackCandidate(sourceUrl);

    Object? lastError;
    for (var i = 0; i < candidates.length; i++) {
      final url = candidates[i];
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);
        if (response.statusCode >= 400) {
          throw HttpException(
            'Failed to download audio (HTTP ${response.statusCode})',
            uri: Uri.parse(url),
          );
        }
        final total = response.contentLength ?? 0;
        final sink = file.openWrite();
        try {
          // Fast path for background batch downloads:
          // avoid per-chunk Dart callbacks when progress UI is not needed.
          if (onProgress == null) {
            await response.stream.pipe(sink);
          } else {
            int received = 0;
            int lastReportedReceived = 0;
            var lastReportAt = DateTime.fromMillisecondsSinceEpoch(0);

            await for (final chunk in response.stream) {
              sink.add(chunk);
              received += chunk.length;

              final now = DateTime.now();
              final shouldReportByTime =
                  now.difference(lastReportAt) >=
                  const Duration(milliseconds: 120);
              final shouldReportByBytes =
                  total > 0 &&
                  (received - lastReportedReceived) >= (total ~/ 100);
              final isDone = total > 0 && received >= total;

              if (shouldReportByTime || shouldReportByBytes || isDone) {
                onProgress(received, total);
                lastReportAt = now;
                lastReportedReceived = received;
              }
            }

            if (received != lastReportedReceived) {
              onProgress(received, total);
            }
          }
        } finally {
          await sink.flush();
          await sink.close();
        }
        return path;
      } catch (e) {
        if (file.existsSync()) file.deleteSync();
        lastError = e;
        final hasFallback = i < candidates.length - 1;
        if (!(hasFallback && _isSslLikeFailure(e))) {
          rethrow;
        }
      } finally {
        client.close();
      }
    }

    if (lastError is Exception) {
      throw lastError;
    }
    throw Exception('Failed to download surah audio');
  }

  // ── Insecure fallback for broken SSL sources ─────────────────────────────
  // Only used when strict HTTPS validation fails on certain content hosts.
  static Future<String> downloadSurahInsecure(
    Moshaf moshaf,
    int surahNumber, {
    DownloadProgressCallback? onProgress,
  }) async {
    final path = await localPath(moshaf, surahNumber);
    final file = File(path);
    if (file.existsSync()) return path;

    final sourceUrl = moshaf.surahUrl(surahNumber);
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw const FormatException('Invalid surah source URL');
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    client.badCertificateCallback = (cert, host, port) {
      Object.hash(cert, host, port);
      return true;
    };

    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode >= 400) {
        throw HttpException(
          'Failed to download audio (HTTP ${response.statusCode})',
          uri: uri,
        );
      }

      final total = response.contentLength;
      final sink = file.openWrite();
      try {
        if (onProgress == null) {
          await response.pipe(sink);
        } else {
          int received = 0;
          int lastReportedReceived = 0;
          var lastReportAt = DateTime.fromMillisecondsSinceEpoch(0);

          await for (final chunk in response) {
            sink.add(chunk);
            received += chunk.length;

            final now = DateTime.now();
            final shouldReportByTime =
                now.difference(lastReportAt) >=
                const Duration(milliseconds: 120);
            final shouldReportByBytes =
                total > 0 &&
                (received - lastReportedReceived) >=
                    ((total ~/ 100).clamp(1, 1 << 30));
            final isDone = total > 0 && received >= total;

            if (shouldReportByTime || shouldReportByBytes || isDone) {
              onProgress(received, total);
              lastReportAt = now;
              lastReportedReceived = received;
            }
          }

          if (received != lastReportedReceived) {
            onProgress(received, total);
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }
      return path;
    } catch (_) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  static Future<String> ensureLocalPlaybackFile(
    Moshaf moshaf,
    int surahNumber, {
    DownloadProgressCallback? onProgress,
  }) async {
    final path = await localPath(moshaf, surahNumber);
    final file = File(path);
    if (file.existsSync()) return path;

    try {
      return await downloadSurah(moshaf, surahNumber, onProgress: onProgress);
    } catch (error) {
      final uri = Uri.tryParse(moshaf.surahUrl(surahNumber));
      final couldBeSslIssue =
          _isSslLikeFailure(error) || uri?.scheme == 'https';
      if (!couldBeSslIssue) rethrow;
      return downloadSurahInsecure(moshaf, surahNumber, onProgress: onProgress);
    }
  }

  // ── Download all surahs in a moshaf ─────────────────────────────────────
  static Future<void> downloadMoshaf(
    Moshaf moshaf, {
    ValueChanged<double>? onProgress, // 0.0 – 1.0
    ValueChanged<String>? onStatus,
  }) async {
    final total = moshaf.surahList.length;
    int done = 0;

    for (final surahNum in moshaf.surahList) {
      onStatus?.call(
        'تحميل سورة ${surahNum.toString().padLeft(3, '0')} ($done/$total)',
      );
      try {
        await downloadSurah(moshaf, surahNum);
      } catch (_) {
        // Skip failed surahs
      }
      done++;
      onProgress?.call(done / total);
    }
  }

  // ── Get playback URL (local if downloaded, else network) ─────────────────
  static Future<String> getPlaybackUrl(Moshaf moshaf, int surahNumber) async {
    if (await isDownloaded(moshaf, surahNumber)) {
      return 'file://${await localPath(moshaf, surahNumber)}';
    }
    return _normalizeNetworkUrl(moshaf.surahUrl(surahNumber));
  }

  static List<String> _withHttpFallbackCandidate(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return [url];
    final fallback = uri.replace(scheme: 'http').toString();
    if (fallback == url) return [url];
    return [url, fallback];
  }

  static String _normalizeNetworkUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return url;
    if (!_forceHttpHosts.contains(uri.host.toLowerCase())) return url;
    return uri.replace(scheme: 'http').toString();
  }

  static bool _isSslLikeFailure(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('ssl') ||
        message.contains('certificate') ||
        message.contains('handshake') ||
        message.contains('chain validation');
  }

  // ── Delete a downloaded moshaf ───────────────────────────────────────────
  static Future<void> deleteMoshaf(Moshaf moshaf) async {
    final dir = await _audioDir();
    final folder = Directory('${dir.path}/${_safeMoshafKey(moshaf)}');
    if (folder.existsSync()) folder.deleteSync(recursive: true);
  }

  // ── Count downloaded surahs for a moshaf ────────────────────────────────
  static Future<int> downloadedCount(Moshaf moshaf) async {
    final dir = await _audioDir();
    final folder = Directory('${dir.path}/${_safeMoshafKey(moshaf)}');
    if (!folder.existsSync()) return 0;
    return folder
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.mp3'))
        .length;
  }

  // ── Total storage used (bytes) ───────────────────────────────────────────
  static Future<int> totalStorageBytes() async {
    final dir = await _audioDir();
    if (!dir.existsSync()) return 0;
    int bytes = 0;
    for (final e in dir.listSync(recursive: true).whereType<File>()) {
      bytes += e.lengthSync();
    }
    return bytes;
  }
}
