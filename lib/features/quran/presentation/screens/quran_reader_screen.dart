import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_utils.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../../data/models/reciter.dart';
import '../providers/audio_providers.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/colored_bookmark_sheet.dart';
import '../widgets/quran_audio_sheet.dart';
import '../widgets/quran_font_size_sheet.dart';
import '../widgets/quran_juz_picker_sheet.dart';
import '../widgets/quran_page_jump_dialog.dart';
import '../widgets/quran_page_mode_reader.dart';
import '../widgets/quran_reader_bottom_toolbar.dart';
import '../widgets/quran_reader_header.dart';
import '../widgets/quran_word_info_sheet.dart';
import '../widgets/surah_ornament_title.dart';
import '../widgets/tafsir_bottom_sheet.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialVerse,
    this.initialPage,
  });

  final int surahNumber;
  final int? initialVerse;
  final int? initialPage;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late int _selectedVerse;
  late int _currentPage;
  late PageController _pageController;

  bool _isPageMode = false;
  int _lastKhatmahSuccessPage = -1;

  int get _activeSurahNumber => _isPageMode
      ? QuranService.getSurahNumberFromPage(_currentPage)
      : widget.surahNumber;

  @override
  void initState() {
    super.initState();
    final verseCount = QuranService.getVerseCount(widget.surahNumber);
    final initialVerse = (widget.initialVerse ?? 1).clamp(1, verseCount);
    final inferredPage = QuranService.getPageNumber(
      widget.surahNumber,
      initialVerse,
    );
    _currentPage = QuranService.clampPage(widget.initialPage ?? inferredPage);
    _selectedVerse = widget.initialPage != null
        ? -1
        : (widget.initialVerse != null ? initialVerse : -1);
    _isPageMode = widget.initialPage != null;
    _pageController = PageController(initialPage: _currentPage - 1);
    QuranService.preloadSurah(widget.surahNumber);
    QuranService.preloadPage(_currentPage);

    Future.microtask(() async {
      await ref
          .read(lastReadSurahProvider.notifier)
          .save(QuranService.getSurahNumberFromPage(_currentPage));
      await ref.read(lastReadPageProvider.notifier).save(_currentPage);
      await _syncReadingProgress(_currentPage, showMessage: false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranFontSize = ref.watch(quranFontSizeProvider);
    final favorites = ref.watch(favoriteSurahsProvider);
    final isFavorite = favorites.contains(widget.surahNumber);
    final controlsVisible = ref.watch(quranReaderControlsVisibleProvider);

    final verseColor = context.colors.textPrimary;
    final surahVerseCount = QuranService.getVerseCount(widget.surahNumber);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: const Opacity(opacity: 0.03, child: SizedBox.expand()),
          ),
          SafeArea(
            child: Column(
              children: [
                QuranReaderHeader(
                  surahNumber: widget.surahNumber,
                  isPageMode: _isPageMode,
                  currentPage: _currentPage,
                  selectedVerse: _selectedVerse,
                  onBack: () => context.pop(),
                  onToggleFavorite: _toggleFavorite,
                  onToggleMode: _onToggleMode,
                  onJuzPicker: _openJuzPicker,
                  onFontSize: _showFontSizeSheet,
                ),
                Expanded(
                  child: _isPageMode
                      ? QuranPageModeReader(
                          pageController: _pageController,
                          quranFontSize: quranFontSize,
                          textColor: verseColor,
                          onPageChanged: _onPageModePageChanged,
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 18,
                            right: 18,
                            top: 8,
                            bottom: 100,
                          ),
                          child: Column(
                            children: [
                              _buildSurahOrnamentTitle(),
                              if (widget.surahNumber != 1 &&
                                  widget.surahNumber != 9) ...[
                                const SizedBox(height: 8),
                                _buildBasmalah(quranFontSize, verseColor),
                                const SizedBox(height: 12),
                              ] else
                                const SizedBox(height: 12),
                              RichText(
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  children: [
                                    for (int i = 1; i <= surahVerseCount; i++)
                                      _buildVerseSpan(
                                        i,
                                        quranFontSize,
                                        verseColor,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: controlsVisible
                  ? Consumer(
                      builder: (context, localRef, _) {
                        final audioState = localRef.watch(quranAudioProvider);
                        final isListenActive = audioState.hasAudio &&
                            audioState.surahNumber == _activeSurahNumber;
                        return QuranReaderBottomToolbar(
                          key: const ValueKey('controls-shown'),
                          isPageMode: _isPageMode,
                          isFavorite: isFavorite,
                          isListenActive: isListenActive,
                          audioState: audioState,
                          currentPage: _currentPage,
                          totalPages: QuranService.totalPagesCount,
                          onFontSize: _showFontSizeSheet,
                          onBookmark: _toggleFavorite,
                          onLongPressBookmark: _openColoredBookmarkSheet,
                          onTafsir: _openTafsir,
                          onWordInfo: _openWordInfo,
                          onListen: _handleListenTap,
                          onLongPressListen: _openAudioSheet,
                          onShare: _shareSelectedVerse,
                          onTogglePlayPause: () async {
                            if (audioState.isLoading) return;
                            final notifier =
                                ref.read(quranAudioProvider.notifier);
                            if (audioState.isPlaying) {
                              await notifier.pause();
                            } else {
                              await notifier.resume();
                            }
                          },
                          onStop: () =>
                              ref.read(quranAudioProvider.notifier).stop(),
                          onAudioSettings: _openAudioSheet,
                          onPrevPage: _currentPage > 1
                              ? () => _goToPage(_currentPage - 1)
                              : null,
                          onNextPage:
                              _currentPage < QuranService.totalPagesCount
                                  ? () => _goToPage(_currentPage + 1)
                                  : null,
                          onJumpPage: _openPageJumpDialog,
                        );
                      },
                    )
                  : QuranReaderControlsHint(
                      key: const ValueKey('controls-hidden'),
                      onShow: () => ref
                          .read(quranReaderControlsVisibleProvider.notifier)
                          .save(true),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mode toggle ──────────────────────────────────────────────────────────

  void _onToggleMode() {
    setState(() {
      _isPageMode = !_isPageMode;
      if (_isPageMode) _selectedVerse = -1;
    });
  }

  // ─── Page mode page-change handler ────────────────────────────────────────

  Future<void> _onPageModePageChanged(int page) async {
    if (_currentPage == page) return;
    setState(() {
      _currentPage = page;
      _selectedVerse = -1;
    });
    await _persistReadProgress(page);
    await _syncReadingProgress(page);
  }

  // ─── Surah mode builders ──────────────────────────────────────────────────

  Widget _buildBasmalah(double fontSize, Color textColor) {
    return Text(
      QuranService.basmala,
      style: _quranTextStyle(size: fontSize + 4, color: textColor, height: 1.8),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSurahOrnamentTitle() =>
      SurahOrnamentTitle(surahNumber: widget.surahNumber);

  TextStyle _quranTextStyle({
    required double size,
    required Color color,
    required double height,
  }) {
    return QuranLibrary().hafsStyle.copyWith(
          fontSize: size,
          height: height,
          color: color,
        );
  }

  InlineSpan _buildVerseSpan(
    int verseNumber,
    double quranFontSize,
    Color textColor,
  ) {
    final isSelected = _selectedVerse == verseNumber;
    final isSajdah = QuranService.isSajdahVerse(
      widget.surahNumber,
      verseNumber,
    );
    final separatorColor = isSelected
        ? AppColors.mushafGold
        : AppColors.mushafGold.withValues(alpha: 0.86);

    final ayahId =
        QuranService.getAyahUniqueNumber(widget.surahNumber, verseNumber);
    final bookmarkColor =
        ref.read(coloredBookmarksProvider.notifier).getBookmarkColor(ayahId);

    return TextSpan(
      children: [
        TextSpan(
          text: QuranService.getVerse(
            widget.surahNumber,
            verseNumber,
            verseEndSymbol: false,
          ),
          style: _quranTextStyle(
            size: quranFontSize,
            color: textColor,
            height: 2.1,
          ).copyWith(
            backgroundColor: isSelected
                ? AppColors.mushafGold.withValues(alpha: 0.12)
                : null,
          ),
        ),
        if (isSajdah)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SvgPicture.asset(
                'packages/quran_library/assets/svg/sajdaIcon.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  AppColors.mushafGold,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _selectVerse(verseNumber),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'packages/quran_library/assets/svg/suraNum.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppColors.mushafGold : separatorColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  if (bookmarkColor != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(bookmarkColor.colorCode),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    _toArabicNumber(verseNumber),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.mushafGold
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const TextSpan(text: ' '),
      ],
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> _goToPage(int page) async {
    final target = QuranService.clampPage(page);
    QuranService.preloadPage(target);
    if (target > 1) QuranService.preloadPage(target - 1);
    if (target < QuranService.totalPagesCount) {
      QuranService.preloadPage(target + 1);
    }
    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        target - 1,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    if (_currentPage == target) return;
    setState(() {
      _currentPage = target;
      _selectedVerse = -1;
    });
    await _persistReadProgress(target);
    await _syncReadingProgress(target);
  }

  void _selectVerse(int verseNumber) async {
    setState(() {
      _selectedVerse = verseNumber;
      _currentPage = QuranService.getPageNumber(
        widget.surahNumber,
        verseNumber,
      );
    });
    await _persistReadProgress(_currentPage);
    await _syncReadingProgress(_currentPage);
  }

  Future<void> _persistReadProgress(int page) async {
    final surah = QuranService.getSurahNumberFromPage(page);
    await ref.read(lastReadSurahProvider.notifier).save(surah);
    await ref.read(lastReadPageProvider.notifier).save(page);
  }

  Future<void> _syncReadingProgress(
    int page, {
    bool showMessage = true,
  }) async {
    final reachedTodayTarget = await ref
        .read(khatmahControllerProvider.notifier)
        .syncFromReadingPage(page);

    if (!reachedTodayTarget || !showMessage) return;
    if (!mounted || _lastKhatmahSuccessPage == page) return;
    _lastKhatmahSuccessPage = page;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'ممتاز، أنجزت وردك اليومي في الختمة',
          style: GoogleFonts.tajawal(),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  // ─── Sheet / dialog openers ───────────────────────────────────────────────

  Future<void> _openJuzPicker() async {
    if (!_isPageMode) return;
    await showQuranJuzPickerSheet(context, onPageSelected: _goToPage);
  }

  Future<void> _openPageJumpDialog() async {
    final page = await showDialog<int>(
      context: context,
      builder: (ctx) => QuranPageJumpDialog(initialPage: _currentPage),
    );

    if (!mounted) return;
    if (page == null) return;
    if (page < 1 || page > QuranService.totalPagesCount) {
      _showAudioSnack('رقم الصفحة غير صحيح');
      return;
    }
    await _goToPage(page);
  }

  Future<void> _showFontSizeSheet() => showQuranFontSizeSheet(context, ref);

  Future<void> _toggleFavorite() async {
    await ref.read(favoriteSurahsProvider.notifier).toggle(widget.surahNumber);
    if (!mounted) return;
    final isFavorite =
        ref.read(favoriteSurahsProvider).contains(widget.surahNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'تمت إضافة السورة إلى المفضلة'
              : 'تمت إزالة السورة من المفضلة',
          style: GoogleFonts.tajawal(),
        ),
      ),
    );
  }

  Future<void> _openTafsir() async {
    if (!mounted) return;
    final surahNumber = _isPageMode ? _activeSurahNumber : widget.surahNumber;
    final ayahNumber = _isPageMode
        ? QuranService.getFirstAyahNumberOnPage(_currentPage)
        : _selectedVerse;
    final ayahUq = QuranService.getAyahUniqueNumber(surahNumber, ayahNumber);
    await showTafsirSheet(
      context,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahUQNumber: ayahUq,
    );
  }

  Future<void> _openWordInfo() async {
    if (!mounted) return;
    final surahNumber = _isPageMode ? _activeSurahNumber : widget.surahNumber;
    final ayahNumber = _isPageMode
        ? QuranService.getFirstAyahNumberOnPage(_currentPage)
        : _selectedVerse;
    await showQuranWordInfoSheet(
      context,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  Future<void> _openColoredBookmarkSheet() async {
    if (!mounted) return;
    final surahNumber = _isPageMode ? _activeSurahNumber : widget.surahNumber;
    final ayahNumber = _isPageMode
        ? QuranService.getFirstAyahNumberOnPage(_currentPage)
        : (_selectedVerse > 0 ? _selectedVerse : 1);
    await showColoredBookmarkSheet(
      context,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }

  // ─── Audio ────────────────────────────────────────────────────────────────

  Future<void> _handleListenTap() async {
    final audioState = ref.read(quranAudioProvider);
    final notifier = ref.read(quranAudioProvider.notifier);

    if (audioState.hasAudio && audioState.surahNumber == _activeSurahNumber) {
      if (audioState.isPlaying) {
        await notifier.pause();
      } else {
        await notifier.resume();
      }
      return;
    }

    await _playWithDefaultReciter();
  }

  Future<void> _playWithDefaultReciter() async {
    final notifier = ref.read(quranAudioProvider.notifier);

    try {
      final reciters = await ref.read(recitersProvider.future);
      if (reciters.isEmpty) {
        _showAudioSnack('لا يوجد قراء متاحون حالياً');
        return;
      }

      final defaultReciterId = ref.read(defaultReciterIdProvider);
      final preferredMap = ref.read(preferredReciterMoshafProvider);

      Reciter? reciter;
      if (defaultReciterId != null) {
        for (final item in reciters) {
          if (item.id == defaultReciterId &&
              item.moshafForSurah(_activeSurahNumber) != null) {
            reciter = item;
            break;
          }
        }
      }

      reciter ??= _fallbackNoreenReciter(reciters);
      reciter ??= _firstAvailableReciter(reciters);

      if (reciter == null) {
        _showAudioSnack('لا يتوفر قارئ لهذه السورة');
        return;
      }

      final moshaf = reciter.preferredMoshafForSurah(
        _activeSurahNumber,
        preferredMoshafId: preferredMap[reciter.id],
      );
      if (moshaf == null) {
        _showAudioSnack('لا تتوفر رواية مناسبة لهذه السورة');
        return;
      }

      if (defaultReciterId == null) {
        await ref.read(defaultReciterIdProvider.notifier).save(reciter.id);
        await ref.read(defaultReciterNameProvider.notifier).save(reciter.name);
      }

      await ref
          .read(preferredReciterMoshafProvider.notifier)
          .saveSelection(reciter.id, moshaf.id);

      await notifier.play(reciter, moshaf, _activeSurahNumber);
    } catch (_) {
      _showAudioSnack('تعذر تشغيل القراءة، تحقق من اتصال الإنترنت');
    }
  }

  Reciter? _fallbackNoreenReciter(List<Reciter> reciters) {
    for (final reciter in reciters) {
      final normalizedName = ArabicUtils.normalizeArabic(reciter.name);
      if (!normalizedName.contains('نورين')) continue;
      if (reciter.moshafForSurah(_activeSurahNumber) != null) return reciter;
    }
    return null;
  }

  Reciter? _firstAvailableReciter(List<Reciter> reciters) {
    for (final reciter in reciters) {
      if (reciter.moshafForSurah(_activeSurahNumber) != null) return reciter;
    }
    return null;
  }

  void _showAudioSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAudioSheet() async {
    if (!mounted) return;
    final targetSurah = _activeSurahNumber;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => QuranAudioSheet(surahNumber: targetSurah),
    );
  }

  // ─── Share ────────────────────────────────────────────────────────────────

  Future<void> _shareSelectedVerse() async {
    if (_isPageMode) {
      final text = QuranService.getPageText(_currentPage);
      await SharePlus.instance.share(
        ShareParams(
          text:
              '$text\n\nالصفحة ${_toArabicNumber(_currentPage)} - الجزء ${_toArabicNumber(QuranService.getJuzByPage(_currentPage))}\nمن تطبيق المسلم',
        ),
      );
      return;
    }

    final verse = QuranService.getVerse(
      widget.surahNumber,
      _selectedVerse,
      verseEndSymbol: false,
    );
    final surahName =
        QuranService.getSurahNameArabicNormalized(widget.surahNumber);
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$verse\n\n$surahName - آية ${_toArabicNumber(_selectedVerse)}\nمن تطبيق المسلم',
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }
}
