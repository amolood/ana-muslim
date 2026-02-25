<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>تعديل الباب - إدارة حصن المسلم</title>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['IBM Plex Sans Arabic', 'sans-serif'] },
                    colors: { primary: '#11D4B4' }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50">

<div class="min-h-screen">
    <header class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center">
                <h1 class="text-3xl font-bold text-gray-900">تعديل الباب</h1>
                <a href="{{ route('admin.hisnmuslim.show', $chapter->id) }}" class="text-primary hover:text-primary/80">← العودة للباب</a>
            </div>
        </div>
    </header>

    <main class="max-w-3xl mx-auto px-4 py-8 sm:px-6 lg:px-8">

        @if($errors->any())
            <div class="mb-6 bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded">
                <ul class="list-disc list-inside">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <div class="bg-white shadow rounded-lg p-6">
            <form action="{{ route('admin.hisnmuslim.chapter.update', $chapter->id) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="space-y-6">
                    <!-- العنوان بالعربي -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">العنوان بالعربي *</label>
                        <input type="text" name="title_ar" value="{{ old('title_ar', $chapter->title_ar) }}" required
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">
                    </div>

                    <!-- العنوان بالإنجليزي -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">العنوان بالإنجليزي</label>
                        <input type="text" name="title_en" value="{{ old('title_en', $chapter->title_en) }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">
                    </div>

                    <!-- رابط الصوت -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">رابط الصوت</label>
                        <input type="url" name="audio_url" value="{{ old('audio_url', $chapter->audio_url) }}"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                               placeholder="https://example.com/audio.mp3">
                        <p class="mt-1 text-sm text-gray-500">رابط ملف MP3 للباب كاملاً</p>
                    </div>

                    <!-- الترتيب -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">الترتيب *</label>
                        <input type="number" name="order" value="{{ old('order', $chapter->order) }}" required min="0"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">
                        <p class="mt-1 text-sm text-gray-500">رقم الترتيب في القائمة</p>
                    </div>

                    <!-- الحالة -->
                    <div>
                        <label class="flex items-center gap-2">
                            <input type="checkbox" name="is_active" value="1" {{ old('is_active', $chapter->is_active) ? 'checked' : '' }}
                                   class="w-5 h-5 text-primary border-gray-300 rounded focus:ring-primary">
                            <span class="text-sm font-medium text-gray-700">نشط</span>
                        </label>
                    </div>
                </div>

                <!-- الأزرار -->
                <div class="mt-8 flex gap-4">
                    <button type="submit" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary/90 transition font-medium">
                        حفظ التعديلات
                    </button>
                    <a href="{{ route('admin.hisnmuslim.show', $chapter->id) }}" class="bg-gray-200 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-300 transition font-medium">
                        إلغاء
                    </a>
                </div>
            </form>
        </div>

    </main>
</div>

</body>
</html>
