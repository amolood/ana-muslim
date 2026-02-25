// ignore_for_file: use_build_context_synchronously

part of '../../audio.dart';

/// Extension for playing a range of ayahs with high reliability
/// Supports both same-surah and cross-surah ranges
extension AyahRangeCtrlExtension on AudioCtrl {
  /// Play a range of ayahs from startAyah to endAyah (inclusive)
  ///
  /// Parameters:
  /// - [context]: BuildContext for showing UI elements
  /// - [surahNumber]: The surah number (1-114)
  /// - [startAyah]: First ayah number to play (1-based)
  /// - [endAyah]: Last ayah number to play (1-based, inclusive)
  /// - [loop]: Whether to loop the range (default: false)
  /// - [stopAtEnd]: Whether to stop at the end or continue to next ayah (default: true)
  /// - [ayahAudioStyle]: Optional custom styling
  /// - [ayahDownloadManagerStyle]: Optional download manager styling
  /// - [isDarkMode]: Optional dark mode flag
  ///
  /// Throws:
  /// - ArgumentError if range is invalid
  /// - StateError if audio service is not initialized
  Future<void> playAyahRange({
    required BuildContext context,
    required int surahNumber,
    required int startAyah,
    required int endAyah,
    bool loop = false,
    bool stopAtEnd = true,
    AyahAudioStyle? ayahAudioStyle,
    AyahDownloadManagerStyle? ayahDownloadManagerStyle,
    bool? isDarkMode,
  }) async {
    // Validate input
    _validateAyahRange(surahNumber, startAyah, endAyah);

    // Check if playback is allowed
    if (!await canPlayAudio()) {
      state.isAudioPreparing.value = false;
      return;
    }

    // Enable preparing state
    state.isAudioPreparing.value = true;

    try {
      final bool isDark = isDarkMode ??
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      // Store range info in state for tracking
      state.currentRangeInfo.value = AyahRangeInfo(
        surahNumber: surahNumber,
        startAyah: startAyah,
        endAyah: endAyah,
        loop: loop,
        stopAtEnd: stopAtEnd,
      );

      // Set playing mode
      state.isPlayingRangeMode = true;
      state.playSingleAyahOnly = false;

      // Disable surah position saving
      disableSurahPositionSaving();

      // Show control UI
      QuranCtrl.instance.isShowControl.value = true;

      // Stop any active playback
      if (state.audioPlayer.playing) await pausePlayer();

      // Small delay for UI update
      Future.delayed(
        const Duration(milliseconds: 400),
        () => QuranCtrl.instance.state.isPlayExpanded.value = true,
      );

      // Get ayah unique numbers for the range
      final rangeAyahNumbers = _getAyahRangeUniqueNumbers(
        surahNumber,
        startAyah,
        endAyah,
      );

      if (rangeAyahNumbers.isEmpty) {
        throw StateError('No ayahs found for the specified range');
      }

      // Set current ayah to start
      state.currentAyahUniqueNumber.value = rangeAyahNumbers.first;

      // Play the range
      await _playAyahRangeFile(
        context,
        rangeAyahNumbers,
        ayahAudioStyle: ayahAudioStyle ??
            AyahAudioStyle.defaults(isDark: isDark, context: context),
        ayahDownloadManagerStyle: ayahDownloadManagerStyle ??
            AyahDownloadManagerStyle.defaults(isDark: isDark, context: context),
        isDark: isDark,
      );
    } catch (e) {
      state.isAudioPreparing.value = false;
      state.isPlayingRangeMode = false;
      state.currentRangeInfo.value = null;
      log('Error in playAyahRange: $e', name: 'AyahRangeCtrl');
      ToastUtils().showToast(context, 'خطأ في تشغيل نطاق الآيات: ${e.toString()}');
      rethrow;
    }
  }

  /// Validate ayah range parameters
  void _validateAyahRange(int surahNumber, int startAyah, int endAyah) {
    if (surahNumber < 1 || surahNumber > 114) {
      throw ArgumentError('Invalid surah number: $surahNumber. Must be 1-114');
    }

    final surah = QuranCtrl.instance.surahs
        .firstWhere((s) => s.surahNumber == surahNumber);
    final surahAyahCount = surah.ayahs.length;

    if (startAyah < 1 || startAyah > surahAyahCount) {
      throw ArgumentError(
          'Invalid start ayah: $startAyah. Must be 1-$surahAyahCount for surah $surahNumber');
    }

    if (endAyah < 1 || endAyah > surahAyahCount) {
      throw ArgumentError(
          'Invalid end ayah: $endAyah. Must be 1-$surahAyahCount for surah $surahNumber');
    }

    if (startAyah > endAyah) {
      throw ArgumentError(
          'Start ayah ($startAyah) must be <= end ayah ($endAyah)');
    }
  }

  /// Get unique numbers for ayahs in the range
  List<int> _getAyahRangeUniqueNumbers(
    int surahNumber,
    int startAyah,
    int endAyah,
  ) {
    final surah = QuranCtrl.instance.surahs
        .firstWhere((s) => s.surahNumber == surahNumber);

    return surah.ayahs
        .where((ayah) =>
            ayah.ayahNumber >= startAyah && ayah.ayahNumber <= endAyah)
        .map((ayah) => ayah.ayahUQNumber)
        .toList();
  }

  /// Internal method to play ayah range files
  Future<void> _playAyahRangeFile(
    BuildContext context,
    List<int> ayahUniqueNumbers, {
    required AyahAudioStyle ayahAudioStyle,
    required AyahDownloadManagerStyle ayahDownloadManagerStyle,
    required bool isDark,
  }) async {
    final sw = Stopwatch()..start();
    log('TIMER: _playAyahRangeFile start for ${ayahUniqueNumbers.length} ayahs',
        name: 'AyahRangeTimer');

    if (ayahUniqueNumbers.isEmpty) {
      throw ArgumentError('Ayah range list cannot be empty');
    }

    try {
      // Get surah number from first ayah
      final firstAyahUQ = ayahUniqueNumbers.first;
      final surahNumber = _getSurahNumberFromAyahUQ(firstAyahUQ);

      // Check if all ayahs are downloaded (non-web only)
      if (!kIsWeb) {
        final allDownloaded =
            await _areRangeAyahsDownloaded(ayahUniqueNumbers, surahNumber);

        if (!allDownloaded) {
          await _showAyahDownloadBottomSheet(
            context,
            initialSurahToDownload: surahNumber,
            style: ayahDownloadManagerStyle,
            ayahStyle: ayahAudioStyle,
            isDark: isDark,
          );

          // Recheck after download
          final downloadedNow =
              await _areRangeAyahsDownloaded(ayahUniqueNumbers, surahNumber);
          if (!downloadedNow) {
            state.isAudioPreparing.value = false;
            return;
          }
        }
      }

      log('TIMER: after download check: ${sw.elapsedMilliseconds} ms',
          name: 'AyahRangeTimer');

      // Stop any active playback and cancel subscriptions
      await state.audioPlayer.stop();
      state.cancelAllSubscriptions();

      // Create audio sources for the range
      final List<AudioSource> audioSources;

      if (kIsWeb) {
        audioSources = await _createWebAudioSourcesForRange(ayahUniqueNumbers);
      } else {
        audioSources =
            await _createLocalAudioSourcesForRange(ayahUniqueNumbers);
      }

      if (audioSources.isEmpty) {
        throw StateError('Failed to create audio sources for range');
      }

      log('TIMER: audio sources created: ${sw.elapsedMilliseconds} ms',
          name: 'AyahRangeTimer');

      // Set audio sources
      await state.audioPlayer.setAudioSources(
        audioSources,
        initialIndex: 0,
      );

      // Configure playlist
      await state.audioPlayer.setShuffleModeEnabled(false);

      // Set loop mode based on range settings
      final rangeInfo = state.currentRangeInfo.value;
      await state.audioPlayer.setLoopMode(
        rangeInfo?.loop == true ? LoopMode.all : LoopMode.off,
      );

      log('${'-' * 30} range player starting.. ${'-' * 30}',
          name: 'AyahRangeCtrl');

      // Setup range playback listener
      _setupRangePlaybackListener(ayahUniqueNumbers);

      state.isPlaying.value = true;
      state.isAudioPreparing.value = false;
      await state.audioPlayer.play();

      log('TIMER: playback started: ${sw.elapsedMilliseconds} ms',
          name: 'AyahRangeTimer');
    } catch (e) {
      state.isAudioPreparing.value = false;
      state.isPlaying.value = false;
      state.isPlayingRangeMode = false;
      state.currentRangeInfo.value = null;
      await state.audioPlayer.stop();
      log('Error in _playAyahRangeFile: $e', name: 'AyahRangeCtrl');
      ToastUtils().showToast(context, 'خطأ في تشغيل نطاق الآيات: ${e.toString()}');
      rethrow;
    }
  }

  /// Check if all ayahs in range are downloaded
  Future<bool> _areRangeAyahsDownloaded(
      List<int> ayahUniqueNumbers, int surahNumber) async {
    if (kIsWeb) return false;

    try {
      final surah = QuranCtrl.instance.surahs
          .firstWhere((s) => s.surahNumber == surahNumber);
      final dir = await state.dir;

      for (final ayahUQ in ayahUniqueNumbers) {
        final ayah =
            surah.ayahs.firstWhere((a) => a.ayahUQNumber == ayahUQ);
        final fileName = _ayahFileNameFor(surahNumber, ayah.ayahNumber);
        final path = join(dir.path, fileName);
        if (!await File(path).exists()) {
          return false;
        }
      }
      return true;
    } catch (e) {
      log('Error checking range downloads: $e', name: 'AyahRangeCtrl');
      return false;
    }
  }

  /// Get surah number from ayah unique number
  int _getSurahNumberFromAyahUQ(int ayahUQ) {
    for (final surah in QuranCtrl.instance.surahs) {
      if (surah.ayahs.any((a) => a.ayahUQNumber == ayahUQ)) {
        return surah.surahNumber;
      }
    }
    throw ArgumentError('Invalid ayah unique number: $ayahUQ');
  }

  /// Create web audio sources for range
  Future<List<AudioSource>> _createWebAudioSourcesForRange(
      List<int> ayahUniqueNumbers) async {
    final List<AudioSource> sources = [];

    for (final ayahUQ in ayahUniqueNumbers) {
      final surahNumber = _getSurahNumberFromAyahUQ(ayahUQ);
      final surah = QuranCtrl.instance.surahs
          .firstWhere((s) => s.surahNumber == surahNumber);
      final ayah = surah.ayahs.firstWhere((a) => a.ayahUQNumber == ayahUQ);

      // Build URL for web
      final fileName = _ayahFileNameFor(surahNumber, ayah.ayahNumber);
      final url = '$ayahDownloadSource$fileName';

      final mediaItem = MediaItem(
        id: ayahUQ.toString(),
        title: 'سورة ${surah.arabicName}',
        displayTitle: 'الآية ${ayah.ayahNumber}',
        displaySubtitle: 'سورة ${surah.arabicName}',
        artist: ayahReaderName,
        artUri: state.cachedArtUri,
      );

      sources.add(AudioSource.uri(
        Uri.parse(url),
        tag: mediaItem,
      ));
    }

    return sources;
  }

  /// Create local audio sources for range
  Future<List<AudioSource>> _createLocalAudioSourcesForRange(
      List<int> ayahUniqueNumbers) async {
    final List<AudioSource> sources = [];
    final dir = await state.dir;

    for (final ayahUQ in ayahUniqueNumbers) {
      final surahNumber = _getSurahNumberFromAyahUQ(ayahUQ);
      final surah = QuranCtrl.instance.surahs
          .firstWhere((s) => s.surahNumber == surahNumber);
      final ayah = surah.ayahs.firstWhere((a) => a.ayahUQNumber == ayahUQ);

      final fileName = _ayahFileNameFor(surahNumber, ayah.ayahNumber);
      final filePath = join(dir.path, fileName);

      final mediaItem = MediaItem(
        id: ayahUQ.toString(),
        title: 'سورة ${surah.arabicName}',
        displayTitle: 'الآية ${ayah.ayahNumber}',
        displaySubtitle: 'سورة ${surah.arabicName}',
        artist: ayahReaderName,
        artUri: state.cachedArtUri,
      );

      sources.add(AudioSource.file(
        filePath,
        tag: mediaItem,
      ));
    }

    return sources;
  }

  /// Setup listener for range playback to track progress and handle completion
  void _setupRangePlaybackListener(List<int> ayahUniqueNumbers) {
    int? lastHandledIndex;

    // Listen to sequence state for index changes
    state._currentIndexSubscription =
        state.audioPlayer.sequenceStateStream.listen((sequenceState) async {
      final index = sequenceState.currentIndex;
      if (index == null || index < 0 || index >= ayahUniqueNumbers.length) {
        return;
      }

      // Ignore duplicate index events
      if (lastHandledIndex == index) {
        return;
      }
      lastHandledIndex = index;

      // Update current ayah
      final newAyahUQ = ayahUniqueNumbers[index];
      state.currentAyahUniqueNumber.value = newAyahUQ;

      // Update visual selection
      QuranCtrl.instance.toggleAyahSelection(newAyahUQ);

      // Handle page navigation
      final newPage =
          QuranCtrl.instance.getPageNumberByAyahUqNumber(newAyahUQ);
      final currentPage = QuranCtrl.instance.state.currentPageNumber.value;

      if (newPage != currentPage) {
        log('Range: Page changed to $newPage', name: 'AyahRangeCtrl');
        await QuranCtrl.instance.quranPagesController.animateToPage(
          newPage - 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }

      log('Range: Playing ayah $index/${ayahUniqueNumbers.length} (UQ: $newAyahUQ)',
          name: 'AyahRangeCtrl');
    });

    // Listen to player state for completion
    state._playerStateSubscription =
        state.audioPlayer.playerStateStream.listen((playerState) async {
      if (playerState.processingState == ProcessingState.completed) {
        final rangeInfo = state.currentRangeInfo.value;

        if (rangeInfo?.stopAtEnd == true && rangeInfo?.loop != true) {
          log('Range playback completed. Stopping.', name: 'AyahRangeCtrl');
          state.isPlaying.value = false;
          state.isPlayingRangeMode = false;
          state.currentRangeInfo.value = null;
          await state.audioPlayer.stop();
        } else if (rangeInfo?.loop != true) {
          // Continue to next ayah if not stopping and not looping
          log('Range playback completed. Ready for next action.',
              name: 'AyahRangeCtrl');
        }
      }
    });
  }

  /// Helper to get ayah file name (reuse from ayah_ctrl_extension)
  String _ayahFileNameFor(int surahNumber, int ayahNumberInSurah) {
    if (ReadersConstants.activeAyahReaders[state.ayahReaderIndex.value].url ==
        ReadersConstants.ayahs1stSource) {
      final aq = QuranCtrl.instance.surahs
          .firstWhere((s) => s.surahNumber == surahNumber)
          .ayahs[ayahNumberInSurah - 1]
          .ayahUQNumber;
      return '$ayahReaderValue/$aq.mp3';
    } else {
      final s = surahNumber.toString().padLeft(3, '0');
      final a = ayahNumberInSurah.toString().padLeft(3, '0');
      return '$ayahReaderValue/$s$a.mp3';
    }
  }

  /// Stop range playback and clean up
  Future<void> stopRangePlayback() async {
    if (!state.isPlayingRangeMode) return;

    log('Stopping range playback', name: 'AyahRangeCtrl');
    state.isPlaying.value = false;
    state.isPlayingRangeMode = false;
    state.currentRangeInfo.value = null;
    await state.audioPlayer.stop();
    state.cancelAllSubscriptions();
  }

  /// Skip to next ayah in range
  Future<void> skipNextInRange() async {
    if (!state.isPlayingRangeMode) {
      log('Not in range mode, using normal skip', name: 'AyahRangeCtrl');
      return;
    }

    final currentIndex = state.audioPlayer.currentIndex;
    if (currentIndex == null) return;

    final rangeInfo = state.currentRangeInfo.value;
    if (rangeInfo == null) return;

    await state.audioPlayer.seekToNext();
    log('Range: Skipped to next ayah', name: 'AyahRangeCtrl');
  }

  /// Skip to previous ayah in range
  Future<void> skipPreviousInRange() async {
    if (!state.isPlayingRangeMode) {
      log('Not in range mode, using normal skip', name: 'AyahRangeCtrl');
      return;
    }

    final currentIndex = state.audioPlayer.currentIndex;
    if (currentIndex == null) return;

    final rangeInfo = state.currentRangeInfo.value;
    if (rangeInfo == null) return;

    await state.audioPlayer.seekToPrevious();
    log('Range: Skipped to previous ayah', name: 'AyahRangeCtrl');
  }
}

/// Model class to hold range playback information
class AyahRangeInfo {
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final bool loop;
  final bool stopAtEnd;

  AyahRangeInfo({
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.loop,
    required this.stopAtEnd,
  });

  int get ayahCount => endAyah - startAyah + 1;

  @override
  String toString() {
    return 'AyahRangeInfo(surah: $surahNumber, range: $startAyah-$endAyah, count: $ayahCount, loop: $loop, stopAtEnd: $stopAtEnd)';
  }
}
