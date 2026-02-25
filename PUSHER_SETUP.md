# 📡 إعداد Pusher - الإشعارات المخصصة من الإدارة

## ⚠️ ملاحظة هامة

**Pusher يستخدم فقط للإشعارات المخصصة من الإدارة**

- ✅ إشعارات الصلوات → تتم محلياً في التطبيق (لا تستخدم Pusher)
- ✅ إشعارات رمضان → تتم محلياً في التطبيق (لا تستخدم Pusher)
- ✅ إشعارات الإدارة المخصصة → تستخدم Pusher فقط

## ✅ ما تم إنجازه

تم إعداد Pusher بالكامل للتطبيق والباك إند لإرسال إشعارات مخصصة فورية من الإدارة (Real-time).

---

## 📱 1. التطبيق (Flutter)

### الملفات المضافة/المعدلة:

#### ✅ `.env`
```env
# Pusher Configuration
PUSHER_APP_ID=2119620
PUSHER_KEY=d1504f807ef87ee64e4c
PUSHER_SECRET=59b4f779702b7b0944d1
PUSHER_CLUSTER=ap2

# API Configuration
API_BASE_URL=https://your-api-url.com
```

⚠️ **هام**: هذا الملف تم إضافته إلى `.gitignore` لحماية المفاتيح السرية.

#### ✅ `.gitignore`
تم إضافة:
```
# Environment variables
.env
.env.local
.env.*.local
```

#### ✅ `pubspec.yaml`
تم إضافة الحزم:
```yaml
dependencies:
  pusher_channels_flutter: ^2.2.1  # للاتصال بـ Pusher
  flutter_dotenv: ^5.2.1            # لقراءة ملف .env

flutter:
  assets:
    - .env  # إضافة ملف .env للـ assets
```

#### ✅ `lib/core/services/pusher_service.dart`
خدمة كاملة للتعامل مع Pusher:
- تهيئة الاتصال
- الاشتراك في القنوات
- معالجة الأحداث
- إلغاء الاشتراك
- فصل الاتصال

**الميزات**:
- معالجة حدث واحد فقط:
  - `admin-notification`: إشعار مخصص من الإدارة
- إدارة حالة الاتصال
- معالجة الأخطاء
- Logging تفصيلي
- **ملاحظة**: جميع إشعارات الصلوات ورمضان تتم محلياً في التطبيق

#### ✅ `lib/main.dart`
تم التحديث:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/pusher_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة
  await dotenv.load(fileName: '.env');

  // ... باقي الكود
}

final appStartupProvider = FutureProvider<void>((ref) async {
  // ...
  await PusherService.init(); // تهيئة Pusher
  // ...
});
```

---

## 🔧 2. الباك إند (Laravel)

### الملفات المضافة/المعدلة:

#### ✅ `backend/.env`
تم إضافة:
```env
BROADCAST_CONNECTION=pusher

# Pusher Configuration
PUSHER_APP_ID=2119620
PUSHER_APP_KEY=d1504f807ef87ee64e4c
PUSHER_APP_SECRET=59b4f779702b7b0944d1
PUSHER_APP_CLUSTER=ap2
```

#### ✅ `backend/config/broadcasting.php`
ملف إعدادات Broadcasting الكامل:
- إعداد Pusher driver
- إعدادات الاتصال (cluster, host, port, scheme)
- دعم TLS/SSL

#### ✅ `backend/app/Events/AdminNotification.php`
Event للإشعارات المخصصة من الإدارة:
```php
event(new AdminNotification(
    'عنوان الإشعار',
    'محتوى الإشعار',
    'general', // النوع: general, announcement, alert, reminder
    ['key' => 'value'] // بيانات إضافية (اختياري)
));
```
- يبث على قناة: `muslim-app`
- اسم الحدث: `admin-notification`
- **هذا النوع الوحيد من الأحداث عبر Pusher**

#### ✅ `backend/app/Http/Controllers/Api/PusherTestController.php`
Controller للاختبار مع 3 endpoints:
1. `GET /api/pusher/info` - معلومات الإعداد
2. `POST /api/pusher/test/notification` - اختبار إرسال إشعار تجريبي
3. `POST /api/pusher/send-notification` - إرسال إشعار حقيقي (يتطلب validation)

#### ✅ `backend/routes/api.php`
تم إضافة routes للإشعارات المخصصة:
```php
// Pusher - Admin Notifications
Route::prefix('pusher')->group(function () {
    Route::get('/info', [PusherTestController::class, 'info']);
    Route::post('/test/notification', [PusherTestController::class, 'testAdminNotification']);
    Route::post('/send-notification', [PusherTestController::class, 'sendGeneralNotification']);
});
```

---

## 🧪 3. كيفية الاختبار

### خطوة 1: تثبيت المتطلبات

#### التطبيق (Flutter):
```bash
cd /Users/molood/I\'mMuslim
flutter pub get
```

#### الباك إند (Laravel):
```bash
cd /Users/molood/I\'mMuslim/backend

# تثبيت Pusher PHP SDK
composer require pusher/pusher-php-server

# مسح الـ cache
php artisan config:clear
php artisan cache:clear
```

### خطوة 2: تشغيل الباك إند
```bash
cd /Users/molood/I\'mMuslim/backend
php artisan serve
```

### خطوة 3: اختبار الإعدادات
```bash
# التحقق من إعدادات Pusher
curl http://localhost:8000/api/pusher/info
```

**النتيجة المتوقعة**:
```json
{
  "pusher_configured": true,
  "app_key": "d1504f807ef87ee64e4c",
  "cluster": "ap2",
  "app_id": "2119620"
}
```

### خطوة 4: إرسال إشعار تجريبي

#### اختبار إرسال إشعار بسيط:
```bash
curl -X POST http://localhost:8000/api/pusher/test/notification
```

**النتيجة المتوقعة**:
```json
{
  "success": true,
  "message": "تم إرسال الإشعار المخصص عبر Pusher",
  "data": {
    "title": "إشعار تجريبي",
    "body": "هذا إشعار تجريبي من الإدارة",
    "type": "general",
    "metadata": null,
    "timestamp": "2026-02-24T19:30:00+00:00"
  }
}
```

#### اختبار إرسال إشعار مخصص:
```bash
curl -X POST http://localhost:8000/api/pusher/test/notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "تحديث مهم",
    "body": "تم إضافة محتوى جديد للتطبيق",
    "type": "announcement",
    "metadata": {"content_id": "123"}
  }'
```

#### إرسال إشعار حقيقي (مع validation):
```bash
curl -X POST http://localhost:8000/api/pusher/send-notification \
  -H "Content-Type: application/json" \
  -d '{
    "title": "إشعار عام",
    "body": "السلام عليكم ورحمة الله وبركاته",
    "type": "general"
  }'
```

### خطوة 5: اختبار التطبيق

1. شغّل التطبيق على الإيمليتور/الجهاز
2. افتح Logcat (Android) أو Console (iOS)
3. ابحث عن رسائل Pusher:
   - `✅ Pusher initialized successfully`
   - `✅ Subscribed to channel: muslim-app`
4. أرسل حدث من الباك إند (الخطوة 4)
5. يجب أن ترى في الـ logs:
   ```
   📨 Pusher Event:
     Channel: muslim-app
     Event: prayer-time-updated
     Data: {...}
   ```

---

## 📡 4. كيفية الاستخدام في الكود

### في التطبيق (Flutter):

#### الاشتراك في قناة:
```dart
await PusherService.subscribe('muslim-app');
```

#### إلغاء الاشتراك:
```dart
await PusherService.unsubscribe('muslim-app');
```

#### فصل الاتصال:
```dart
await PusherService.disconnect();
```

#### معالجة الإشعارات المخصصة:
عدّل `_handleAdminNotification` في `pusher_service.dart`:
```dart
static void _handleAdminNotification(String data) {
  try {
    final json = jsonDecode(data);
    final title = json['title'] ?? 'إشعار';
    final body = json['body'] ?? '';
    final type = json['type'] ?? 'general';

    // عرض إشعار محلي
    NotificationsService.showNotification(
      title: title,
      body: body,
      payload: type,
    );
  } catch (e) {
    print('❌ Error handling admin notification: $e');
  }
}
```

### في الباك إند (Laravel):

#### إرسال إشعار من أي مكان:
```php
use App\Events\AdminNotification;

// في Controller
event(new AdminNotification(
    'عنوان الإشعار',
    'محتوى الإشعار',
    'general' // النوع
));

// في Command
event(new AdminNotification(
    'تحديث جديد',
    'تم إضافة محتوى إسلامي جديد',
    'announcement',
    ['content_id' => 123] // بيانات إضافية
));

// في Service
event(new AdminNotification(
    'تنبيه',
    'يرجى تحديث التطبيق',
    'alert'
));
```

#### أنواع الإشعارات المدعومة:
- `general`: إشعار عام
- `announcement`: إعلان
- `alert`: تنبيه
- `reminder`: تذكير

---

## 🔒 5. الأمان

### ⚠️ تحذيرات هامة:

1. **لا تشارك المفاتيح علنياً**:
   - ملف `.env` محمي في `.gitignore`
   - لا تضع المفاتيح في الكود مباشرة

2. **أعد توليد المفاتيح**:
   - المفاتيح الحالية تم مشاركتها في المحادثة
   - يُنصح بإعادة توليد مفاتيح جديدة من:
   - https://dashboard.pusher.com

3. **استخدم Channels خاصة للبيانات الحساسة**:
   - القناة الحالية `muslim-app` عامة
   - للبيانات الشخصية، استخدم Private/Presence Channels

### إعادة توليد المفاتيح:

1. اذهب إلى https://dashboard.pusher.com
2. اختر تطبيقك
3. اذهب إلى "App Keys"
4. اضغط "Regenerate" لكل مفتاح
5. حدّث الملفات:
   - `/Users/molood/I'mMuslim/.env`
   - `/Users/molood/I'mMuslim/backend/.env`

---

## 📊 6. مراقبة الأحداث

### لوحة Pusher Dashboard:
1. اذهب إلى: https://dashboard.pusher.com
2. اختر تطبيقك (App ID: 2119620)
3. اذهب إلى "Debug Console"
4. أرسل حدث من الباك إند
5. ستشاهد الحدث مباشرة في Console

### في التطبيق:
شاهد logs في:
- Android: `adb logcat | grep Pusher`
- iOS: Xcode Console
- Flutter: Debug Console

---

## 🎯 7. حالات الاستخدام

### أمثلة عملية للإشعارات المخصصة من الإدارة:

#### 1. إشعار عند نشر محتوى إسلامي جديد
```php
// في Controller عند نشر مقال/فيديو
public function publish(Request $request, $id)
{
    $article = Article::findOrFail($id);
    $article->update(['status' => 'published']);

    // إشعار جميع المستخدمين
    event(new AdminNotification(
        'محتوى جديد',
        'تم نشر: ' . $article->title,
        'announcement',
        ['content_id' => $article->id, 'type' => 'article']
    ));

    return response()->json(['success' => true]);
}
```

#### 2. إشعار تنبيه مهم
```php
// في Admin Panel
public function sendUrgentAlert(Request $request)
{
    event(new AdminNotification(
        'تنبيه هام',
        $request->input('message'),
        'alert'
    ));

    return back()->with('success', 'تم إرسال التنبيه');
}
```

#### 3. تذكير المستخدمين بمناسبة إسلامية
```php
// في Scheduled Task
public function remindIslamicEvent()
{
    $event = IslamicEvent::today()->first();

    if ($event) {
        event(new AdminNotification(
            'مناسبة إسلامية',
            'اليوم: ' . $event->name,
            'reminder',
            ['event_id' => $event->id]
        ));
    }
}
```

#### 4. إشعار بتحديث التطبيق
```php
// عند نشر نسخة جديدة
public function notifyAppUpdate()
{
    event(new AdminNotification(
        'تحديث متاح',
        'نسخة جديدة من التطبيق متاحة الآن',
        'announcement',
        ['version' => '2.0.0', 'force_update' => false]
    ));
}
```

---

## 🐛 8. استكشاف الأخطاء

### المشكلة: التطبيق لا يتلقى الأحداث

**الحلول**:
1. تحقق من الـ logs:
   ```bash
   adb logcat | grep -i pusher
   ```
2. تحقق من الاتصال بالإنترنت
3. تحقق من إعدادات `.env`:
   ```bash
   flutter pub run flutter_dotenv:check
   ```

### المشكلة: البرودكاست لا يعمل في Laravel

**الحلول**:
1. تحقق من `config/broadcasting.php`:
   ```bash
   php artisan config:clear
   ```
2. تحقق من `.env`:
   ```bash
   php artisan config:cache
   ```
3. تحقق من تثبيت Pusher SDK:
   ```bash
   composer require pusher/pusher-php-server
   ```

### المشكلة: Connection Refused

**الحلول**:
1. تحقق من الـ cluster الصحيح (ap2)
2. تحقق من الاتصال بالإنترنت
3. تحقق من Firewall settings

---

## 📚 9. المراجع

- [Pusher Documentation](https://pusher.com/docs/)
- [Laravel Broadcasting](https://laravel.com/docs/broadcasting)
- [pusher_channels_flutter Package](https://pub.dev/packages/pusher_channels_flutter)
- [flutter_dotenv Package](https://pub.dev/packages/flutter_dotenv)

---

## ✅ 10. Checklist التحقق النهائي

### التطبيق:
- [x] تثبيت `pusher_channels_flutter`
- [x] تثبيت `flutter_dotenv`
- [x] إنشاء ملف `.env`
- [x] إضافة `.env` إلى `.gitignore`
- [x] إضافة `.env` إلى `pubspec.yaml` assets
- [x] إنشاء `PusherService`
- [x] تهيئة Pusher في `main.dart`
- [ ] اختبار استقبال الأحداث

### الباك إند:
- [x] إضافة إعدادات Pusher إلى `.env`
- [x] إنشاء `config/broadcasting.php`
- [x] إنشاء Events
- [x] إنشاء Test Controller
- [x] إضافة routes للاختبار
- [ ] تثبيت `pusher/pusher-php-server`
- [ ] اختبار إرسال الأحداث

### الأمان:
- [x] إضافة `.env` إلى `.gitignore`
- [ ] إعادة توليد مفاتيح Pusher
- [ ] تحديث المفاتيح في الملفات

---

**تم الإنجاز**: 24 فبراير 2026
**الحالة**: ✅ جاهز للاختبار
**المطور**: Claude Code
