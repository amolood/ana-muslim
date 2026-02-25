# دليل الإصلاحات السريعة

## ✅ ما تم إنجازه

### 1. حذف كارد آخر قراءة من شاشة القرآن ✓
**الملف:** `lib/features/quran/presentation/screens/quran_index_screen.dart`

**التغيير:**
```dart
// تم حذف:
// _buildLastReadBanner(ref),
```

### 2. إضافة زر عودة في شاشة العلامات ✓
**الملف:** `lib/features/quran/presentation/widgets/bookmarks_view.dart`

**التغيير:**
```dart
return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text('العلامات المرجعية'),
  ),
  // ...
)
```

---

## 🔧 الإصلاحات المتبقية

### 3. إصلاح ورد اليوم - تشغيل الآية فقط
**المشكلة:** زر التشغيل يفتح الشاشة فقط دون تشغيل الصوت

**الملف:** `lib/features/home/presentation/screens/home_screen.dart`

**الموقع:** السطر ~1235

**الحل المقترح:**
```dart
// استبدال:
InkWell(
  onTap: () {
    QuranService.preloadSurah(wird.surah);
    context.push('/quran/reader/${wird.surah}?ayah=${wird.ayah}');
  },
  // ...
)

// بـ:
InkWell(
  onTap: () async {
    // تشغيل الآية مباشرة
    final audioController = ref.read(surahAudioControllerProvider);

    // إيقاف التشغيل الحالي إن وجد
    if (audioController.isPlaying) {
      await audioController.stop();
    }

    // تشغيل الآية المحددة
    await audioController.playAyahRange(
      surahNumber: wird.surah,
      startAyah: wird.ayah,
      endAyah: wird.ayah, // نفس الآية
    );

    // فتح الشاشة
    if (context.mounted) {
      QuranService.preloadSurah(wird.surah);
      context.push('/quran/reader/${wird.surah}?ayah=${wird.ayah}');
    }
  },
  // ...
)
```

**ملاحظة:** تأكد من إضافة import:
```dart
import '../../quran/presentation/providers/audio_providers.dart';
```

---

### 4. تحسين شاشة مواقيت الصلاة (Light/Dark Mode)
**الملف:** `lib/features/prayer_times/presentation/screens/prayer_times_screen.dart`

**المشكلة:** جميع الألوان ثابتة (Dark Mode فقط)

**الحل:** إضافة `isDark` check لكل لون

**مثال:**
```dart
// قبل:
color: Colors.white

// بعد:
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? Colors.white : Colors.black

// قبل:
color: AppColors.surfaceDark

// بعد:
color: isDark ? AppColors.surfaceDark : Colors.white

// قبل:
color: AppColors.textSecondaryDark

// بعد:
color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight
```

**الأماكن التي تحتاج تعديل:**
1. `_buildHeader()` - السطر 176
2. `_buildLocationAndDate()` - السطر 225
3. `_buildTimerCard()` - السطر 296
4. `_buildPrayerList()` - السطر 359

**عدد التغييرات:** حوالي 30-40 موقع

---

### 5. إضافة اختيار صوت الأذان من الملفات

**الخطوة 1: إضافة file_picker في pubspec.yaml**
```yaml
dependencies:
  file_picker: ^8.1.4
```

**الخطوة 2: تحديث AdhanSoundOption**
```dart
// في lib/core/providers/preferences_provider.dart

enum AdhanSoundOption {
  makkah,
  makkahFajr,
  madina,
  madinaFajr,
  classic,
  custom, // <- جديد
}

extension AdhanSoundOptionX on AdhanSoundOption {
  String get label => switch (this) {
    AdhanSoundOption.custom => 'صوت مخصص',
    // ... باقي الخيارات
  };

  String get androidResourceName => switch (this) {
    AdhanSoundOption.custom => 'custom_adhan',
    // ... باقي الخيارات
  };
}
```

**الخطوة 3: إضافة زر "اختيار من الملفات"**
```dart
// في notification_settings_screen.dart

// إضافة في dialog الاختيار:
TextButton.icon(
  icon: Icon(Icons.folder_open),
  label: Text('اختيار من الملفات'),
  onPressed: () async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;

      // حفظ المسار
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('custom_adhan_path', filePath);

      // تحديد الخيار
      await ref.read(adhanSoundOptionProvider.notifier).save(
        AdhanSoundOption.custom,
      );

      // نسخ الملف إلى res/raw
      await _copyFileToAndroidRes(filePath);
    }
  },
)
```

---

### 6. تحسين الإحصائيات المتقدمة

**الملف:** `lib/features/home/presentation/screens/worship_stats_screen.dart`

**التحسينات المقترحة:**
1. إضافة رسوم بيانية (Charts)
2. عرض إحصائيات أسبوعية
3. عرض أكثر السور قراءة
4. عرض معدل القراءة اليومي

**مكتبة مقترحة:**
```yaml
dependencies:
  fl_chart: ^0.69.2
```

---

### 7. إصلاح مشكلة القبلة

**المشاكل المحتملة:**
1. عدم منح أذونات الموقع
2. عدم منح أذونات الحساس
3. خطأ في الحسابات
4. مشكلة في flutter_qiblah package

**الحلول المقترحة:**

**أ) التحقق من الأذونات:**
```dart
// في QiblaScreen initState
@override
void initState() {
  super.initState();
  _checkPermissions();
}

Future<void> _checkPermissions() async {
  // Location permission
  final locationStatus = await Permission.location.request();
  if (!locationStatus.isGranted) {
    // Show error
  }

  // Sensor permission (Android)
  // Usually auto-granted but good to check
}
```

**ب) تحديث flutter_qiblah:**
```yaml
dependencies:
  flutter_qiblah: ^2.3.5 # آخر إصدار
```

**ج) استخدام حساب مختلف:**
إذا استمرت المشكلة، يمكن استخدام حساب يدوي:
```dart
import 'dart:math' as math;

double calculateQiblaDirection(double lat, double lon) {
  // Kaaba coordinates
  const kaabaLat = 21.4225;
  const kaabaLon = 39.8262;

  final dLon = (kaabaLon - lon) * math.pi / 180;
  final lat1 = lat * math.pi / 180;
  final lat2 = kaabaLat * math.pi / 180;

  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

  var bearing = math.atan2(y, x) * 180 / math.pi;
  bearing = (bearing + 360) % 360;

  return bearing;
}
```

**د) التحقق من دقة البوصلة:**
```dart
// إضافة معايرة البوصلة
void _showCalibrationDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('معايرة البوصلة'),
      content: Text('حرك الهاتف في شكل رقم 8 لمعايرة البوصلة'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('حسناً'),
        ),
      ],
    ),
  );
}
```

---

## 📊 ملخص الحالة

| المهمة | الحالة | الأولوية |
|--------|--------|----------|
| حذف كارد آخر قراءة | ✅ مكتمل | ✓ |
| زر عودة العلامات | ✅ مكتمل | ✓ |
| إصلاح ورد اليوم | 🔄 جاهز للتطبيق | 🔴 عاجل |
| تحسين المواقيت | 🔄 جاهز للتطبيق | 🔴 عاجل |
| اختيار الأذان من ملف | 📝 مخطط | 🟡 مهم |
| تحسين الإحصائيات | 📝 مخطط | 🟢 اختياري |
| إصلاح القبلة | 📝 يحتاج تشخيص | 🔴 عاجل |

---

## 🚀 الأولوية الموصى بها

1. **إصلاح القبلة** - أهم مشكلة
2. **إصلاح ورد اليوم** - سهل وسريع
3. **تحسين المواقيت** - يحسن UX بشكل كبير
4. **اختيار الأذان من ملف** - ميزة إضافية مفيدة
5. **تحسين الإحصائيات** - آخر أولوية

---

**تاريخ التحديث:** 2026-02-24
**الإصدار:** 1.0
