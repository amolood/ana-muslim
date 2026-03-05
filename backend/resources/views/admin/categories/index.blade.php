<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            @if($currentParent)
                <div class="mb-2 flex flex-wrap items-center gap-2 text-xs font-bold text-gray-500 dark:text-gray-400">
                    <a href="{{ route('admin.categories.index') }}" class="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                        <i class="fa-solid fa-home ml-1"></i> الأقسام الرئيسية
                    </a>
                    @if($currentParent->parent)
                        <i class="fa-solid fa-chevron-left text-[10px]"></i>
                        <a href="{{ route('admin.categories.index', ['parent_id' => $currentParent->parent_id]) }}" class="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                            {{ $currentParent->parent->title }}
                        </a>
                    @endif
                    <i class="fa-solid fa-chevron-left text-[10px]"></i>
                    <span class="text-blue-600 dark:text-blue-400">{{ $currentParent->title }}</span>
                </div>
                <h2 class="text-2xl font-black text-gray-800 dark:text-white">إدارة التصنيفات الفرعية</h2>
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إدارة التفرعات التابعة لتصنيف: {{ $currentParent->title }}</p>
            @else
                <h2 class="text-2xl font-black text-gray-800 dark:text-white">إدارة التصنيفات</h2>
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">هيكلة المحتوى بحسب أقسام رئيسية وفرعية بطريقة منظمة</p>
            @endif
        </div>

        <div class="flex flex-wrap items-center gap-3">
            @if($currentParent)
                <a href="{{ route('admin.categories.index') }}" class="admin-btn bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/5 dark:text-white dark:ring-transparent dark:hover:bg-white/10">
                    <i class="fa-solid fa-list ml-2"></i> عرض الأقسام الرئيسية
                </a>
            @endif
            <a href="{{ route('admin.categories.create') }}" class="admin-btn bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30 hover:-translate-y-0.5 hover:shadow-blue-500/50 transition-all">
                <i class="fa-solid fa-plus ml-2"></i> إضافة تصنيف
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 rounded-xl border-r-4 border-emerald-500 bg-gradient-to-l from-emerald-500/10 to-transparent p-4 text-sm font-bold text-emerald-700 dark:text-emerald-400">
            <i class="fa-solid fa-check ml-2"></i>{{ session('success') }}
        </div>
    @endif

    @if($errors->any())
        <div class="mb-6 rounded-xl border-r-4 border-red-500 bg-gradient-to-l from-red-500/10 to-transparent p-4">
            @foreach($errors->all() as $error)
                <p class="text-sm font-bold text-red-700 dark:text-red-400"><i class="fa-solid fa-circle-exclamation ml-2"></i>{{ $error }}</p>
            @endforeach
        </div>
    @endif

    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">إجمالي التصنيفات</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_categories'] ?? 0) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">أقسام رئيسية</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['root_categories'] ?? 0) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">أقسام فرعية</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['sub_categories'] ?? 0) }}</p>
        </div>
        <div class="admin-card p-5">
            <p class="text-xs font-bold text-gray-500 dark:text-gray-400">مواد مربوطة</p>
            <p class="mt-2 text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_items_in_categories'] ?? 0) }}</p>
        </div>
    </div>

    <div class="admin-card mb-6 p-4">
        <form action="{{ route('admin.categories.index') }}" method="GET" class="grid grid-cols-1 gap-3 md:grid-cols-4">
            @if($currentParent)
                <input type="hidden" name="parent_id" value="{{ $currentParent->id }}">
            @endif

            <div class="relative md:col-span-2">
                <i class="fa-solid fa-magnifying-glass pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث بعنوان التصنيف أو الاسم البرمجي"
                    class="w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10">
            </div>

            @unless($currentParent)
                <div>
                    <select name="parent_id" class="w-full rounded-xl border-0 bg-gray-50 py-3 px-4 text-sm ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10">
                        <option value="">كل التصنيفات الرئيسية</option>
                        @foreach($parentCategories as $parent)
                            <option value="{{ $parent->id }}" {{ (string) request('parent_id') === (string) $parent->id ? 'selected' : '' }} class="dark:bg-gray-800">{{ $parent->title }}</option>
                        @endforeach
                    </select>
                </div>
            @else
                <div class="flex items-center rounded-xl bg-blue-50 px-4 text-sm font-bold text-blue-700 dark:bg-blue-500/10 dark:text-blue-300">
                    <i class="fa-solid fa-filter ml-2"></i>
                    {{ $currentParent->title }}
                </div>
            @endunless

            <div class="flex items-center gap-2">
                <button type="submit" class="h-[46px] w-full rounded-xl bg-gray-900 px-4 text-sm font-bold text-white hover:bg-gray-800 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100">تطبيق</button>
                @if(request('search') || request('parent_id'))
                    <a href="{{ route('admin.categories.index') }}" class="flex h-[46px] w-12 items-center justify-center rounded-xl bg-red-50 text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20">
                        <i class="fa-solid fa-xmark"></i>
                    </a>
                @endif
            </div>
        </form>
    </div>

    <div class="admin-card overflow-hidden">
        @if($categories->count())
            <div class="overflow-x-auto">
                <table class="w-full text-right text-sm">
                    <thead>
                        <tr class="border-b border-gray-100 bg-gray-50/80 text-gray-500 dark:border-white/10 dark:bg-white/5 dark:text-gray-400">
                            <th class="px-6 py-4 text-xs font-bold">#</th>
                            <th class="px-6 py-4 text-xs font-bold">عنوان التصنيف</th>
                            <th class="px-6 py-4 text-xs font-bold">التبعيات</th>
                            <th class="px-6 py-4 text-xs font-bold">اللغة</th>
                            <th class="px-6 py-4 text-center text-xs font-bold">المواد</th>
                            <th class="px-6 py-4 text-left text-xs font-bold">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                        @foreach($categories as $category)
                            <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02]">
                                <td class="px-6 py-4">
                                    <span class="inline-flex rounded-lg bg-gray-100 px-2.5 py-1 font-mono text-xs font-bold text-gray-600 dark:bg-white/5 dark:text-gray-400">{{ $category->id }}</span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <span class="flex h-9 w-9 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-300">
                                            <i class="fa-solid {{ $category->children->count() ? 'fa-folder-tree' : 'fa-folder-open' }}"></i>
                                        </span>
                                        <div>
                                            <p class="font-bold text-gray-900 dark:text-white">{{ $category->title }}</p>
                                            @if($category->block_name)
                                                <p class="text-xs text-gray-500 dark:text-gray-400">{{ $category->block_name }}</p>
                                            @endif
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex flex-wrap items-center gap-1.5">
                                        @if($category->parent)
                                            <a href="{{ route('admin.categories.index', ['parent_id' => $category->parent_id]) }}" class="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-bold text-blue-700 hover:bg-blue-100 dark:bg-blue-500/10 dark:text-blue-300 dark:hover:bg-blue-500/20">
                                                {{ $category->parent->title }}
                                            </a>
                                        @endif
                                        @if($category->children->count())
                                            <a href="{{ route('admin.categories.index', ['parent_id' => $category->id]) }}" class="inline-flex items-center rounded-md bg-amber-50 px-2 py-1 text-xs font-bold text-amber-700 hover:bg-amber-100 dark:bg-amber-500/10 dark:text-amber-300 dark:hover:bg-amber-500/20">
                                                {{ $category->children->count() }} تفرع
                                            </a>
                                        @endif
                                        @if(!$category->parent && !$category->children->count())
                                            <span class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-bold text-gray-500 dark:bg-white/5 dark:text-gray-400">بدون تفرعات</span>
                                        @endif
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex rounded-md px-2 py-1 text-[11px] font-bold uppercase {{ $category->language === 'ar' ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-300' : 'bg-blue-50 text-blue-700 dark:bg-blue-500/10 dark:text-blue-300' }}">
                                        {{ $category->language }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    @if($category->items_count > 0)
                                        <a href="{{ route('admin.items.index', ['category_id' => $category->id]) }}" class="inline-flex rounded-full bg-indigo-50 px-2.5 py-1 text-xs font-bold text-indigo-700 hover:bg-indigo-100 dark:bg-indigo-500/20 dark:text-indigo-300 dark:hover:bg-indigo-500/30">{{ $category->items_count }}</a>
                                    @else
                                        <span class="text-xs text-gray-400">-</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-left">
                                    <div class="flex items-center justify-end gap-1.5">
                                        <a href="{{ route('admin.categories.edit', $category->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 ring-1 ring-inset ring-gray-300 transition-all hover:bg-blue-50 hover:text-blue-600 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form action="{{ route('admin.categories.destroy', $category->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذا التصنيف؟');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 ring-1 ring-inset ring-gray-300 transition-all hover:bg-red-50 hover:text-red-600 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            @if($categories->hasPages())
                <div class="border-t border-gray-100 bg-gray-50/50 p-4 dark:border-white/10 dark:bg-white/[0.02]">
                    {{ $categories->withQueryString()->links() }}
                </div>
            @endif
        @else
            <div class="px-6 py-16 text-center">
                <div class="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-gray-50 dark:bg-white/5">
                    <i class="fa-solid fa-folder-open text-3xl text-gray-400"></i>
                </div>
                <h3 class="text-sm font-bold text-gray-900 dark:text-white">لا توجد تصنيفات حالياً</h3>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">ابدأ بإضافة تصنيف جديد لتنظيم المواد العلمية والدعوية.</p>
                <div class="mt-6">
                    <a href="{{ route('admin.categories.create') }}" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                        <i class="fa-solid fa-plus ml-2"></i> إنشاء تصنيف
                    </a>
                </div>
            </div>
        @endif
    </div>
</x-admin-layout>
