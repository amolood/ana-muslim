import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../khatmah/presentation/providers/khatmah_controller.dart';
import '../../data/models/reciter.dart';
import '../providers/audio_providers.dart';
import '../widgets/surah_title_text.dart';
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
  static const String _qpcFontFamily = 'KFGQPC Uthmanic Script';
  static const String _hafsFontFamily = _qpcFontFamily;
  static const Color _mushafGold = Color(0xFFD6B06B);

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final verseColor = isDark ? Colors.white : AppColors.textPrimaryLight;
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
                _buildHeader(),
                Expanded(
                  child: _isPageMode
                      ? _buildPageModeReader(quranFontSize, verseColor)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 16,
                            bottom: 120,
                          ),
                          child: Column(
                            children: [
                              _buildSurahOrnamentTitle(),
                              const SizedBox(height: 16),
                              if (widget.surahNumber != 1 &&
                                  widget.surahNumber != 9)
                                _buildBasmalah(quranFontSize, verseColor),
                              const SizedBox(height: 16),
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
            bottom: 24,
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
                        return _buildBottomToolbar(
                          key: const ValueKey('controls-shown'),
                          isFavorite: isFavorite,
                          audioState: audioState,
                        );
                      },
                    )
                  : _buildControlsCollapsedHint(
                      key: const ValueKey('controls-hidden'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageModeReader(double quranFontSize, Color textColor) {
    return PageView.builder(
      controller: _pageController,
      reverse: false,
      itemCount: QuranService.totalPagesCount,
      onPageChanged: (index) async {
        final page = index + 1;
        if (_currentPage == page) return;
        setState(() {
          _currentPage = page;
          _selectedVerse = -1;
        });
        await _persistReadProgress(page);
        await _syncReadingProgress(page);
      },
      itemBuilder: (_, index) {
        final pageNumber = index + 1;
        final pageAyahs = QuranService.getPageAyahs(pageNumber);
        final pageTitle = QuranService.getPageTitle(pageNumber);
        final juz = QuranService.getJuzByPage(pageNumber);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                SurahTitleText(
                  pageTitle,
                  fontSize: 26,
                  maxLines: 1,
                  color: _mushafGold,
                ),
                const SizedBox(height: 6),
                Text(
                  'الجزء ${_toArabicNumber(juz)} • الصفحة ${_toArabicNumber(pageNumber)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: _buildPageTextSpans(
                      pageAyahs: pageAyahs,
                      quranFontSize: quranFontSize,
                      textColor: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final controlsVisible = ref.watch(quranReaderControlsVisibleProvider);
    final headerSurahNumber = _isPageMode
        ? QuranService.getSurahNumberFromPage(_currentPage)
        : widget.surahNumber;
    final juzNumber = _isPageMode
        ? QuranService.getJuzByPage(_currentPage)
        : QuranService.getJuzNumber(
            widget.surahNumber,
            _selectedVerse > 0 ? _selectedVerse : 1,
          );

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SurahTitleText(
                  _isPageMode
                      ? QuranService.getPageTitle(_currentPage)
                      : QuranService.getSurahNameArabicNormalized(
                          widget.surahNumber,
                        ),
                  fontSize: _isPageMode ? 20 : 24,
                  maxLines: 1,
                  color: _mushafGold,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isPageMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          QuranService.getPlaceOfRevelation(
                                    headerSurahNumber,
                                  ) ==
                                  'Makkah'
                              ? 'مكية'
                              : 'مدنية',
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (!_isPageMode) const SizedBox(width: 6),
                    Text(
                      'الجزء ${_toArabicNumber(juzNumber)}',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: controlsVisible ? 'إخفاء الأدوات' : 'إظهار الأدوات',
                onPressed: () => ref
                    .read(quranReaderControlsVisibleProvider.notifier)
                    .save(!controlsVisible),
                icon: Icon(
                  controlsVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
              ),
              IconButton(
                tooltip: _isPageMode ? 'وضع السور' : 'وضع الصفحات',
                onPressed: () => setState(() {
                  _isPageMode = !_isPageMode;
                  if (_isPageMode) {
                    _selectedVerse = -1;
                  }
                }),
                icon: Icon(
                  _isPageMode
                      ? Icons.menu_book_outlined
                      : Icons.chrome_reader_mode_rounded,
                  color: AppColors.primary,
                ),
              ),
              if (_isPageMode)
                IconButton(
                  tooltip: 'الأجزاء',
                  onPressed: _openJuzPicker,
                  icon: const Icon(
                    Icons.view_module_rounded,
                    color: Colors.white70,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  'ص ${_toArabicNumber(_currentPage)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasmalah(double fontSize, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        QuranService.basmala,
        style: _quranTextStyle(
          size: fontSize + 5,
          color: textColor,
          height: 1.9,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSurahOrnamentTitle() {
    final surahName = QuranService.getSurahNameArabicNormalized(
      widget.surahNumber,
    );
    final versesCount = QuranService.getVerseCount(widget.surahNumber);
    final revelationType =
        QuranService.getPlaceOfRevelation(widget.surahNumber) == 'Makkah'
        ? 'مكية'
        : 'مدنية';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF173F38), Color(0xFF102A25)],
        ),
        border: Border.all(
          color: _mushafGold.withValues(alpha: 0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _mushafGold.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: _mushafGold.withValues(alpha: 0.7),
                  thickness: 1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '۞',
                style: TextStyle(
                  fontFamily: _hafsFontFamily,
                  fontSize: 24,
                  color: _mushafGold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: _mushafGold.withValues(alpha: 0.7),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SurahTitleText(
            surahName,
            fontSize: 31,
            maxLines: 2,
            color: _mushafGold,
          ),
          const SizedBox(height: 5),
          Text(
            '$revelationType • ${_toArabicNumber(versesCount)} آيات',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _quranTextStyle({
    required double size,
    required Color color,
    required double height,
  }) {
    return TextStyle(
      fontFamily: _hafsFontFamily,
      fontFamilyFallback: const ['naskh'],
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
        ? _mushafGold
        : _mushafGold.withValues(alpha: 0.86);

    return TextSpan(
      children: [
        TextSpan(
          text: QuranService.getVerse(
            widget.surahNumber,
            verseNumber,
            verseEndSymbol: false,
          ),
          style:
              _quranTextStyle(
                size: quranFontSize,
                color: textColor,
                height: 2.1,
              ).copyWith(
                backgroundColor: isSelected
                    ? _mushafGold.withValues(alpha: 0.12)
                    : null,
              ),
        ),
        if (isSajdah)
          TextSpan(
            text: ' ۩',
            style: _quranTextStyle(
              size: quranFontSize - 2,
              color: _mushafGold,
              height: 2.1,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? _mushafGold.withValues(alpha: 0.20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? _mushafGold : separatorColor,
                  width: isSelected ? 1.4 : 1.1,
                ),
              ),
              child: Text(
                '﴿${_toArabicNumber(verseNumber)}﴾',
                style: _quranTextStyle(
                  size: (quranFontSize - 7).clamp(12, 22).toDouble(),
                  color: separatorColor,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
        const TextSpan(text: ' '),
      ],
    );
  }

  Widget _buildBottomToolbar({
    Key? key,
    required bool isFavorite,
    required QuranAudioState audioState,
  }) {
    final isCurrentSurahAudio =
        audioState.hasAudio && audioState.surahNumber == _activeSurahNumber;

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Mini audio bar ──────────────────────────────────────────────
        if (audioState.hasAudio) _buildAudioBar(audioState),
        if (_isPageMode) _buildPageNavigator(),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolbarItem(
                icon: Icons.text_fields,
                label: 'الخط',
                onTap: _showFontSizeSheet,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _buildToolbarItem(
                icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                label: 'حفظ',
                isActive: isFavorite,
                onTap: _toggleFavorite,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _buildToolbarItem(
                icon: Icons.menu_book,
                label: 'تفسير',
                onTap: _openTafsir,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _buildToolbarItem(
                icon: Icons.headphones_outlined,
                label: 'استماع',
                isActive: isCurrentSurahAudio,
                onTap: _handleListenTap,
                onLongPress: _openAudioSheet,
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _buildToolbarItem(
                icon: Icons.ios_share,
                label: 'نشر',
                onTap: _shareSelectedVerse,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlsCollapsedHint({Key? key}) {
    return Align(
      key: key,
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () =>
              ref.read(quranReaderControlsVisibleProvider.notifier).save(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'إظهار الأدوات',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioBar(QuranAudioState audioState) {
    final duration = audioState.duration;
    final hasDuration = duration != null && duration.inMilliseconds > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _audioControlButton(
                icon: audioState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: audioState.isPlaying ? 'مؤقت' : 'تشغيل',
                isLoading: audioState.isLoading,
                onTap: () async {
                  if (audioState.isLoading) return;
                  final notifier = ref.read(quranAudioProvider.notifier);
                  if (audioState.isPlaying) {
                    await notifier.pause();
                  } else {
                    await notifier.resume();
                  }
                },
              ),
              const SizedBox(width: 8),
              _audioControlButton(
                icon: Icons.stop_rounded,
                label: 'إيقاف',
                onTap: () => ref.read(quranAudioProvider.notifier).stop(),
              ),
              const SizedBox(width: 8),
              _audioControlButton(
                icon: Icons.tune_rounded,
                label: 'اختيار',
                onTap: _openAudioSheet,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioState.reciter?.name ?? '',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (audioState.moshaf != null)
                      Text(
                        audioState.moshaf!.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (hasDuration) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: audioState.progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatAudioDuration(audioState.position),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  _formatAudioDuration(duration),
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _audioControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 54,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      )
                    : Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavigator() {
    final prevPage = _currentPage > 1 ? _currentPage - 1 : null;
    final nextPage = _currentPage < QuranService.totalPagesCount
        ? _currentPage + 1
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPageNavButton(
              label: 'السابق',
              pageTitle: prevPage == null
                  ? ''
                  : QuranService.getPageTitle(prevPage),
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: prevPage == null ? null : () => _goToPage(prevPage),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPageNavButton(
              label: 'التالي',
              pageTitle: nextPage == null
                  ? ''
                  : QuranService.getPageTitle(nextPage),
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: nextPage == null ? null : () => _goToPage(nextPage),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _openPageJumpDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'صفحة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNavButton({
    required String label,
    required String pageTitle,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (pageTitle.isNotEmpty)
                  Text(
                    pageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : Colors.white,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToPage(int page) async {
    final target = QuranService.clampPage(page);
    QuranService.preloadPage(target);
    if (target > 1) {
      QuranService.preloadPage(target - 1);
    }
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

  Future<void> _syncReadingProgress(int page, {bool showMessage = true}) async {
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

  Future<void> _openJuzPicker() async {
    if (!_isPageMode) return;

    final selectedJuz = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'الانتقال إلى جزء',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 30,
                  itemBuilder: (_, index) {
                    final juz = index + 1;
                    final firstPage = QuranService.getFirstPageForJuz(juz);
                    return ListTile(
                      onTap: () => Navigator.of(ctx).pop(juz),
                      title: Text(
                        'الجزء ${_toArabicNumber(juz)}',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'يبدأ من صفحة ${_toArabicNumber(firstPage)}',
                        style: GoogleFonts.tajawal(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (selectedJuz == null) return;
    if (!mounted) return;
    final page = QuranService.getFirstPageForJuz(selectedJuz);
    await _goToPage(page);
  }

  Future<void> _openPageJumpDialog() async {
    final page = await showDialog<int>(
      context: context,
      builder: (ctx) => _PageJumpDialog(initialPage: _currentPage),
    );

    if (!mounted) return;
    if (page == null) return;
    if (page < 1 || page > QuranService.totalPagesCount) {
      _showAudioSnack('رقم الصفحة غير صحيح');
      return;
    }
    await _goToPage(page);
  }

  Future<void> _showFontSizeSheet() async {
    final current = ref.read(quranFontSizeProvider);
    double temp = current;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجم خط السورة',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: temp,
                    min: 18,
                    max: 40,
                    divisions: 22,
                    activeColor: AppColors.primary,
                    label: temp.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => temp = value);
                    },
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'الحجم: ${temp.toStringAsFixed(0)}',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(quranFontSizeProvider.notifier)
                            .save(temp);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                      ),
                      child: Text(
                        'حفظ',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite() async {
    await ref.read(favoriteSurahsProvider.notifier).toggle(widget.surahNumber);
    if (!mounted) {
      return;
    }
    final isFavorite = ref
        .read(favoriteSurahsProvider)
        .contains(widget.surahNumber);
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

      // Persist defaults if user did not select one yet.
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
      final normalizedName = _normalizeArabic(reciter.name);
      if (!normalizedName.contains('نورين')) continue;
      if (reciter.moshafForSurah(_activeSurahNumber) != null) {
        return reciter;
      }
    }
    return null;
  }

  Reciter? _firstAvailableReciter(List<Reciter> reciters) {
    for (final reciter in reciters) {
      if (reciter.moshafForSurah(_activeSurahNumber) != null) {
        return reciter;
      }
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
      builder: (ctx) => _AudioSheet(surahNumber: targetSurah),
    );
  }

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
    final surahName = QuranService.getSurahNameArabicNormalized(
      widget.surahNumber,
    );
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$verse\n\n$surahName - آية ${_toArabicNumber(_selectedVerse)}\nمن تطبيق المسلم',
      ),
    );
  }

  String _toArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String numStr = number.toString();
    for (int i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }

  String _formatAudioDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _normalizeArabic(String input) {
    return input
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  List<InlineSpan> _buildPageTextSpans({
    required List<AyahModel> pageAyahs,
    required double quranFontSize,
    required Color textColor,
  }) {
    if (pageAyahs.isEmpty) {
      return const <InlineSpan>[TextSpan(text: '')];
    }

    final spans = <InlineSpan>[];
    int? lastSurahNumber;

    for (final ayah in pageAyahs) {
      final currentSurah = ayah.surahNumber ?? 0;
      if (lastSurahNumber != null &&
          currentSurah != 0 &&
          currentSurah != lastSurahNumber) {
        spans.add(
          TextSpan(
            text: '  ۞  ',
            style: _quranTextStyle(
              size: quranFontSize - 1,
              color: _mushafGold,
              height: 2.0,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: ayah.text.trim(),
          style: _quranTextStyle(
            size: quranFontSize + 1,
            color: textColor,
            height: 2.0,
          ),
        ),
      );

      if (_isAyahSajdah(ayah)) {
        spans.add(
          TextSpan(
            text: ' ۩',
            style: _quranTextStyle(
              size: quranFontSize - 1,
              color: _mushafGold,
              height: 2.0,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: ' ﴿${_toArabicNumber(ayah.ayahNumber)}﴾ ',
          style: _quranTextStyle(
            size: (quranFontSize - 5).clamp(12, 22).toDouble(),
            color: _mushafGold,
            height: 2.0,
          ),
        ),
      );
      lastSurahNumber = currentSurah;
    }
    return spans;
  }

  bool _isAyahSajdah(AyahModel ayah) {
    if (ayah.sajdaBool == true) {
      return true;
    }
    final dynamic sajda = ayah.sajda;
    if (sajda == null || sajda == false) {
      return false;
    }
    if (sajda is Map) {
      return sajda['recommended'] == true || sajda['obligatory'] == true;
    }
    if (sajda is bool) {
      return sajda;
    }
    return true;
  }
}

// ── Audio reciter selection sheet ────────────────────────────────────────────
class _PageJumpDialog extends StatefulWidget {
  const _PageJumpDialog({required this.initialPage});

  final int initialPage;

  @override
  State<_PageJumpDialog> createState() => _PageJumpDialogState();
}

class _PageJumpDialogState extends State<_PageJumpDialog> {
  late String _input;

  @override
  void initState() {
    super.initState();
    _input = widget.initialPage.toString();
  }

  void _submit() {
    Navigator.of(context).pop(int.tryParse(_input.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'الانتقال إلى صفحة',
          style: GoogleFonts.tajawal(color: Colors.white),
        ),
        content: TextFormField(
          key: const ValueKey('page-jump-input'),
          initialValue: _input,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: (value) => _input = value,
          onFieldSubmitted: (_) => _submit(),
          style: GoogleFonts.tajawal(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'من 1 إلى 604',
            hintStyle: GoogleFonts.tajawal(color: AppColors.textSecondaryDark),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2D5E57)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: _submit,
            child: Text(
              'انتقال',
              style: GoogleFonts.tajawal(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  const _AudioSheet({required this.surahNumber});

  @override
  ConsumerState<_AudioSheet> createState() => _AudioSheetState();
}

class _AudioSheetState extends ConsumerState<_AudioSheet> {
  String _query = '';
  int _searchFieldVersion = 0;

  @override
  Widget build(BuildContext context) {
    final recitersAsync = ref.watch(recitersProvider);
    final audioPlaybackUi = ref.watch(
      quranAudioProvider.select(
        (state) => (
          isPlaying: state.isPlaying,
          isLoading: state.isLoading,
          surahNumber: state.surahNumber,
          reciterId: state.reciter?.id,
          moshafId: state.moshaf?.id,
        ),
      ),
    );
    final defaultReciterId = ref.watch(defaultReciterIdProvider);
    final favoriteReciterIds = ref.watch(favoriteReciterIdsProvider);
    final preferredMoshafMap = ref.watch(preferredReciterMoshafProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.45,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'القراءة الصوتية',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  QuranService.getSurahNameArabicNormalized(widget.surahNumber),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر القارئ والرواية مرة واحدة، ثم التشغيل يصبح مباشرًا',
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2D5E57), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextFormField(
              key: ValueKey(_searchFieldVersion),
              initialValue: _query,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 14),
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن القارئ أو الرواية',
                hintStyle: GoogleFonts.tajawal(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondaryDark,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: AppColors.textSecondaryDark,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _query = '';
                            _searchFieldVersion++;
                          });
                        },
                      ),
                filled: true,
                fillColor: const Color(0xFF0F2824),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D5E57)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: recitersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: AppColors.textSecondaryDark,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تعذّر تحميل القراء\nيرجى التحقق من الاتصال بالإنترنت',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (reciters) {
                final available = reciters
                    .where(
                      (r) => r.moshafsForSurah(widget.surahNumber).isNotEmpty,
                    )
                    .toList();
                final filtered = _filterReciters(available, _query);

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد نتائج مطابقة',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  );
                }

                final sorted = _sortReciters(
                  reciters: filtered,
                  defaultReciterId: defaultReciterId,
                  favoriteReciterIds: favoriteReciterIds.toSet(),
                );

                return ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => _ReciterTile(
                    reciter: sorted[i],
                    surahNumber: widget.surahNumber,
                    isDefault: sorted[i].id == defaultReciterId,
                    isFavorite: favoriteReciterIds.contains(sorted[i].id),
                    audioIsPlaying: audioPlaybackUi.isPlaying,
                    audioIsLoading: audioPlaybackUi.isLoading,
                    currentAudioSurah: audioPlaybackUi.surahNumber,
                    currentAudioReciterId: audioPlaybackUi.reciterId,
                    currentAudioMoshafId: audioPlaybackUi.moshafId,
                    preferredMoshafId: preferredMoshafMap[sorted[i].id],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Reciter> _filterReciters(List<Reciter> reciters, String query) {
    if (query.isEmpty) return reciters;
    final normalized = _normalizeArabic(query);
    return reciters.where((reciter) {
      if (_normalizeArabic(reciter.name).contains(normalized)) return true;
      return reciter.moshaf.any(
        (m) => _normalizeArabic(m.name).contains(normalized),
      );
    }).toList();
  }

  List<Reciter> _sortReciters({
    required List<Reciter> reciters,
    required int? defaultReciterId,
    required Set<int> favoriteReciterIds,
  }) {
    final defaultItems = reciters
        .where((reciter) => reciter.id == defaultReciterId)
        .toList();
    final favoriteItems = reciters
        .where(
          (reciter) =>
              reciter.id != defaultReciterId &&
              favoriteReciterIds.contains(reciter.id),
        )
        .toList();
    final regularItems = reciters
        .where(
          (reciter) =>
              reciter.id != defaultReciterId &&
              !favoriteReciterIds.contains(reciter.id),
        )
        .toList();

    return [...defaultItems, ...favoriteItems, ...regularItems];
  }

  String _normalizeArabic(String input) {
    return input
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }
}

// ── Single reciter tile ───────────────────────────────────────────────────────
class _ReciterTile extends ConsumerStatefulWidget {
  final Reciter reciter;
  final int surahNumber;
  final bool isDefault;
  final bool isFavorite;
  final bool audioIsPlaying;
  final bool audioIsLoading;
  final int? currentAudioSurah;
  final int? currentAudioReciterId;
  final int? currentAudioMoshafId;
  final int? preferredMoshafId;

  const _ReciterTile({
    required this.reciter,
    required this.surahNumber,
    required this.isDefault,
    required this.isFavorite,
    required this.audioIsPlaying,
    required this.audioIsLoading,
    required this.currentAudioSurah,
    required this.currentAudioReciterId,
    required this.currentAudioMoshafId,
    required this.preferredMoshafId,
  });

  @override
  ConsumerState<_ReciterTile> createState() => _ReciterTileState();
}

class _ReciterTileState extends ConsumerState<_ReciterTile> {
  late Moshaf _selectedMoshaf;

  @override
  void initState() {
    super.initState();
    _selectedMoshaf = _resolveSelectedMoshaf();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(moshafDownloadProvider.notifier)
          .checkDownloaded(_selectedMoshaf);
    });
  }

  @override
  void didUpdateWidget(covariant _ReciterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preferredMoshafId == widget.preferredMoshafId) return;

    final next = _resolveSelectedMoshaf();
    if (next.id == _selectedMoshaf.id) return;

    _selectedMoshaf = next;
    ref.read(moshafDownloadProvider.notifier).checkDownloaded(_selectedMoshaf);
  }

  Moshaf _resolveSelectedMoshaf() {
    return widget.reciter.preferredMoshafForSurah(
          widget.surahNumber,
          preferredMoshafId: widget.preferredMoshafId,
        ) ??
        widget.reciter.moshafForSurah(widget.surahNumber)!;
  }

  @override
  Widget build(BuildContext context) {
    final moshafsForSurah = widget.reciter.moshafsForSurah(widget.surahNumber);
    final dlState =
        ref.watch(moshafDownloadProvider)[_selectedMoshaf.id] ??
        const MoshafDownloadState();
    final isSelected =
        widget.currentAudioReciterId == widget.reciter.id &&
        widget.currentAudioSurah == widget.surahNumber &&
        widget.currentAudioMoshafId == _selectedMoshaf.id;
    final isPlaying = widget.audioIsPlaying && isSelected;
    final isLoading = widget.audioIsLoading && isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : const Color(0xFF0D2622),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : const Color(0xFF2D5E57),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: dlState.isDownloading
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            onTap: () async {
              final notifier = ref.read(quranAudioProvider.notifier);
              if (isSelected) {
                await notifier.togglePlayPause();
              } else {
                await notifier.play(
                  widget.reciter,
                  _selectedMoshaf,
                  widget.surahNumber,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.isDefault) ...[
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.primary,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (widget.isFavorite) ...[
                              const Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                widget.reciter.name,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (dlState.isFullyDownloaded) ...[
                              const Icon(
                                Icons.offline_bolt_rounded,
                                color: AppColors.primary,
                                size: 11,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Expanded(
                              child: Text(
                                _selectedMoshaf.name,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (moshafsForSurah.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Material(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _openRiwayaPicker(
                                    context,
                                    availableMoshafs: moshafsForSurah,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.menu_book_rounded,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'تغيير الرواية بسهولة',
                                            style: GoogleFonts.tajawal(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildDownloadButton(context, _selectedMoshaf, dlState),
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: widget.isFavorite
                        ? 'إزالة من المفضلة'
                        : 'إضافة إلى المفضلة',
                    icon: Icon(
                      widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.isFavorite
                          ? Colors.redAccent
                          : AppColors.textSecondaryDark,
                      size: 20,
                    ),
                    onPressed: () async {
                      final adding = !widget.isFavorite;
                      await ref
                          .read(favoriteReciterIdsProvider.notifier)
                          .toggle(widget.reciter.id);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            adding
                                ? 'تمت إضافة ${widget.reciter.name} إلى المفضلة'
                                : 'تمت إزالة ${widget.reciter.name} من المفضلة',
                            style: GoogleFonts.tajawal(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    tooltip: widget.isDefault
                        ? 'إلغاء القارئ الافتراضي'
                        : 'تعيين كقارئ افتراضي',
                    icon: Icon(
                      widget.isDefault
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: widget.isDefault
                          ? AppColors.primary
                          : AppColors.textSecondaryDark,
                      size: 20,
                    ),
                    onPressed: () async {
                      if (widget.isDefault) {
                        await ref
                            .read(defaultReciterIdProvider.notifier)
                            .clear();
                        await ref
                            .read(defaultReciterNameProvider.notifier)
                            .clear();
                      } else {
                        await ref
                            .read(defaultReciterIdProvider.notifier)
                            .save(widget.reciter.id);
                        await ref
                            .read(defaultReciterNameProvider.notifier)
                            .save(widget.reciter.name);
                        await ref
                            .read(preferredReciterMoshafProvider.notifier)
                            .saveSelection(
                              widget.reciter.id,
                              _selectedMoshaf.id,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تعيين ${widget.reciter.name} كقارئ افتراضي',
                              style: GoogleFonts.tajawal(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (dlState.isDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: dlState.progress > 0 ? dlState.progress : null,
                    backgroundColor: const Color(0xFF0D2622),
                    color: AppColors.primary,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dlState.status.isNotEmpty
                        ? dlState.status
                        : 'جاري التحميل… ${(dlState.progress * 100).toInt()}%'
                              ' (${dlState.downloadedCount}/${dlState.totalCount})',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openRiwayaPicker(
    BuildContext context, {
    required List<Moshaf> availableMoshafs,
  }) async {
    final selected = await showModalBottomSheet<Moshaf>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.62,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'اختيار الرواية',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'اضغط على الرواية المطلوبة',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: availableMoshafs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final moshaf = availableMoshafs[index];
                        final isSelected = moshaf.id == _selectedMoshaf.id;
                        return Material(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : const Color(0xFF0F2D28),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(ctx).pop(moshaf),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 58),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            moshaf.name,
                                            style: GoogleFonts.tajawal(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            isSelected
                                                ? 'محددة الآن'
                                                : 'اضغط للاختيار',
                                            style: GoogleFonts.tajawal(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondaryDark,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondaryDark,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (selected == null || selected.id == _selectedMoshaf.id) return;

    setState(() {
      _selectedMoshaf = selected;
    });

    await ref
        .read(preferredReciterMoshafProvider.notifier)
        .saveSelection(widget.reciter.id, selected.id);
    await ref.read(moshafDownloadProvider.notifier).checkDownloaded(selected);

    if (!mounted) return;

    final currentState = ref.read(quranAudioProvider);
    if (currentState.reciter?.id == widget.reciter.id &&
        currentState.surahNumber == widget.surahNumber) {
      await ref
          .read(quranAudioProvider.notifier)
          .play(widget.reciter, selected, widget.surahNumber);
    }
  }

  Widget _buildDownloadButton(
    BuildContext context,
    Moshaf moshaf,
    MoshafDownloadState dlState,
  ) {
    if (dlState.isDownloading) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: dlState.progress > 0 ? dlState.progress : null,
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (dlState.isFullyDownloaded) {
      return IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        tooltip: 'حذف النسخة المحلية',
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: Text(
                'حذف التحميل',
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
              content: Text(
                'سيتم حذف القرآن المحمّل لهذه النسخة.',
                style: GoogleFonts.tajawal(color: AppColors.textSecondaryDark),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'حذف',
                    style: GoogleFonts.tajawal(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true && mounted) {
            await ref.read(moshafDownloadProvider.notifier).delete(moshaf);
          }
        },
      );
    }

    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.download_outlined,
        color: AppColors.textSecondaryDark,
        size: 20,
      ),
      tooltip: 'تحميل للاستماع بدون إنترنت',
      onPressed: () {
        ref.read(moshafDownloadProvider.notifier).startDownload(moshaf);
      },
    );
  }
}
