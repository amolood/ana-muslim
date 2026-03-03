/// Common Arabic UI strings used across the app.
///
/// Centralising these makes future localization straightforward — each field
/// here corresponds to one entry in an ARB file. Prefer importing this class
/// and referencing `UiStrings.retry` rather than inlining string literals.
abstract final class UiStrings {
  // ── Generic actions ────────────────────────────────────────────────────────
  static const retry = 'إعادة المحاولة';
  static const save = 'حفظ';
  static const cancel = 'إلغاء';
  static const copy = 'نسخ';
  static const close = 'إغلاق';

  // ── Loading / error states ─────────────────────────────────────────────────
  static const loading = 'جاري التحميل…';
  static const errorGeneric = 'حدث خطأ';
  static const noResults = 'لا توجد نتائج';

  // ── Hadith ─────────────────────────────────────────────────────────────────
  static const hadithCopied = 'تم نسخ الحديث';
  static const hadithLoading = 'جاري تحميل الأحاديث…';
  static const hadithError = 'حدث خطأ في تحميل الأحاديث';
  static const hadithSearchHint = 'ابحث بالنص أو رقم الحديث...';
  static const hadithSearchEmpty = 'ابحث في مكتبة الحديث';
  static const hadithFontSizeTitle = 'حجم خط الحديث';

  // ── Quran ──────────────────────────────────────────────────────────────────
  static const quranSearchHint = 'ابحث في آيات القرآن...';
  static const quranSearchEmpty = 'ابحث في آيات القرآن الكريم';
}
