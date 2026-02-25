# ملخص التحسينات المطلوبة

## 📋 قائمة المهام

### ✅ تم الإنجاز سابقاً
1. نظام الأذونات الاحترافي
2. محرك الاقتراحات الذكية
3. اختيار صوت الأذان من الخيارات المحددة
4. تغيير ألوان قائمة السور للأبيض

### 🔄 المهام الحالية

#### 1. تحسين شاشة مواقيت الصلاة ✨
**المطلوب:**
- دعم كامل للوضع النهاري (Light Mode)
- دعم كامل للوضع الليلي (Dark Mode)
- تصميم احترافي وجذاب

**التغييرات:**
```dart
// استبدال:
color: Colors.white
// بـ:
color: isDark ? Colors.white : Colors.black

// استبدال:
color: AppColors.surfaceDark
// بـ:
color: isDark ? AppColors.surfaceDark : Colors.white

// وهكذا لجميع الألوان
```

#### 2. إضافة اختيار صوت الأذان من الملفات 🎵
**المطلوب:**
- إضافة خيار "اختيار من الملفات" في إعدادات الأذان
- استخدام file_picker package
- حفظ مسار الملف المختار
- استخدامه في الإشعارات

**الخطوات:**
1. إضافة `file_picker` في pubspec.yaml
2. تحديث `AdhanSoundOption` لإضافة `custom`
3. إضافة واجهة اختيار الملف
4. حفظ المسار في SharedPreferences
5. نسخ الملف لـ Android res/raw

#### 3. إضافة زر عودة في شاشة العلامات ⬅️
**المطلوب:**
- إضافة زر رجوع في AppBar

**الحل:**
```dart
appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  // ...
)
```

#### 4. حذف كارد آخر قراءة من شاشة القرآن ❌
**المطلوب:**
- إزالة "Last Read Banner" من quran_index_screen.dart

**الموقع:**
```dart
// في quran_index_screen.dart
// حذف:
_buildLastReadBanner(ref),
```

#### 5. إصلاح ورد اليوم - تشغيل الآية المحددة فقط 📖
**المشكلة:**
عند الضغط على زر التشغيل في "ورد اليوم"، يتم تشغيل السورة كاملة بدلاً من الآية المحددة فقط.

**الحل:**
استخدام `playAyahRange` بدلاً من `playSurah`:
```dart
// بدلاً من:
audioController.playSurah(surahNumber)

// استخدم:
audioController.playAyahRange(
  surahNumber: surahNumber,
  startAyah: ayahNumber,
  endAyah: ayahNumber, // نفس الآية
)
```

#### 6. تحسين الإحصائيات المتقدمة 📊
**المطلوب:**
- تحسين واجهة عرض الإحصائيات
- إضافة رسوم بيانية أو مخططات
- عرض معلومات أكثر تفصيلاً

#### 7. إصلاح مشكلة القبلة 🧭
**المشكلة:**
القبلة لا تعمل بشكل صحيح.

**الحلول المحتملة:**
1. التحقق من أذونات الموقع
2. التحقق من أذونات الحساس (Sensors)
3. تحديث flutter_qiblah package
4. استخدام طريقة حساب مختلفة

## 📝 ملاحظات تقنية

### الألوان الديناميكية
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Text colors
textColor: isDark ? Colors.white : Colors.black
secondaryTextColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight

// Background colors
backgroundColor: isDark ? AppColors.surfaceDark : Colors.white
cardColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight

// Border colors
borderColor: isDark
  ? Colors.white.withValues(alpha: 0.1)
  : Colors.black.withValues(alpha: 0.1)
```

### أولويات التنفيذ
1. 🔴 عاجل: شاشة المواقيت، القبلة، ورد اليوم
2. 🟡 مهم: حذف كارد آخر قراءة، زر العودة
3. 🟢 جيد للإضافة: اختيار الأذان من الملفات، الإحصائيات

## 🚀 البدء

### 1. شاشة المواقيت
ملف: `lib/features/prayer_times/presentation/screens/prayer_times_screen.dart`

التغييرات الرئيسية:
- إضافة `final isDark = Theme.of(context).brightness == Brightness.dark;` في كل widget
- تحديث جميع الألوان الثابتة لتكون ديناميكية
- تحسين التباين والوضوح

### 2. اختيار الأذان من الملفات
ملفات:
- `lib/core/providers/preferences_provider.dart`
- `lib/features/settings/presentation/screens/notification_settings_screen.dart`
- `lib/core/notifications/notifications_service.dart`

### 3. باقي التحسينات
حسب الأولوية المذكورة أعلاه

---

**تاريخ الإنشاء:** 2026-02-24
**الحالة:** قيد التنفيذ ⚙️
