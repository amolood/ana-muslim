import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RemoteFontLoader {
  RemoteFontLoader._();

  static const qpcFontFamily = 'KFGQPC Uthmanic Script';
  static const _qpcFontUrl = String.fromEnvironment(
    'QPC_FONT_URL',
    defaultValue: '',
  );

  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;

    final url = _qpcFontUrl.trim();
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return;
    }

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return;

      final byteData = ByteData.view(
        Uint8List.fromList(response.bodyBytes).buffer,
      );
      final loader = FontLoader(qpcFontFamily)..addFont(Future.value(byteData));
      await loader.load();
      _loaded = true;
    } catch (_) {
      // Keep default fallback font if remote loading fails.
    }
  }
}
