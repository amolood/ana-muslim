# 🔊 إعداد خيار اختيار صوت الأذان

## ✅ ما تم إنجازه

### 1. إضافة Enum وProvider
- ✅ تم إضافة `AdhanSoundOption` enum في `preferences_provider.dart`
- ✅ تم إضافة `adhanSoundOptionProvider` للحفظ/القراءة
- ✅ 5 خيارات متاحة:
  - أذان مكة (`adhan_makkah`)
  - أذان مكة الفجر (`adhan_makkah_fajr`)
  - أذان المدينة (`adhan_madina`)
  - أذان المدينة الفجر (`adhan_madina_fajr`)
  - أذان كلاسيكي (`azan`)

### 2. تحديث NotificationsService
- ✅ إضافة `setAdhanSound(String androidResourceName)`
- ✅ تحديث `_ensureStandardAdhanChannel()` لاستخدام `_currentAdhanSoundName`
- ✅ تحديث `_ensureBypassDndAdhanChannelIfAllowed()` لاستخدام `_currentAdhanSoundName`
- ✅ تحديث `_scheduleSingle()` لاستخدام `_currentAdhanSoundName`

### 3. نسخ ملفات الصوت
- ✅ تم نسخ 4 ملفات MP3 إلى `android/app/src/main/res/raw/`
- ✅ الملفات موجودة في: `assets/sounds/azan/`

---

## 🔧 الخطوات المتبقية (يدوية)

### الخطوة 1: إضافة UI في Settings

في `lib/features/settings/presentation/screens/notification_settings_screen.dart`، أضف:

```dart
// في build method بعد إعدادات الإشعارات الموجودة

_buildDivider(context),

// خيار اختيار صوت الأذان
_buildSettingsItem(
  context,
  icon: Icons.music_note,
  title: 'صوت الأذان',
  subtitle: ref.watch(adhanSoundOptionProvider).label,
  onTap: () => _showAdhanSoundPicker(context, ref),
),
```

### الخطوة 2: إضافة Dialog للاختيار

أضف هذه الدالة في نفس الملف:

```dart
Future<void> _showAdhanSoundPicker(BuildContext context, WidgetRef ref) async {
  final currentOption = ref.read(adhanSoundOptionProvider);

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'اختر صوت الأذان',
        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AdhanSoundOption.values.map((option) {
          return RadioListTile<AdhanSoundOption>(
            title: Text(
              option.label,
              style: GoogleFonts.tajawal(),
              textDirection: TextDirection.rtl,
            ),
            value: option,
            groupValue: currentOption,
            onChanged: (value) async {
              if (value != null) {
                // حفظ الخيار الجديد
                await ref.read(adhanSoundOptionProvider.notifier).save(value);

                // تحديث الصوت في NotificationsService
                NotificationsService.setAdhanSound(value.androidResourceName);

                // إعادة جدولة الإشعارات
                await _reschedulePrayerNotifications(ref, context: context);

                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('إلغاء', style: GoogleFonts.tajawal()),
        ),
      ],
    ),
  );
}
```

### الخطوة 3: تهيئة الصوت عند بدء التطبيق

في `lib/main.dart`، في `main()` function بعد تهيئة SharedPreferences:

```dart
// تهيئة صوت الأذان من الإعدادات المحفوظة
final container = ProviderContainer(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ],
);
final adhanSound = container.read(adhanSoundOptionProvider);
NotificationsService.setAdhanSound(adhanSound.androidResourceName);
container.dispose();
```

---

## 🎵 الأصوات المتوفرة

| الخيار | الملف | الحجم |
|--------|------|-------|
| أذان مكة | `adhan_makkah.mp3` | 199 KB |
| أذان مكة (الفجر) | `adhan_makkah_fajr.mp3` | 420 KB |
| أذان المدينة | `adhan_madina.mp3` | 371 KB |
| أذان المدينة (الفجر) | `adhan_madina_fajr.mp3` | 546 KB |
| أذان كلاسيكي | `azan.mp3` | 3.9 MB |

---

## 🧪 اختبار الميزة

1. افتح الإعدادات → تنبيهات الصلاة
2. اضغط على "صوت الأذان"
3. اختر صوت مختلف
4. سيتم إعادة جدولة الإشعارات تلقائياً
5. جرّب الإشعار للتأكد من الصوت الجديد

---

## 📝 ملاحظات مهمة

### لـ Android:
- الأصوات يجب أن تكون في `android/app/src/main/res/raw/`
- الاسم بدون امتداد (مثل `adhan_makkah` وليس `adhan_makkah.mp3`)
- إعادة بناء التطبيق إذا أضفت ملفات جديدة

### لـ iOS:
- الأصوات يجب أن تكون في المشروع
- الاسم مع امتداد (مثل `adhan_makkah.mp3`)

---

## 🐛 حل المشاكل

### الصوت لا يعمل:
1. تأكد من نسخ الملفات إلى `res/raw`
2. تأكد من اسم الملف صحيح (بدون مسافات/أحرف خاصة)
3. أعد بناء التطبيق (`flutter clean && flutter build apk`)
4. تحقق من أذونات الإشعارات

### الصوت القديم لا زال يعمل:
1. احذف notifications channel القديم من إعدادات Android
2. أعد تثبيت التطبيق
3. تأكد من استدعاء `setAdhanSound()` قبل الجدولة

---

## ✅ التحقق النهائي

```dart
// للتحقق من الصوت المختار حالياً:
final currentSound = ref.watch(adhanSoundOptionProvider);
print('Current adhan: ${currentSound.label}');
print('File: ${currentSound.androidResourceName}');
```

---

تم إنشاء هذا الملف بواسطة Claude Code
