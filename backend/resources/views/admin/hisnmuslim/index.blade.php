<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>إدارة حصن المسلم - أنا المسلم</title>

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
    <!-- Header -->
    <header class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold text-gray-900">إدارة حصن المسلم</h1>
            <div class="flex gap-4">
                <a href="{{ url('/hisnmuslim') }}" class="text-primary hover:text-primary/80">عرض الصفحة</a>
                <a href="{{ route('admin.dashboard') }}" class="text-gray-600 hover:text-gray-900">لوحة التحكم</a>
            </div>
        </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">

        @if(session('success'))
            <div class="mb-6 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded">
                {{ session('success') }}
            </div>
        @endif

        <!-- Stats -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white p-6 rounded-lg shadow">
                <div class="text-sm text-gray-500 mb-1">إجمالي الأبواب</div>
                <div class="text-3xl font-bold text-primary">{{ $chapters->total() }}</div>
            </div>
            <div class="bg-white p-6 rounded-lg shadow">
                <div class="text-sm text-gray-500 mb-1">إجمالي الأدعية</div>
                <div class="text-3xl font-bold text-primary">{{ $chapters->sum('duas_count') }}</div>
            </div>
            <div class="bg-white p-6 rounded-lg shadow">
                <div class="text-sm text-gray-500 mb-1">متوسط الأدعية لكل باب</div>
                <div class="text-3xl font-bold text-primary">{{ round($chapters->avg('duas_count'), 1) }}</div>
            </div>
        </div>

        <!-- Actions -->
        <div class="mb-6 flex justify-between items-center">
            <h2 class="text-2xl font-bold text-gray-900">قائمة الأبواب</h2>
            <a href="{{ route('admin.hisnmuslim.chapter.create') }}" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary/90 transition">
                + إضافة باب جديد
            </a>
        </div>

        <!-- Chapters Table -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الترتيب</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">العنوان</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">عدد الأدعية</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الحالة</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    @foreach($chapters as $chapter)
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ $chapter->order }}</td>
                            <td class="px-6 py-4 text-sm text-gray-900">
                                <div class="font-medium">{{ $chapter->title_ar }}</div>
                                @if($chapter->title_en)
                                    <div class="text-gray-500 text-xs">{{ $chapter->title_en }}</div>
                                @endif
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <span class="bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium">
                                    {{ $chapter->duas_count }} دعاء
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                @if($chapter->is_active)
                                    <span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium">نشط</span>
                                @else
                                    <span class="bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-medium">غير نشط</span>
                                @endif
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <div class="flex gap-2">
                                    <a href="{{ route('admin.hisnmuslim.show', $chapter->id) }}" class="text-primary hover:text-primary/80">عرض</a>
                                    <a href="{{ route('admin.hisnmuslim.chapter.edit', $chapter->id) }}" class="text-blue-600 hover:text-blue-800">تعديل</a>
                                    <form action="{{ route('admin.hisnmuslim.chapter.delete', $chapter->id) }}" method="POST" class="inline" onsubmit="return confirm('هل أنت متأكد من حذف هذا الباب وجميع أدعيته؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="text-red-600 hover:text-red-800">حذف</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <div class="mt-6">
            {{ $chapters->links() }}
        </div>

    </main>
</div>

</body>
</html>
