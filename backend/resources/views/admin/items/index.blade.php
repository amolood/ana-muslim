<x-admin-layout>
    <!-- Header Section -->
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            @if(isset($currentCategory) && $currentCategory)
                <div class="flex items-center gap-2 mb-2">
                    <a href="{{ route('admin.categories.index', ['parent_id' => $currentCategory->parent_id]) }}" class="text-sm font-bold text-gray-500 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors tooltip" title="العودة لشجرة التصنيفات">
                        <i class="fa-solid fa-folder-tree"></i> شجرة التصنيفات
                    </a>
                    <i class="fa-solid fa-chevron-left text-[10px] text-gray-400"></i>
                    <span class="text-sm font-bold text-blue-600 dark:text-blue-400">مواد لتصنيف: {{ $currentCategory->title }}</span>
                </div>
            @endif
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إدارة المواد العلمية والدعوية</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">نظرة عامة وإدارة شاملة لجميع أنواع المحتوى في المنصة</p>
        </div>
        <div class="flex items-center gap-3">
            @if(isset($currentCategory) && $currentCategory)
                <a href="{{ route('admin.items.index') }}" class="admin-btn bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/5 dark:text-white dark:ring-transparent dark:hover:bg-white/10 transition-all">
                    <i class="fa-solid fa-list-ul ml-2"></i> عرض كافة المواد
                </a>
            @endif
            <a href="{{ route('admin.items.create') }}" class="admin-btn bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-plus ml-2"></i> إضافة مادة جديدة
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 bg-gradient-to-l from-emerald-500/10 to-transparent border-r-4 border-emerald-500 p-4 rounded-xl flex items-center gap-3 backdrop-blur-sm">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                <i class="fa-solid fa-check"></i>
            </div>
            <p class="text-sm font-bold text-emerald-700 dark:text-emerald-400">{{ session('success') }}</p>
        </div>
    @endif

    <!-- 📊 Statistics Cards Grid -->
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Stat Card 1: Total Items -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-blue-500 to-indigo-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي المواد</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_items']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-xl text-blue-600 group-hover:scale-110 transition-transform dark:bg-blue-900/20 dark:text-blue-400">
                    <i class="fa-solid fa-boxes-stacked"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                كافة المواد المضافة للنظام
            </div>
        </div>

        <!-- Stat Card 2: Audio & Video -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-rose-500 to-pink-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">مرئيات وصوتيات</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['audio_video']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-rose-50 text-xl text-rose-600 group-hover:scale-110 transition-transform dark:bg-rose-900/20 dark:text-rose-400">
                    <i class="fa-solid fa-photo-film"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                دروس ومحاضرات ومقاطع
            </div>
        </div>

        <!-- Stat Card 3: Books & Articles -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-emerald-500 to-teal-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">كتب ومقالات</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['books_articles']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-xl text-emerald-600 group-hover:scale-110 transition-transform dark:bg-emerald-900/20 dark:text-emerald-400">
                    <i class="fa-solid fa-book-open"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                محتوى مقروء ونصوص
            </div>
        </div>

        <!-- Stat Card 4: Total Authors -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي المؤلفين والقراء</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_authors']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-xl text-amber-600 group-hover:scale-110 transition-transform dark:bg-amber-900/20 dark:text-amber-400">
                    <i class="fa-solid fa-users-rectangle"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                شيوخ ودعاة وقراء ومترجمين
            </div>
        </div>
    </div>

    <!-- Search & Filter Area -->
    <div class="admin-card mb-6 p-2 ring-1 ring-gray-900/5 dark:ring-white/10">
        <form action="{{ route('admin.items.index') }}" method="GET" class="flex flex-col sm:flex-row gap-2">
            @if(request('category_id'))
                <input type="hidden" name="category_id" value="{{ request('category_id') }}">
            @endif
            <!-- Search bar -->
            <div class="relative flex-1 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-magnifying-glass text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث باسم المادة، وصفها، أو محتواها..." 
                    class="block w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
            </div>

            <!-- Type Filter -->
            <div class="relative w-full sm:w-64 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-filter text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <select name="type" class="block w-full appearance-none rounded-xl border-0 bg-gray-50 py-3 pl-10 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
                    <option value="">جميع الأنواع والتصنيفات</option>
                    @foreach($types as $t)
                        <option value="{{ $t }}" {{ request('type') == $t ? 'selected' : '' }} class="dark:bg-gray-800">
                            {{ $typeMap[strtolower($t)] ?? ucfirst($t) }}
                        </option>
                    @endforeach
                </select>
                <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
                    <i class="fa-solid fa-chevron-down text-gray-400 text-xs"></i>
                </div>
            </div>

            <button type="submit" class="flex items-center justify-center h-[46px] rounded-xl bg-gray-900 px-6 text-sm font-semibold text-white shadow-sm hover:bg-gray-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-900 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100 transition-colors">
                فلترة النتائج
            </button>

            @if(request()->has('search') || request()->has('type') || request()->has('category_id'))
                <a href="{{ route('admin.items.index') }}" class="flex items-center justify-center h-[46px] rounded-xl bg-red-50 px-4 text-sm font-semibold text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20 transition-colors tooltip" title="إلغاء جميع الفلاتر">
                    <i class="fa-solid fa-times"></i>
                </a>
            @endif
        </form>
    </div>

    <!-- Main Table -->
    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الصورة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">العنوان والنوع</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">المؤلفون / القراء</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">التصنيفات المربوطة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($items as $item)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                            <!-- Image -->
                            <td class="px-6 py-4 w-20">
                                @if($item->image)
                                    <div class="relative h-14 w-14 overflow-hidden rounded-xl shadow-sm ring-1 ring-gray-900/10 dark:ring-white/10">
                                        <img src="{{ $item->image }}" alt="" class="h-full w-full object-cover group-hover:scale-110 transition-transform duration-500">
                                    </div>
                                @else
                                    <div class="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-gray-100 to-gray-200 text-gray-400 shadow-sm ring-1 ring-gray-900/10 dark:from-white/5 dark:to-white/10 dark:ring-white/10">
                                        <i class="fa-solid fa-clapperboard text-lg opacity-50"></i>
                                    </div>
                                @endif
                            </td>

                            <!-- Title & Type -->
                            <td class="px-6 py-4 max-w-[250px]">
                                <div class="font-bold text-gray-900 dark:text-white line-clamp-2 text-sm mb-1.5 leading-tight" title="{{ $item->title }}">
                                    {{ $item->title }}
                                </div>
                                @php
                                    $displayType = $item->type;
                                    if (is_numeric($displayType) || empty(trim($displayType))) {
                                        $displayType = 'غير محدد';
                                    } else {
                                        $displayType = $typeMap[strtolower($displayType)] ?? ucfirst($displayType);
                                    }
                                @endphp
                                <span class="inline-flex items-center gap-1.5 rounded-md bg-indigo-50 px-2 py-0.5 text-[11px] font-bold text-indigo-600 ring-1 ring-inset ring-indigo-500/10 dark:bg-indigo-400/10 dark:text-indigo-400 dark:ring-indigo-400/20">
                                    <i class="fa-solid fa-tag text-[9px]"></i>
                                    {{ $displayType }}
                                </span>
                            </td>

                            <!-- Avatar Stack Authors Display -->
                            <td class="px-6 py-4 min-w-[200px]">
                                @if($item->authors->isEmpty())
                                    <span class="inline-flex items-center gap-1.5 rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-500 ring-1 ring-inset ring-gray-500/10 dark:bg-white/5 dark:text-gray-400 dark:ring-white/10">
                                        بدون مؤلف
                                    </span>
                                @else
                                    <div class="flex items-center -space-x-2 space-x-reverse">
                                        @foreach($item->authors->take(3) as $i => $author)
                                            <!-- Generate Avatar Letters (first letter of first two words) -->
                                            @php
                                                $words = explode(' ', trim($author->title));
                                                $initials = mb_substr($words[0], 0, 1, 'UTF-8');
                                                if (isset($words[1])) {
                                                    $initials .= ' ' . mb_substr($words[1], 0, 1, 'UTF-8');
                                                }
                                                // Dynamic colors based on index for variety
                                                $colors = [
                                                    'bg-blue-100 text-blue-700 dark:bg-blue-900/50 dark:text-blue-300 ring-white dark:ring-slate-900',
                                                    'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300 ring-white dark:ring-slate-900',
                                                    'bg-amber-100 text-amber-700 dark:bg-amber-900/50 dark:text-amber-300 ring-white dark:ring-slate-900'
                                                ];
                                                $colorClass = $colors[$i % 3];
                                            @endphp

                                            <div class="relative group/avatar cursor-help">
                                                <div class="flex h-10 w-10 items-center justify-center rounded-full ring-2 {{ $colorClass }} shadow-sm text-xs font-black shadow-sm transition-transform hover:z-10 hover:-translate-y-1">
                                                    {{ $initials }}
                                                </div>
                                                <!-- Tooltip -->
                                                <div class="absolute bottom-full right-1/2 mb-2 hidden w-max max-w-[200px] translate-x-1/2 rounded bg-gray-900 px-2.5 py-1.5 text-xs font-medium text-white shadow-xl group-hover/avatar:block dark:bg-white dark:text-gray-900 z-50">
                                                    {{ $author->title }}
                                                    <div class="absolute top-full right-1/2 -mt-px h-0 w-0 translate-x-1/2 border-4 border-transparent border-t-gray-900 dark:border-t-white"></div>
                                                </div>
                                            </div>
                                        @endforeach
                                        
                                        <!-- Remaining Authors Bubble -->
                                        @if($item->authors->count() > 3)
                                            <div class="relative group/avatar cursor-help z-10">
                                                <div class="flex h-10 w-10 items-center justify-center rounded-full ring-2 bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-300 ring-white dark:ring-slate-900 shadow-sm text-[11px] font-black transition-transform hover:-translate-y-1">
                                                    +{{ $item->authors->count() - 3 }}
                                                </div>
                                                <!-- Tooltip for remaining -->
                                                <div class="absolute bottom-full right-1/2 mb-2 hidden w-max max-w-[250px] translate-x-1/2 rounded bg-gray-900 p-2 text-xs font-medium text-white shadow-xl group-hover/avatar:block dark:bg-white dark:text-gray-900 z-50">
                                                    <ul class="text-right list-disc list-inside">
                                                        @foreach($item->authors->skip(3) as $remainingAuthor)
                                                            <li class="truncate">{{ $remainingAuthor->title }}</li>
                                                        @endforeach
                                                    </ul>
                                                    <div class="absolute top-full right-1/2 -mt-px h-0 w-0 translate-x-1/2 border-4 border-transparent border-t-gray-900 dark:border-t-white"></div>
                                                </div>
                                            </div>
                                        @endif
                                    </div>
                                @endif
                            </td>

                            <!-- Categories Tags -->
                            <td class="px-6 py-4 max-w-[200px]">
                                <div class="flex flex-wrap gap-1.5">
                                    @forelse($item->categories->take(2) as $category)
                                        <a href="{{ route('admin.items.index', ['category_id' => $category->id]) }}" class="group/cat inline-flex items-center gap-1 rounded-md bg-gray-100 pl-2 pr-1.5 py-1 text-[11px] font-medium text-gray-700 dark:bg-white/5 dark:text-gray-300 hover:bg-indigo-50 hover:text-indigo-600 ring-1 ring-transparent hover:ring-indigo-200 dark:hover:bg-indigo-500/20 dark:hover:text-indigo-400 dark:hover:ring-indigo-500/30 transition-all tooltip" title="تصفية عبر: {{ $category->title }}">
                                            <span class="truncate max-w-[80px]"><i class="fa-solid fa-filter text-[8px] opacity-50 mr-1"></i> {{ $category->title }}</span>
                                        </a>
                                    @empty
                                        <span class="text-xs text-gray-400">-</span>
                                    @endforelse
                                    
                                    @if($item->categories->count() > 2)
                                        <div class="inline-flex items-center justify-center rounded-md bg-blue-50 px-2 py-1 text-[11px] font-bold text-blue-700 dark:bg-blue-500/10 dark:text-blue-400 cursor-help tooltip" title="يوجد {{ $item->categories->count() - 2 }} تصنيفات أخرى">
                                            +{{ $item->categories->count() - 2 }}
                                        </div>
                                    @endif
                                </div>
                            </td>

                            <!-- Actions -->
                            <td class="px-6 py-4 text-left">
                                <div class="flex items-center justify-end gap-1.5 opacity-100 lg:opacity-60 xl:opacity-100 group-hover:opacity-100 transition-opacity">
                                    <a href="{{ route('admin.attachments.index', ['item_id' => $item->id]) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-emerald-50 hover:text-emerald-600 hover:ring-emerald-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-emerald-500/20 dark:hover:text-emerald-400 dark:hover:ring-transparent transition-all" title="استعراض المرفقات (ملفات الصوت، الكتب، إلخ)">
                                        <i class="fa-solid fa-photo-film"></i>
                                    </a>
                                    <a href="{{ route('admin.items.edit', $item->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:ring-blue-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400 dark:hover:ring-transparent transition-all" title="تعديل بيانات المادة">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <form action="{{ route('admin.items.destroy', $item->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذه المادة؟ سيتم حذف جميع المرفقات المرتبطة بها نهائياً ولن تتمكن من استعادتها.');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-red-50 hover:text-red-600 hover:ring-red-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400 dark:hover:ring-transparent transition-all" title="حذف المادة">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-6 py-16 text-center">
                                <div class="flex flex-col items-center justify-center">
                                    <div class="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-gray-50 dark:bg-white/5">
                                        <i class="fa-solid fa-inbox text-3xl text-gray-400"></i>
                                    </div>
                                    <h3 class="mt-2 text-sm font-bold text-gray-900 dark:text-white">لا توجد مواد علمية حالياً</h3>
                                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">ابدأ بإضافة أول مادة علمية، كتاب، أو محاضرة إلى المنصة.</p>
                                    <div class="mt-6">
                                        <a href="{{ route('admin.items.create') }}" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                                            <i class="fa-solid fa-plus ml-2"></i> إضافة مادة جديدة
                                        </a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        
        @if($items->hasPages())
            <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                {{ $items->withQueryString()->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
