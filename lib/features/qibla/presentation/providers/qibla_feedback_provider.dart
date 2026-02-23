import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/providers/preferences_provider.dart';

final qiblaTonePlayerProvider = Provider<QiblaTonePlayer>((ref) {
  final player = QiblaTonePlayer();
  ref.onDispose(player.dispose);
  return player;
});

class QiblaTonePlayer {
  final AudioPlayer _player = AudioPlayer();
  String? _loadedUrl;

  Future<void> play(QiblaSuccessToneOption option) async {
    final path = option.assetPath.trim();
    if (path.isEmpty) {
      return;
    }

    if (_loadedUrl != path) {
      await _player.setAsset(path);
      _loadedUrl = path;
    }
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
