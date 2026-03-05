<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            @if(isset($currentCategory) && $currentCategory)
                <div class="mb-2 flex items-center gap-2 text-xs font-bold text-gray-500 dark:text-gray-400">
                    <a href="{{ route('admin.categories.index', ['parent_id' => $currentCategory->parent_id]) }}" class="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                        <i class="fa-solid fa-folder-tree ml-1"></i> شجرة التصنيفات
                    </a>
                    <i class="fa-solid fa-chevron-left text-[10px]"></i>
                    <span class="text-blue-600 dark:text-blue-400">مواد لتصنيف: {{ $currentCategory->title }}</span>
                </div>
            @endif
            <h2 class="text-2xl font-black text-gray-800 dark:text-white">إدارة المواد العلمية والدعوية</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إدارة المحتوى وربطه بالمؤلفين والتصنيفات بصورة عملية ومنظمة</p>
        </div>

        <div class="flex flex-wrap items-center gap-3">
            @if(isset($currentCategory) && $currentCategory)
                <a href="{{ route('admin.items.index') }}" class="admin-btn bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/5 dark:text-white dark:ring-transparent dark:hover:bg-white/10">
                    <i class="fa-solid fa-list ml-2"></i> كافة المواد
                </a>
            @endif
            <a href="{{ route('admin.items.create') }}" class="admin-btn bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30 hover:-translate-y-0.5 hover:shadow-blue-500/50 transition-all">
                <i class="fa-solid fa-plus ml-2"></i> إضافة مادة
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 rounded-xl border-r-4 border-emerald-500 bg-gradient-to-l from-emerald-500/10 to-transparent p-4 text-sm font-bold text-emerald-700 dark:text-emerald-400">
            <i class="fa-solid fa-check ml-2"></i>{{ session('success') }}
        </div>
    @endif

    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">إجمالي المواد</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_items']) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">مرئيات وصوتيات</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['audio_video']) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">كتب ومقالات</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['books_articles']) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">مؤلفون وقراء</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_authors']) }}</p>
        </div>
    </div>

    <div class="admin-card mb-6 p-4">
        <form action="{{ route('admin.items.index') }}" method="GET" class="grid grid-cols-1 gap-3 md:grid-cols-4">
            @if(request('category_id'))
                <input type="hidden" name="category_id" value="{{ request('category_id') }}">
            @endif

            <div class="relative md:col-span-2">
                <i class="fa-solid fa-magnifying-glass pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث بالعنوان، الوصف، أو اسم المؤلف"
                    class="w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10">
            </div>

            <div>
                <select name="type" class="w-full rounded-xl border-0 bg-gray-50 py-3 px-4 text-sm ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10">
                    <option value="">كل الأنواع</option>
                    @foreach($types as $t)
                        <option value="{{ $t }}" {{ request('type') == $t ? 'selected' : '' }} class="dark:bg-gray-800">
                            {{ $typeMap[strtolower($t)] ?? ucfirst($t) }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="flex items-center gap-2">
                <button type="submit" class="h-[46px] w-full rounded-xl bg-gray-900 px-4 text-sm font-bold text-white hover:bg-gray-800 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100">
                    تطبيق
                </button>
                @if(request('search') || request('type') || request('category_id'))
                    <a href="{{ route('admin.items.index') }}" class="flex h-[46px] w-12 items-center justify-center rounded-xl bg-red-50 text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20">
                        <i class="fa-solid fa-xmark"></i>
                    </a>
                @endif
            </div>
        </form>
    </div>

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm">
                <thead>
                    <tr class="border-b border-gray-100 bg-gray-50/80 text-gray-500 dark:border-white/10 dark:bg-white/5 dark:text-gray-400">
                        <th class="px-6 py-4 text-xs font-bold">الصورة</th>
                        <th class="px-6 py-4 text-xs font-bold">العنوان والنوع</th>
                        <th class="px-6 py-4 text-xs font-bold">المؤلفون</th>
                        <th class="px-6 py-4 text-xs font-bold">التصنيفات</th>
                        <th class="px-6 py-4 text-left text-xs font-bold">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($items as $item)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02]">
                            <td class="w-20 px-6 py-4">
                                @if($item->image)
                                    <div class="h-14 w-14 overflow-hidden rounded-xl ring-1 ring-gray-900/10 dark:ring-white/10">
                                        <img src="{{ $item->image }}" alt="" class="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110">
                                    </div>
                                @else
                                    <div class="flex h-14 w-14 items-center justify-center rounded-xl bg-gray-100 text-gray-400 dark:bg-white/5 dark:text-gray-500">
                                        <i class="fa-solid fa-clapperboard"></i>
                                    </div>
                                @endif
                            </td>

                            <td class="max-w-[280px] px-6 py-4">
                                <p class="mb-1.5 line-clamp-2 text-sm font-bold text-gray-900 dark:text-white" title="{{ $item->title }}">{{ $item->title }}</p>
                                @php
                                    $displayType = $item->type;
                                    if (is_numeric($displayType) || empty(trim((string) $displayType))) {
                                        $displayType = 'غير محدد';
                                    } else {
                                        $displayType = $typeMap[strtolower($displayType)] ?? ucfirst($displayType);
                                    }
                                @endphp
                                <span class="inline-flex items-center rounded-md bg-indigo-50 px-2 py-1 text-[11px] font-bold text-indigo-700 dark:bg-indigo-500/10 dark:text-indigo-300">{{ $displayType }}</span>
                            </td>

                            <td class="min-w-[200px] px-6 py-4">
                                @if($item->authors->isEmpty())
                                    <span class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-bold text-gray-500 dark:bg-white/5 dark:text-gray-400">بدون مؤلف</span>
                                @else
                                    <div class="flex flex-wrap gap-1.5">
                                        @foreach($item->authors->take(3) as $author)
                                            <span class="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-bold text-blue-700 dark:bg-blue-500/10 dark:text-blue-300" title="{{ $author->title }}">
                                                {{ $author->title }}
                                            </span>
                                        @endforeach
                                        @if($item->authors->count() > 3)
                                            <span class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-bold text-gray-600 dark:bg-white/5 dark:text-gray-300">+{{ $item->authors->count() - 3 }}</span>
                                        @endif
                                    </div>
                                @endif
                            </td>

                            <td class="max-w-[230px] px-6 py-4">
                                <div class="flex flex-wrap gap-1.5">
                                    @forelse($item->categories->take(2) as $category)
                                        <a href="{{ route('admin.items.index', ['category_id' => $category->id]) }}" class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-[11px] font-bold text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-indigo-500/20 dark:hover:text-indigo-300">
                                            {{ $category->title }}
                                        </a>
                                    @empty
                                        <span class="text-xs text-gray-400">-</span>
                                    @endforelse

                                    @if($item->categories->count() > 2)
                                        <span class="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-[11px] font-bold text-blue-700 dark:bg-blue-500/10 dark:text-blue-300">+{{ $item->categories->count() - 2 }}</span>
                                    @endif
                                </div>
                            </td>

                            <td class="px-6 py-4 text-left">
                                <div class="flex items-center justify-end gap-1.5">
                                    <a href="{{ route('admin.attachments.index', ['item_id' => $item->id]) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 ring-1 ring-inset ring-gray-300 transition-all hover:bg-emerald-50 hover:text-emerald-600 dark:bg-white/5 dark:ring-transparent dark:hover:bg-emerald-500/20 dark:hover:text-emerald-400" title="المرفقات">
                                        <i class="fa-solid fa-photo-film"></i>
                                    </a>
                                    <a href="{{ route('admin.items.edit', $item->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 ring-1 ring-inset ring-gray-300 transition-all hover:bg-blue-50 hover:text-blue-600 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400" title="تعديل">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <form action="{{ route('admin.items.destroy', $item->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذه المادة؟ سيتم حذف جميع المرفقات المرتبطة بها نهائياً.');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 ring-1 ring-inset ring-gray-300 transition-all hover:bg-red-50 hover:text-red-600 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400" title="حذف">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-6 py-16 text-center">
                                <div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-gray-50 dark:bg-white/5">
                                    <i class="fa-solid fa-inbox text-3xl text-gray-400"></i>
                                </div>
                                <h3 class="text-sm font-bold text-gray-900 dark:text-white">لا توجد مواد حالياً</h3>
                                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">ابدأ بإضافة أول مادة علمية، كتاب، أو محاضرة.</p>
                                <div class="mt-6">
                                    <a href="{{ route('admin.items.create') }}" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                                        <i class="fa-solid fa-plus ml-2"></i> إضافة مادة
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($items->hasPages())
            <div class="border-t border-gray-100 bg-gray-50/50 p-4 dark:border-white/10 dark:bg-white/[0.02]">
                {{ $items->withQueryString()->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
