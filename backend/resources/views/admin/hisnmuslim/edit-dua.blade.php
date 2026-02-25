<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>تعديل الدعاء - إدارة حصن المسلم</title>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&family=Amiri:wght@400;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['IBM Plex Sans Arabic', 'sans-serif'], arabic: ['Amiri', 'serif'] },
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
                <div>
                    <h1 class="text-3xl font-bold text-gray-900">تعديل الدعاء</h1>
                    <p class="text-gray-600 mt-1">{{ $dua->chapter->title_ar }}</p>
                </div>
                <a href="{{ route('admin.hisnmuslim.show', $dua->chapter_id) }}" class="text-primary hover:text-primary/80">← العودة للباب</a>
            </div>
        </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-8 sm:px-6 lg:px-8">

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
            <form action="{{ route('admin.hisnmuslim.dua.update', $dua->id) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="space-y-6">
                    <!-- النص العربي -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">النص العربي *</label>
                        <textarea name="text_ar" rows="4" required
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent font-arabic text-xl">{{ old('text_ar', $dua->text_ar) }}</textarea>
                    </div>

                    <!-- النص الإنجليزي -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">النص الإنجليزي</label>
                        <textarea name="text_en" rows="4"
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">{{ old('text_en', $dua->text_en) }}</textarea>
                    </div>

                    <!-- الترجمة العربية -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">الترجمة / الشرح بالعربي</label>
                        <textarea name="translation_ar" rows="3"
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">{{ old('translation_ar', $dua->translation_ar) }}</textarea>
                    </div>

                    <!-- الترجمة الإنجليزية -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">الترجمة بالإنجليزي</label>
                        <textarea name="translation_en" rows="3"
                                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">{{ old('translation_en', $dua->translation_en) }}</textarea>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <!-- المرجع -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">المرجع / المصدر</label>
                            <input type="text" name="reference" value="{{ old('reference', $dua->reference) }}"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                                   placeholder="مثال: صحيح البخاري">
                        </div>

                        <!-- عدد التكرار -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">عدد التكرار</label>
                            <input type="number" name="count" value="{{ old('count', $dua->count) }}" min="1"
                                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">
                        </div>
                    </div>

                    <!-- الترتيب -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-2">الترتيب *</label>
                        <input type="number" name="order" value="{{ old('order', $dua->order) }}" required min="0"
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent">
                        <p class="mt-1 text-sm text-gray-500">رقم الترتيب داخل الباب</p>
                    </div>

                    <!-- الحالة -->
                    <div>
                        <label class="flex items-center gap-2">
                            <input type="checkbox" name="is_active" value="1" {{ old('is_active', $dua->is_active) ? 'checked' : '' }}
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
                    <a href="{{ route('admin.hisnmuslim.show', $dua->chapter_id) }}" class="bg-gray-200 text-gray-700 px-6 py-2 rounded-lg hover:bg-gray-300 transition font-medium">
                        إلغاء
                    </a>
                </div>
            </form>
        </div>

    </main>
</div>

</body>
</html>
