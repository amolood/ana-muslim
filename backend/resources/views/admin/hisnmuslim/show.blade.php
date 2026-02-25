<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $chapter->title_ar }} - إدارة حصن المسلم</title>
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
                <h1 class="text-3xl font-bold text-gray-900">{{ $chapter->title_ar }}</h1>
                <a href="{{ route('admin.hisnmuslim.index') }}" class="text-primary hover:text-primary/80">← العودة للقائمة</a>
            </div>
        </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">

        @if(session('success'))
            <div class="mb-6 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded">
                {{ session('success') }}
            </div>
        @endif

        <!-- Chapter Info -->
        <div class="bg-white p-6 rounded-lg shadow mb-8">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div>
                    <div class="text-sm text-gray-500">رقم الباب</div>
                    <div class="text-lg font-bold">{{ $chapter->chapter_id }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">الترتيب</div>
                    <div class="text-lg font-bold">{{ $chapter->order }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">عدد الأدعية</div>
                    <div class="text-lg font-bold text-primary">{{ $chapter->duas->count() }}</div>
                </div>
                <div>
                    <div class="text-sm text-gray-500">الحالة</div>
                    <div class="text-lg font-bold">
                        @if($chapter->is_active)
                            <span class="text-green-600">نشط</span>
                        @else
                            <span class="text-gray-600">غير نشط</span>
                        @endif
                    </div>
                </div>
            </div>
            <div class="mt-4 flex gap-4">
                <a href="{{ route('admin.hisnmuslim.chapter.edit', $chapter->id) }}" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">تعديل الباب</a>
                <a href="{{ route('admin.hisnmuslim.dua.create', $chapter->id) }}" class="bg-primary text-white px-4 py-2 rounded hover:bg-primary/90">+ إضافة دعاء</a>
            </div>
        </div>

        <!-- Duas List -->
        <h2 class="text-2xl font-bold mb-4">الأدعية ({{ $chapter->duas->count() }})</h2>

        <div class="space-y-4">
            @forelse($chapter->duas->sortBy('order') as $dua)
                <div class="bg-white p-6 rounded-lg shadow">
                    <div class="flex justify-between items-start mb-4">
                        <span class="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-medium">#{{ $dua->order }}</span>
                        <div class="flex gap-2">
                            <a href="{{ route('admin.hisnmuslim.dua.edit', $dua->id) }}" class="text-blue-600 hover:text-blue-800 text-sm">تعديل</a>
                            <form action="{{ route('admin.hisnmuslim.dua.delete', $dua->id) }}" method="POST" class="inline" onsubmit="return confirm('هل أنت متأكد من حذف هذا الدعاء؟')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-800 text-sm">حذف</button>
                            </form>
                        </div>
                    </div>

                    <p class="text-2xl font-arabic leading-loose mb-4">{{ $dua->text_ar }}</p>

                    @if($dua->translation_ar)
                        <div class="border-t pt-4 mb-4">
                            <div class="text-sm text-gray-500 mb-1">الترجمة:</div>
                            <p class="text-gray-700">{{ $dua->translation_ar }}</p>
                        </div>
                    @endif

                    <div class="flex gap-4 text-sm">
                        @if($dua->reference)
                            <span class="text-gray-600"><strong>المصدر:</strong> {{ $dua->reference }}</span>
                        @endif
                        @if($dua->count)
                            <span class="text-primary"><strong>التكرار:</strong> {{ $dua->count }} مرات</span>
                        @endif
                        <span class="text-gray-500">
                            @if($dua->is_active)
                                <span class="text-green-600">نشط</span>
                            @else
                                <span class="text-gray-400">غير نشط</span>
                            @endif
                        </span>
                    </div>
                </div>
            @empty
                <div class="bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
                    <p class="text-gray-500 mb-4">لا توجد أدعية في هذا الباب</p>
                    <a href="{{ route('admin.hisnmuslim.dua.create', $chapter->id) }}" class="inline-block bg-primary text-white px-6 py-2 rounded hover:bg-primary/90">
                        + إضافة أول دعاء
                    </a>
                </div>
            @endforelse
        </div>

    </main>
</div>

</body>
</html>
