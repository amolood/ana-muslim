import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';

import '../../../../core/providers/quran_audio_preferences_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../quran/data/models/quran_api_font.dart';
import '../../../quran/data/models/reciter.dart';
import '../../../quran/data/repositories/audio_download_service.dart';
import '../../../quran/data/services/quran_font_service.dart';
import '../../../quran/presentation/providers/audio_providers.dart';
import '../../../quran/presentation/providers/quran_api_font_providers.dart';

// ─── Static item descriptors ──────────────────────────────────────────────

class _LibraryItem {
  final String fileName;
  final String displayName;
  final String bookName;
  final bool isBundled;
  final String sizeHint;

  const _LibraryItem({
    required this.fileName,
    required this.displayName,
    this.bookName = '',
    this.isBundled = false,
    this.sizeHint = '',
  });
}

const _featuredTafsirs = [
  _LibraryItem(
    fileName: 'saadi',
    displayName: 'تفسير السعدي',
    bookName: 'تيسير الكريم الرحمن',
    isBundled: true,
  ),
  _LibraryItem(
    fileName: 'ibnkatheer',
    displayName: 'تفسير ابن كثير',
    bookName: 'تفسير القرآن العظيم',
    sizeHint: '~4 MB',
  ),
  _LibraryItem(
    fileName: 'tabari',
    displayName: 'تفسير الطبري',
    bookName: 'جامع البيان عن تأويل آي القرآن',
    sizeHint: '~12 MB',
  ),
  _LibraryItem(
    fileName: 'qurtubi',
    displayName: 'تفسير القرطبي',
    bookName: 'الجامع لأحكام القرآن',
    sizeHint: '~8 MB',
  ),
  _LibraryItem(
    fileName: 'tafsir-jalalayn',
    displayName: 'تفسير الجلالين',
    bookName: 'تفسير الجلالين',
    sizeHint: '~2 MB',
  ),
  _LibraryItem(
    fileName: 'baghawy',
    displayName: 'تفسير البغوي',
    bookName: 'معالم التنزيل',
    sizeHint: '~5 MB',
  ),
];

const _featuredTranslations = [
  _LibraryItem(
    fileName: 'en',
    displayName: 'English',
    bookName: 'English Translation',
    isBundled: true,
  ),
  _LibraryItem(
    fileName: 'fr',
    displayName: 'Français',
    bookName: 'Traduction française',
    sizeHint: '~1 MB',
  ),
  _LibraryItem(
    fileName: 'es',
    displayName: 'Español',
    bookName: 'Traducción al español',
    sizeHint: '~1 MB',
  ),
];

// ─── Curated Quran fonts ───────────────────────────────────────────────────
// Keys match the fawazahmed0 quran-api fonts.json so files stored by
// QuranFontService are compatible with the font picker screen.

const List<QuranApiFont> _curatedFonts = [
  QuranApiFont(
    key: 'quran_madina',
    name: 'مصحف المدينة',
    displayName: 'QURAN MADINA. Normal',
    designer: '',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/maddina.ttf',
  ),
  QuranApiFont(
    key: 'kfgqpc_hafs',
    name: 'مجمع الملك فهد - حفص',
    displayName: 'KFGQPC HAFS Uthmanic Script Regular',
    designer: 'King Fahd Glorious Quran Printing Complex',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/hafs-uthmanic-v14-full.ttf',
  ),
  QuranApiFont(
    key: 'kfgqpc_warsh',
    name: 'مجمع الملك فهد - ورش',
    displayName: 'KFGQPC WARSH Uthmanic Script Regular',
    designer: 'King Fahd Glorious Quran Printing Complex',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/warsh-v8-full.ttf',
  ),
  QuranApiFont(
    key: 'kfgqpc_qaloon',
    name: 'مجمع الملك فهد - قالون',
    displayName: 'KFGQPC QALOON Uthmanic Script Regular',
    designer: 'King Fahd Glorious Quran Printing Complex',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qaloon-v8-full.ttf',
  ),
  QuranApiFont(
    key: 'kfgqpc_doori',
    name: 'مجمع الملك فهد - الدوري',
    displayName: 'KFGQPC DOORI Uthmanic Script Regular',
    designer: 'King Fahd Glorious Quran Printing Complex',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/doori-v8-full.ttf',
  ),
  QuranApiFont(
    key: 'amiri_quran',
    name: 'الخط الأميري القرآني',
    displayName: 'Amiri Quran Regular',
    designer: 'Khaled Hosny',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/amiri-quran-full.ttf',
  ),
  QuranApiFont(
    key: 'al_qalam_majeed',
    name: 'خط القلم - قرآن مجيد',
    displayName: 'Al Qalam Quran Majeed Regular',
    designer: 'Abdul Majeed Khan',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/al-qalam-quran-majeed.ttf',
  ),
  QuranApiFont(
    key: 'al_mushaf',
    name: 'خط المصحف',
    displayName: 'Al_Mushaf Regular',
    designer: 'Alvi Technologies',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/almushaf.ttf',
  ),
  QuranApiFont(
    key: 'quran_standard',
    name: 'خط القرآن المعياري',
    displayName: 'Quran Standard Normal',
    designer: '',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qur-std.ttf',
  ),
  QuranApiFont(
    key: 'noorehuda_naskh',
    name: 'خط نور الهدى - نسخ',
    displayName: 'noorehuda Regular',
    designer: 'abu saad',
    ttfUrl:
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/noorehuda-regular.ttf',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  // ── Tafsir state ─────────────────────────────────────────────────────────
  bool _ctrlReady = false;
  int? _downloadingIndex;
  Timer? _refreshTimer;

  // ── Audio download state ──────────────────────────────────────────────────
  bool _isDownloadingAudio = false;
  double _audioDownloadProgress = 0.0;
  String _audioStatusText = '';
  int _audioRefreshKey = 0; // increment to force FutureBuilder re-evaluation

  @override
  void initState() {
    super.initState();
    _initCtrl();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initCtrl() async {
    await TafsirCtrl.instance.initTafsir();
    if (mounted) setState(() => _ctrlReady = true);
  }

  // ── Tafsir helpers ────────────────────────────────────────────────────────

  int? _findIndex(String fileName) {
    final items = TafsirCtrl.instance.tafsirAndTranslationsItems;
    final idx = items.indexWhere((e) => e.fileName == fileName);
    return idx == -1 ? null : idx;
  }

  bool _isDownloaded(int index) {
    return TafsirCtrl.instance.tafsirDownloadStatus.value[index] ?? false;
  }

  double _progressValue() => TafsirCtrl.instance.progress.value;

  // ── Tafsir actions ────────────────────────────────────────────────────────

  Future<void> _download(int index) async {
    setState(() => _downloadingIndex = index);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) {
        if (mounted) setState(() {});
      },
    );
    await TafsirCtrl.instance.tafsirAndTranslationDownload(index);
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (mounted) setState(() => _downloadingIndex = null);
  }

  Future<void> _delete(int index, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف', style: GoogleFonts.tajawal()),
        content: Text(
          'هل تريد حذف "$displayName" من الجهاز؟',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal()),
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
    if (confirm != true) return;
    await TafsirCtrl.instance.deleteTafsirOrTranslation(itemIndex: index);
    if (mounted) setState(() {});
  }

  // ── Font actions ──────────────────────────────────────────────────────────

  Future<void> _downloadFont(QuranApiFont font) async {
    ref.read(quranFontDownloadProgressProvider.notifier).set(font.key, 0.01);
    try {
      await QuranFontService.downloadFont(
        font.key,
        font.ttfUrl,
        onProgress: (p) {
          if (!mounted) return;
          ref
              .read(quranFontDownloadProgressProvider.notifier)
              .set(font.key, p);
        },
      );
      await ref
          .read(downloadedQuranFontsProvider.notifier)
          .markDownloaded(font.key);
      if (!mounted) return;
      // Auto-select after download
      await ref.read(selectedQuranFontKeyProvider.notifier).select(font.key);
      ref.read(quranFontDownloadProgressProvider.notifier).remove(font.key);
    } catch (e) {
      if (!mounted) return;
      ref.read(quranFontDownloadProgressProvider.notifier).remove(font.key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل تحميل الخط: ${font.name}',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteFont(QuranApiFont font) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الخط', style: GoogleFonts.tajawal()),
        content: Text(
          'هل تريد حذف "${font.name}" من الجهاز؟',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal()),
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
    if (confirm != true) return;
    await QuranFontService.deleteFont(font.key);
    await ref.read(downloadedQuranFontsProvider.notifier).markDeleted(font.key);
    if (ref.read(selectedQuranFontKeyProvider) == font.key) {
      await ref.read(selectedQuranFontKeyProvider.notifier).select(null);
    }
  }

  // ── Audio actions ─────────────────────────────────────────────────────────

  Moshaf? _resolvePreferredMoshaf(Reciter reciter, Map<int, int> moshafMap) {
    if (reciter.moshaf.isEmpty) return null;
    final preferredId = moshafMap[reciter.id];
    if (preferredId != null) {
      final m = reciter.moshaf.firstWhere(
        (m) => m.id == preferredId,
        orElse: () => reciter.moshaf.first,
      );
      return m;
    }
    return reciter.moshaf.first;
  }

  Future<void> _downloadAudio(Moshaf moshaf) async {
    setState(() {
      _isDownloadingAudio = true;
      _audioDownloadProgress = 0.0;
      _audioStatusText = 'جارٍ التحميل...';
    });

    try {
      await AudioDownloadService.downloadMoshaf(
        moshaf,
        onProgress: (p) {
          if (mounted) setState(() => _audioDownloadProgress = p);
        },
        onStatus: (s) {
          if (mounted) setState(() => _audioStatusText = s);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء التحميل',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingAudio = false;
          _audioRefreshKey++;
        });
      }
    }
  }

  Future<void> _deleteAudio(Moshaf moshaf, String reciterName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف التلاوة', style: GoogleFonts.tajawal()),
        content: Text(
          'هل تريد حذف تلاوة "$reciterName" من الجهاز؟',
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal()),
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
    if (confirm != true) return;
    await AudioDownloadService.deleteMoshaf(moshaf);
    if (mounted) setState(() => _audioRefreshKey++);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'المكتبة',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: !_ctrlReady
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ).copyWith(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(colors),
                  const SizedBox(height: 24),
                  _buildSectionTitle('التلاوة الصوتية', colors),
                  const SizedBox(height: 8),
                  _buildAudioSection(colors, isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle('التفسير العربي', colors),
                  const SizedBox(height: 8),
                  _buildItemList(_featuredTafsirs, colors, isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle('الترجمات', colors),
                  const SizedBox(height: 8),
                  _buildItemList(_featuredTranslations, colors, isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle('خطوط القرآن', colors),
                  const SizedBox(height: 8),
                  _buildFontsSection(colors, isDark),
                ],
              ),
            ),
    );
  }

  // ── Section widgets ───────────────────────────────────────────────────────

  Widget _buildInfoBanner(AppSemanticColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.download_for_offline_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المحتوى غير المتصل',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'حمّل التفاسير والترجمات والتلاوات للاستخدام بدون إنترنت',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppSemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  // ── Audio section ─────────────────────────────────────────────────────────

  Widget _buildAudioSection(AppSemanticColors colors, bool isDark) {
    final reciterId = ref.watch(defaultReciterIdProvider);
    final reciterName = ref.watch(defaultReciterNameProvider);
    final recitersAsync = ref.watch(recitersProvider);
    final moshafMap = ref.watch(preferredReciterMoshafProvider);

    // Resolve reciter object
    Reciter? reciter;
    if (reciterId != null) {
      final list = recitersAsync.asData?.value;
      if (list != null) {
        reciter = list.firstWhereOrNull((r) => r.id == reciterId);
      }
    }

    final moshaf =
        reciter != null ? _resolvePreferredMoshaf(reciter, moshafMap) : null;
    final displayName = reciterName ?? reciter?.name ?? '';

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentQuran.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.headphones_rounded,
                    color: AppColors.accentQuran,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'تلاوة القرآن الكريم',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (reciterId == null)
            _buildAudioNoReciter(colors)
          else if (recitersAsync.isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (moshaf == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                'لا تتوفر قراءات لهذا القارئ',
                style: GoogleFonts.tajawal(color: colors.textSecondary),
              ),
            )
          else
            _buildAudioTile(displayName, moshaf, colors),
        ],
      ),
    );
  }

  Widget _buildAudioNoReciter(AppSemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 20,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'لم تختر قارئاً مفضلاً — اذهب إلى الإعدادات لاختيار قارئ',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTile(
    String reciterName,
    Moshaf moshaf,
    AppSemanticColors colors,
  ) {
    final totalSurahs = moshaf.surahList.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Leading icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentQuran.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentQuran.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 20,
                  color: AppColors.accentQuran,
                ),
              ),
              const SizedBox(width: 12),

              // Name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciterName,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (moshaf.name.isNotEmpty)
                      Text(
                        moshaf.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    if (_isDownloadingAudio)
                      Text(
                        _audioStatusText,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: context.colors.textSecondary,
                        ),
                      )
                    else
                      FutureBuilder<int>(
                        key: ValueKey('audio_count_$_audioRefreshKey'),
                        future:
                            AudioDownloadService.downloadedCount(moshaf),
                        builder: (ctx, snap) {
                          final count = snap.data ?? 0;
                          final isDone = count >= totalSurahs && count > 0;
                          return Text(
                            isDone
                                ? 'محمّلة بالكامل ($totalSurahs سورة)'
                                : count > 0
                                    ? '$count / $totalSurahs سورة محمّلة'
                                    : 'غير محمّلة — $totalSurahs سورة',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: isDone
                                  ? AppColors.primary
                                  : context.colors.textSecondary,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing action
              if (_isDownloadingAudio)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _audioDownloadProgress > 0
                        ? _audioDownloadProgress
                        : null,
                    strokeWidth: 2.5,
                    color: AppColors.accentQuran,
                  ),
                )
              else
                FutureBuilder<int>(
                  key: ValueKey('audio_action_$_audioRefreshKey'),
                  future: AudioDownloadService.downloadedCount(moshaf),
                  builder: (ctx, snap) {
                    final count = snap.data ?? 0;
                    final isFullyDownloaded =
                        count >= totalSurahs && count > 0;
                    return GestureDetector(
                      onTap: isFullyDownloaded
                          ? () => _deleteAudio(moshaf, reciterName)
                          : () => _downloadAudio(moshaf),
                      child: Icon(
                        isFullyDownloaded
                            ? Icons.delete_outline_rounded
                            : Icons.download_rounded,
                        size: 24,
                        color: isFullyDownloaded
                            ? context.colors.iconSecondary
                            : AppColors.accentQuran,
                      ),
                    );
                  },
                ),
            ],
          ),

          // Progress bar
          if (_isDownloadingAudio) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _audioDownloadProgress > 0
                    ? _audioDownloadProgress
                    : null,
                backgroundColor: context.colors.borderDefault,
                color: AppColors.accentQuran,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'جارٍ التحميل… ${(_audioDownloadProgress * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tafsir / Translation section ──────────────────────────────────────────

  Widget _buildItemList(
    List<_LibraryItem> items,
    AppSemanticColors colors,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.borderSubtle,
                indent: 72,
              ),
            _buildItemTile(items[i], colors),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTile(_LibraryItem item, AppSemanticColors colors) {
    final index = _findIndex(item.fileName);
    if (index == null) return const SizedBox.shrink();

    final isDownloaded = item.isBundled || _isDownloaded(index);
    final isDownloading = _downloadingIndex == index;
    final progress = isDownloading ? _progressValue() : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDownloaded
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDownloaded
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : colors.borderDefault,
              ),
            ),
            child: Icon(
              isDownloaded ? Icons.check_rounded : Icons.menu_book_rounded,
              size: 20,
              color: isDownloaded ? AppColors.primary : colors.iconSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (item.bookName.isNotEmpty && !isDownloading)
                  Text(
                    item.isBundled ? 'مثبت مسبقاً' : item.sizeHint,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: item.isBundled
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : colors.textSecondary,
                    ),
                  ),
                if (isDownloading) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : null,
                      backgroundColor: colors.borderDefault,
                      color: AppColors.primary,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'جارٍ التحميل… ${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.isBundled)
            Icon(
              Icons.lock_rounded,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.5),
            )
          else if (isDownloading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          else if (isDownloaded)
            GestureDetector(
              onTap: () => _delete(index, item.displayName),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: colors.iconSecondary,
              ),
            )
          else
            GestureDetector(
              onTap: () => _download(index),
              child: const Icon(
                Icons.download_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  // ── Fonts section ─────────────────────────────────────────────────────────

  Widget _buildFontsSection(AppSemanticColors colors, bool isDark) {
    final downloadedKeys = ref.watch(downloadedQuranFontsProvider);
    final selectedKey = ref.watch(selectedQuranFontKeyProvider);
    final progressMap = ref.watch(quranFontDownloadProgressProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.text_fields_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'خطوط القرآن الكريم',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Font tiles
          for (int i = 0; i < _curatedFonts.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.borderSubtle,
                indent: 72,
              ),
            _buildCuratedFontTile(
              _curatedFonts[i],
              isDownloaded: downloadedKeys.contains(_curatedFonts[i].key),
              isSelected: selectedKey == _curatedFonts[i].key,
              downloadProgress: progressMap[_curatedFonts[i].key],
              colors: colors,
            ),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildCuratedFontTile(
    QuranApiFont font, {
    required bool isDownloaded,
    required bool isSelected,
    required double? downloadProgress,
    required AppSemanticColors colors,
  }) {
    final isDownloading = downloadProgress != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : isDownloaded
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : colors.borderDefault,
              ),
            ),
            child: Icon(
              isDownloaded
                  ? Icons.font_download_rounded
                  : Icons.font_download_off_outlined,
              size: 20,
              color: isSelected || isDownloaded
                  ? AppColors.primary
                  : colors.iconSecondary,
            ),
          ),
          const SizedBox(width: 12),

          // Name + subtitle + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  font.name,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (font.designer.isNotEmpty && !isDownloading)
                  Text(
                    font.designer,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                if (isDownloading) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: downloadProgress > 0.01 ? downloadProgress : null,
                      backgroundColor: colors.borderDefault,
                      color: AppColors.primary,
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Trailing actions
          if (isDownloading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: downloadProgress > 0.01 ? downloadProgress : null,
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          else if (isDownloaded) ...[
            // Select toggle
            GestureDetector(
              onTap: () async {
                if (isSelected) {
                  await ref
                      .read(selectedQuranFontKeyProvider.notifier)
                      .select(null);
                } else {
                  await ref
                      .read(selectedQuranFontKeyProvider.notifier)
                      .select(font.key);
                }
              },
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primary : colors.iconSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            // Delete
            GestureDetector(
              onTap: () => _deleteFont(font),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colors.iconSecondary,
              ),
            ),
          ] else
            GestureDetector(
              onTap: () => _downloadFont(font),
              child: const Icon(
                Icons.download_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Extension helper ──────────────────────────────────────────────────────

extension _ListFirstOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
