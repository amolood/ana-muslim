# 📖 دليل تكامل مكتبة Quran Library - الاستخدام الكامل

## 🎯 الخطة الكاملة لاستخدام جميع مميزات المكتبة

### 1. **استخدام QuranLibraryScreen الكامل** ⭐

```dart
import 'package:quran_library/quran_library.dart';

class QuranLibraryFullScreen extends ConsumerWidget {
  const QuranLibraryFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;

    return QuranLibraryScreen(
      parentContext: context,

      // ═══ إعدادات أساسية ═══
      withPageView: true,
      useDefaultAppBar: false, // نستخدم AppBar مخصص
      isShowAudioSlider: true,
      showAyahBookmarkedIcon: true,
      isDark: isDark,
      appLanguageCode: 'ar',

      // ═══ الألوان ═══
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      textColor: colors.textPrimary,
      ayahSelectedBackgroundColor: AppColors.primary.withValues(alpha: 0.15),
      ayahIconColor: AppColors.primary,

      // ═══ معلومات السورة ═══
      surahInfoStyle: SurahInfoStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        ayahCount: 'آية',
        firstTabText: 'أسماء السور',
        secondTabText: 'عن السورة',
        bottomSheetWidth: 500,
        // تخصيص ألوان معلومات السورة
        backgroundColor: isDark ? AppColors.surfaceDark : colors.surfaceCard,
        textColor: colors.textPrimary,
      ),

      // ═══ البسملة ═══
      basmalaStyle: BasmalaStyle(
        verticalPadding: 8.0,
        basmalaColor: colors.textPrimary,
        basmalaFontSize: 28.0,
        basmalaWidth: 200.0,
        basmalaHeight: 40.0,
      ),

      // ═══ الصوتيات ═══
      ayahStyle: AyahAudioStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        dialogWidth: 400,
        readersTabText: 'القراء',
        // تخصيص قائمة القراء
        backgroundColor: isDark ? AppColors.surfaceDark : colors.surfaceCard,
      ),

      // ═══ شريط الأدوات العلوي ═══
      topBarStyle: QuranTopBarStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        showAudioButton: true,
        showFontsButton: true,
        tabIndexLabel: 'الفهرس',
        tabBookmarksLabel: 'المحفوظات',
        tabSearchLabel: 'بحث',
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // ═══ تبويب الفهرس ═══
      indexTabStyle: IndexTabStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        tabSurahsLabel: 'السور',
        tabJozzLabel: 'الأجزاء',
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // ═══ البحث ═══
      searchTabStyle: SearchTabStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        searchHintText: 'ابحث في القرآن الكريم...',
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // ═══ الإشارات المرجعية الملونة ═══
      bookmarksTabStyle: BookmarksTabStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        emptyStateText: 'لا توجد إشارات مرجعية بعد',
        greenGroupText: 'إشارات للحفظ 🟢',
        yellowGroupText: 'إشارات للمراجعة 🟡',
        redGroupText: 'إشارات للدراسة المتعمقة 🔴',
      ),

      // ═══ قائمة الآية ═══
      ayahMenuStyle: AyahMenuStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        copySuccessMessage: 'تم نسخ الآية بنجاح',
        showPlayAllButton: true,
        // إضافة أزرار مخصصة
      ),

      // ═══ التفسير ═══
      tafsirStyle: TafsirStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        widthOfBottomSheet: 500,
        heightOfBottomSheet: MediaQuery.sizeOf(context).height * 0.85,
        changeTafsirDialogHeight: MediaQuery.sizeOf(context).height * 0.85,
        changeTafsirDialogWidth: 400,
        tafsirName: 'التفسير',
        translateName: 'الترجمة',
        tafsirIsEmptyNote: 'لا يوجد تفسير متاح لهذه الآية',
        footnotesName: 'الهوامش',
      ),

      // ═══ معلومات أعلى وأسفل الصفحة ═══
      topBottomQuranStyle: TopBottomQuranStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        hizbName: 'الحزب',
        juzName: 'الجزء',
        sajdaName: 'سجدة',
      ),

      // ═══ معلومات الكلمات (Word Info) ═══
      wordInfoBottomSheetStyle: WordInfoBottomSheetStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        // تخصيص معلومات الكلمات
        backgroundColor: isDark ? AppColors.surfaceDark : colors.surfaceCard,
      ),

      // ═══ قائمة التجويد ═══
      tajweedMenuStyle: TajweedMenuStyle.defaults(
        isDark: isDark,
        context: context,
      ).copyWith(
        // تفعيل التجويد الملون
      ),
    );
  }
}
```

---

## 2. **تهيئة الإشارات المرجعية الملونة** 🔖

```dart
// في main.dart عند التهيئة
Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  // تهيئة المكتبة مع الإشارات الملونة
  await QuranLibrary.init(
    userBookmarks: [
      Bookmark(
        id: 0,
        colorCode: Colors.green.value,
        name: "للحفظ",
      ),
      Bookmark(
        id: 1,
        colorCode: Colors.yellow.shade700.value,
        name: "للمراجعة",
      ),
      Bookmark(
        id: 2,
        colorCode: Colors.red.value,
        name: "للدراسة",
      ),
    ],
  );

  runApp(const MyApp());
}
```

### استخدام الإشارات المرجعية:

```dart
// إضافة إشارة مرجعية خضراء
await QuranLibrary().setBookmark(
  surahName: 'البقرة',
  ayahNumber: 255, // آية الكرسي
  ayahId: QuranLibrary().getAyahUniqueNumber(2, 255),
  page: QuranLibrary().getPageNumber(2, 255),
  bookmarkId: 0, // الإشارة الخضراء
);

// إضافة إشارة صفراء
await QuranLibrary().setBookmark(
  surahName: 'الكهف',
  ayahNumber: 10,
  ayahId: QuranLibrary().getAyahUniqueNumber(18, 10),
  page: QuranLibrary().getPageNumber(18, 10),
  bookmarkId: 1, // الإشارة الصفراء
);

// الحصول على جميع الإشارات
final bookmarks = QuranLibrary().getUsedBookmarks();

// الانتقال إلى إشارة
await QuranLibrary().jumpToBookmark(bookmark);

// إزالة إشارة
await QuranLibrary().removeBookmark(bookmarkId: 0);
```

---

## 3. **تفعيل معلومات الكلمات (Word Info)** 💡

```dart
// عرض معلومات كلمة معينة
await QuranLibrary().showWordInfoByNumbers(
  context: context,
  surahNumber: 1,
  ayahNumber: 1,
  wordNumber: 1,
  initialKind: WordInfoKind.recitations, // القراءات
  isDark: isDark,
);

// تحميل أنواع معلومات الكلمات
if (!QuranLibrary().isWordInfoKindDownloaded(WordInfoKind.recitations)) {
  await QuranLibrary().downloadWordInfoKind(
    kind: WordInfoKind.recitations,
  );
}

if (!QuranLibrary().isWordInfoKindDownloaded(WordInfoKind.tasreef)) {
  await QuranLibrary().downloadWordInfoKind(
    kind: WordInfoKind.tasreef, // التصريف
  );
}

if (!QuranLibrary().isWordInfoKindDownloaded(WordInfoKind.eerab)) {
  await QuranLibrary().downloadWordInfoKind(
    kind: WordInfoKind.eerab, // الإعراب
  );
}
```

---

## 4. **إدارة التفاسير المتعددة** 📚

```dart
// الحصول على جميع التفاسير
final allTafsirs = TafsirController.instance.items;

// إضافة تفسير مخصص
final added = await TafsirController.instance.addCustomFromFile(
  sourceFile: pickedFile, // من file_picker
  displayName: 'تفسير مخصص',
  bookName: 'كتابي',
  type: TafsirFileType.json, // أو .sql
);

// عرض قائمة اختيار التفسير
QuranLibrary().changeTafsirPopupMenu(
  TafsirStyle.defaults(isDark: isDark, context: context),
  pageNumber: currentPage,
);

// الحصول على تفسير صفحة
final tafsir = await QuranLibrary().fetchTafsir(
  pageNumber: currentPage,
);

// التحقق من تحميل التفسير
final isDownloaded = QuranLibrary().getTafsirDownloaded(index);

// تحميل تفسير
await QuranLibrary().tafsirDownload(index);

// قائمة التفاسير والترجمات
final tafsirList = QuranLibrary().tafsirList;
final translationList = QuranLibrary().translationList;

// تغيير التفسير المحدد
await QuranLibrary().changeTafsirSwitch(
  index,
  pageNumber: currentPage,
);
```

---

## 5. **تحميل وإدارة الخطوط** 🖋️

```dart
// عرض dialog تحميل الخطوط
QuranLibrary().getFontsDownloadDialog(
  DownloadFontsDialogStyle.defaults(
    isDark: isDark,
    context: context,
  ),
  'ar', // language code
);

// أو استخدام widget مخصص
Widget fontsWidget = QuranLibrary().getFontsDownloadWidget(
  context,
  downloadFontsDialogStyle: DownloadFontsDialogStyle.defaults(
    isDark: isDark,
    context: context,
  ),
  languageCode: 'ar',
);

// تحميل الخطوط برمجياً
await QuranLibrary().fontsDownloadMethod();

// تجهيز الخطوط المحملة
await QuranLibrary().getFontsPrepareMethod(pageIndex);

// حذف الخطوط
await QuranLibrary().deleteFontsMethod();

// التحقق من التحميل
final isDownloaded = QuranLibrary().isFontsDownloaded;

// مراقبة التقدم
final progress = QuranLibrary().fontsDownloadProgress;

// استخدام الخطوط
TextStyle hafsStyle = QuranLibrary().hafsStyle;
TextStyle naskhStyle = QuranLibrary().naskhStyle;
```

---

## 6. **البحث المتقدم** 🔍

```dart
// بحث في القرآن
final results = QuranLibrary().search('الله');

// عرض النتائج
ListView.builder(
  itemCount: results.length,
  itemBuilder: (context, index) {
    final ayah = results[index];
    return ListTile(
      title: Text(ayah.text),
      subtitle: Text(
        'سورة ${ayah.surahName} - آية ${ayah.ayahNumber}',
      ),
      onTap: () {
        // الانتقال إلى الآية
        QuranLibrary().jumpToAyah(ayah);
      },
    );
  },
);
```

---

## 7. **التنقل بين الصفحات والأجزاء** 🔄

```dart
// الحصول على جميع الأجزاء
final jozzs = QuranLibrary.allJoz;

// الحصول على جميع الأحزاب
final hizbs = QuranLibrary.allHizb;

// الحصول على جميع السور
final surahs = QuranLibrary.getAllSurahs();

// معلومات سورة محددة
final surah = QuranLibrary().getSurahInfo(1);

// الآيات في صفحة
final ayahsOnPage = QuranLibrary().getAyahsByPage(page);

// القفز إلى آية
await QuranLibrary().jumpToAyah(ayahModel);

// القفز إلى صفحة
await QuranLibrary().jumpToPage(pageNumber);

// القفز إلى جزء
await QuranLibrary().jumpToJoz(jozNumber);

// القفز إلى حزب
await QuranLibrary().jumpToHizb(hizbNumber);

// القفز إلى سورة
await QuranLibrary().jumpToSurah(surahNumber);
```

---

## 8. **الصوتيات المتقدمة** 🎵

### تشغيل الآيات:
```dart
// تشغيل آية واحدة
await QuranLibrary().playAyah(
  context: context,
  currentAyahUniqueNumber: ayahUQNumber,
  playSingleAyah: true,
);

// تشغيل من آية إلى النهاية
await QuranLibrary().playAyah(
  context: context,
  currentAyahUniqueNumber: ayahUQNumber,
  playSingleAyah: false,
);

// الآية التالية
await QuranLibrary().seekNextAyah(
  context: context,
  currentAyahUniqueNumber: currentAyahUQ,
);

// الآية السابقة
await QuranLibrary().seekPreviousAyah(
  context: context,
  currentAyahUniqueNumber: currentAyahUQ,
);
```

### تشغيل السور:
```dart
// تشغيل سورة كاملة
await QuranLibrary().playSurah(surahNumber: 1);

// السورة التالية
await QuranLibrary().seekToNextSurah();

// السورة السابقة
await QuranLibrary().seekToPreviousSurah();

// التحميل للاستماع بدون إنترنت
await QuranLibrary().startDownloadSurah(surahNumber: 1);

// إلغاء التحميل
QuranLibrary().cancelDownloadSurah();
```

### استئناف التشغيل:
```dart
// الحصول على آخر موقع
int lastSurah = QuranLibrary().currentAndLastSurahNumber;
String lastTime = QuranLibrary().formatLastPositionToTime;
Duration lastDuration = QuranLibrary().formatLastPositionToDuration;

// استئناف من آخر موقع
await QuranLibrary().playLastPosition();
```

---

## 9. **عرض صفحات محددة مع Highlighting** ✨

```dart
// عرض صفحة واحدة
QuranPagesScreen(
  parentContext: context,
  page: 6,
)

// عرض نطاق من الصفحات
QuranPagesScreen(
  parentContext: context,
  startPage: 6,
  endPage: 11,
)

// تمييز آيات محددة بالسورة
QuranPagesScreen(
  parentContext: context,
  page: 6,
  highlightedAyahNumbersBySurah: {
    2: [255], // آية الكرسي
    18: [1, 10], // من سورة الكهف
  },
)

// تمييز آيات في نطاق صفحات
QuranPagesScreen(
  parentContext: context,
  startPage: 6,
  endPage: 11,
  highlightedAyahNumbersInPages: [
    (start: 6, end: 11, ayahs: [1, 3, 5]),
  ],
)

// تفعيل الاختيار المتعدد
QuranPagesScreen(
  parentContext: context,
  page: 6,
  enableMultiSelect: true,
)
```

---

## 10. **عرض آية واحدة في أي مكان** 📝

```dart
// آية الكرسي في بطاقة
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: GetSingleAyah(
      surahNumber: 2,
      ayahNumber: 255,
      fontSize: 22,
      textColor: colors.textPrimary,
      isDark: isDark,
      isBold: true,
    ),
  ),
)

// عرض سورة الفاتحة كاملة
Column(
  children: List.generate(7, (index) {
    return GetSingleAyah(
      surahNumber: 1,
      ayahNumber: index + 1,
      fontSize: 20,
      isDark: isDark,
    );
  }),
)
```

---

## 11. **عرض سورة كاملة** 📖

```dart
SurahDisplayScreen(
  surahNumber: 1, // الفاتحة
  onPageChanged: (pageIndex) {
    print('تغيرت صفحة السورة: $pageIndex');
  },
  isDark: isDark,

  // تخصيص البسملة
  basmalaStyle: BasmalaStyle.defaults(
    isDark: isDark,
    context: context,
  ).copyWith(
    basmalaColor: colors.textPrimary,
    basmalaWidth: 180.0,
    basmalaHeight: 35.0,
  ),

  // تخصيص البانر
  bannerStyle: BannerStyle.defaults(
    isDark: isDark,
    context: context,
  ).copyWith(
    isImage: false,
    bannerSvgHeight: 45.0,
    bannerSvgWidth: 160.0,
  ),
)
```

---

## 12. **تحميل التجويد (Tajweed)** 🎨

```dart
// تحميل بيانات التجويد للآيات
if (!QuranLibrary().isTajweedAyahDownloaded) {
  await QuranLibrary().downloadTajweedAyah();
}

// تخصيص قائمة التجويد
tajweedMenuStyle: TajweedMenuStyle.defaults(
  isDark: isDark,
  context: context,
).copyWith(
  // تفعيل ألوان التجويد
  enableTajweed: true,
),
```

---

## 13. **الاستخدام في الشاشة الرئيسية - ورد اليوم** 🌟

```dart
// في home_screen.dart
Widget _buildVerseOfTheDay() {
  // ورد اليوم من قائمة ثابتة
  final today = DateTime.now().day % 10;
  final verse = dailyVerses[today];

  return Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'آية اليوم',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          GetSingleAyah(
            surahNumber: verse.surah,
            ayahNumber: verse.ayah,
            fontSize: 22,
            textColor: colors.textPrimary,
            isDark: isDark,
          ),
          SizedBox(height: 8),
          Text(
            'سورة ${QuranService.getSurahNameArabic(verse.surah)} - آية ${verse.ayah}',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 🎯 خطة التنفيذ الموصى بها

### المرحلة 1: الأساسيات ✅
- [x] تهيئة المكتبة
- [ ] إضافة QuranLibraryScreen كخيار بديل
- [ ] ربط نظام الإشارات المرجعية

### المرحلة 2: المميزات المتقدمة 🚀
- [ ] تفعيل معلومات الكلمات
- [ ] إضافة التفاسير المتعددة
- [ ] تحميل الخطوط
- [ ] تفعيل التجويد الملون

### المرحلة 3: التحسينات 🌟
- [ ] استخدام GetSingleAyah في الشاشة الرئيسية
- [ ] إضافة QuranPagesScreen لعرض صفحات محددة
- [ ] تحسين البحث
- [ ] إضافة ميزة استئناف التشغيل من آخر موقع

### المرحلة 4: التكامل الكامل 🎨
- [ ] مزامنة الإشارات المرجعية مع السحابة
- [ ] إضافة إحصائيات القراءة
- [ ] تخصيص كامل للثيمات
- [ ] دعم اللغات المتعددة

---

## 📌 ملاحظات مهمة

1. **useMaterial3**: يجب تعيينها إلى `false` في MaterialApp
2. **الخطوط**: تحتاج تحميل منفصل لعرض القرآن بشكل صحيح
3. **الأذونات**: تحقق من أذونات الصوت في الخلفية لـ Android/iOS
4. **الذاكرة**: استخدم التحميل الكسول للصفحات
5. **الأداء**: قم بعمل preload للصفحات المجاورة

---

## 🔗 روابط مفيدة

- [التوثيق الكامل](https://alheekmahlib.github.io/quran_library_web/#/ar)
- [GitHub](https://github.com/alheekmahlib/quran_library)
- [pub.dev](https://pub.dev/packages/quran_library)
- [أمثلة](https://github.com/alheekmahlib/quran_library/tree/main/example)

---

تم التوثيق بواسطة Claude Code 🤖
