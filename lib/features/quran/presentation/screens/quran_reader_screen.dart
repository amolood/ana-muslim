import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/quran_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/tafsir_bottom_sheet.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialVerse,
  });

  final int surahNumber;
  final int? initialVerse;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late int _selectedVerse;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    final verseCount = QuranService.getVerseCount(widget.surahNumber);
    final initialVerse = (widget.initialVerse ?? 1).clamp(1, verseCount);
    _selectedVerse = initialVerse;
    _currentPage = QuranService.getPageNumber(widget.surahNumber, initialVerse);

    Future.microtask(() async {
      await ref.read(lastReadSurahProvider.notifier).save(widget.surahNumber);
      await ref.read(lastReadPageProvider.notifier).save(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quranFontSize = ref.watch(quranFontSizeProvider);
    final favorites = ref.watch(favoriteSurahsProvider);
    final isFavorite = favorites.contains(widget.surahNumber);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: const Opacity(
              opacity: 0.03,
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
                    child: Column(
                      children: [
                        if (widget.surahNumber != 1 && widget.surahNumber != 9) _buildBasmalah(quranFontSize),
                        const SizedBox(height: 16),
                        RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            children: [
                              for (int i = 1; i <= QuranService.getVerseCount(widget.surahNumber); i++)
                                _buildVerseSpan(i, quranFontSize),
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
            child: _buildBottomToolbar(isFavorite: isFavorite),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'سورة ${QuranService.getSurahNameArabic(widget.surahNumber)}',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      QuranService.getPlaceOfRevelation(widget.surahNumber) == 'Makkah' ? 'مكية' : 'مدنية',
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'الجزء ${QuranService.getJuzNumber(widget.surahNumber, _selectedVerse)}',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'ص $_currentPage',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasmalah(double fontSize) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Text(
        QuranService.basmala,
        style: GoogleFonts.notoNaskhArabic(
          fontSize: fontSize + 4,
          color: Colors.white,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  InlineSpan _buildVerseSpan(int verseNumber, double quranFontSize) {
    final isSelected = _selectedVerse == verseNumber;

    return TextSpan(
      children: [
        TextSpan(
          text: '${QuranService.getVerse(widget.surahNumber, verseNumber, verseEndSymbol: false)} ',
          style: GoogleFonts.notoNaskhArabic(
            fontSize: quranFontSize,
            height: 2.1,
            color: Colors.white,
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _selectVerse(verseNumber),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _toArabicNumber(verseNumber),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const TextSpan(text: ' '),
      ],
    );
  }

  Widget _buildBottomToolbar({required bool isFavorite}) {
    return Container(
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
          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
          _buildToolbarItem(
            icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
            label: 'حفظ',
            isActive: isFavorite,
            onTap: _toggleFavorite,
          ),
          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
          _buildToolbarItem(
            icon: Icons.menu_book,
            label: 'تفسير',
            onTap: _openTafsir,
          ),
          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
          _buildToolbarItem(
            icon: Icons.ios_share,
            label: 'نشر',
            onTap: _shareSelectedVerse,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                  color: isActive ? AppColors.primary : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectVerse(int verseNumber) {
    setState(() {
      _selectedVerse = verseNumber;
      _currentPage = QuranService.getPageNumber(widget.surahNumber, verseNumber);
    });
    ref.read(lastReadSurahProvider.notifier).save(widget.surahNumber);
    ref.read(lastReadPageProvider.notifier).save(_currentPage);
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
                        await ref.read(quranFontSizeProvider.notifier).save(temp);
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
    final isFavorite = ref.read(favoriteSurahsProvider).contains(widget.surahNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'تمت إضافة السورة إلى المفضلة' : 'تمت إزالة السورة من المفضلة',
          style: GoogleFonts.tajawal(),
        ),
      ),
    );
  }

  Future<void> _openTafsir() async {
    if (!mounted) return;
    final ayahUq =
        QuranService.getAyahUniqueNumber(widget.surahNumber, _selectedVerse);
    await showTafsirSheet(
      context,
      surahNumber: widget.surahNumber,
      ayahNumber: _selectedVerse,
      ayahUQNumber: ayahUq,
    );
  }

  Future<void> _shareSelectedVerse() async {
    final verse = QuranService.getVerse(widget.surahNumber, _selectedVerse, verseEndSymbol: false);
    final surahName = QuranService.getSurahNameArabic(widget.surahNumber);
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$verse\n\nسورة $surahName - آية ${_toArabicNumber(_selectedVerse)}\nمن تطبيق المسلم',
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
}
