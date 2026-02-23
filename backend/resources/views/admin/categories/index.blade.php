<x-admin-layout>
    <!-- Header Section -->
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            @if($currentParent)
                <div class="flex items-center gap-2 mb-2">
                    <a href="{{ route('admin.categories.index') }}" class="text-sm font-bold text-gray-500 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors tooltip" title="العودة للصفحة الرئيسية للتصنيفات">
                        <i class="fa-solid fa-home"></i> الأقسام الرئيسية
                    </a>
                    @if($currentParent->parent)
                        <i class="fa-solid fa-chevron-left text-[10px] text-gray-400"></i>
                        <a href="{{ route('admin.categories.index', ['parent_id' => $currentParent->parent_id]) }}" class="text-sm font-bold text-gray-500 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors tooltip" title="العودة للإطار السابق">
                            {{ $currentParent->parent->title }}
                        </a>
                    @endif
                    <i class="fa-solid fa-chevron-left text-[10px] text-gray-400"></i>
                    <span class="text-sm font-bold text-blue-600 dark:text-blue-400">{{ $currentParent->title }}</span>
                </div>
                <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">تصنيفات فرعية: {{ $currentParent->title }}</h2>
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إدارة الأقسام المندرجة والتفرعات المرتبطة</p>
            @else
                <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إدارة التصنيفات (الأقسام الرئيسية)</h2>
                <p class="text-sm font-medium text-gray-500 dark:text-gray-400">الهيكل التنظيمي والشجرة التصنيفية لمحتوى المنصة</p>
            @endif
        </div>
        <div class="flex items-center gap-3">
            @if($currentParent)
            <a href="{{ route('admin.categories.index') }}" class="admin-btn bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/5 dark:text-white dark:ring-transparent dark:hover:bg-white/10 transition-all">
                <i class="fa-solid fa-arrow-right ml-2"></i> رجوع للرئيسية
            </a>
            @endif
            <a href="{{ route('admin.categories.create') }}" class="admin-btn bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-plus ml-2"></i> إضافة تصنيف جديد
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

    @if($errors->any())
        <div class="mb-6 bg-gradient-to-l from-red-500/10 to-transparent border-r-4 border-red-500 p-4 rounded-xl flex flex-col gap-2 backdrop-blur-sm">
            @foreach($errors->all() as $error)
                <div class="flex items-center gap-3 text-sm font-bold text-red-700 dark:text-red-400"><i class="fa-solid fa-circle-exclamation"></i> {{ $error }}</div>
            @endforeach
        </div>
    @endif

    <!-- 📊 Statistics Cards Grid -->
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Stat Card 1: Total Categories -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-blue-500 to-indigo-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي التصنيفات</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_categories'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-xl text-blue-600 group-hover:scale-110 transition-transform dark:bg-blue-900/20 dark:text-blue-400">
                    <i class="fa-solid fa-folder-tree"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                تشمل الرئيسية والفرعية
            </div>
        </div>

        <!-- Stat Card 2: Root Categories -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-emerald-500 to-teal-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">أقسام رئيسية</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['root_categories'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-xl text-emerald-600 group-hover:scale-110 transition-transform dark:bg-emerald-900/20 dark:text-emerald-400">
                    <i class="fa-solid fa-layer-group"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                لا ترتبط بتصنيف أب
            </div>
        </div>

        <!-- Stat Card 3: Sub Categories -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">أقسام فرعية</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['sub_categories'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-xl text-amber-600 group-hover:scale-110 transition-transform dark:bg-amber-900/20 dark:text-amber-400">
                    <i class="fa-solid fa-diagram-project"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                متفرعة من أقسام أخرى
            </div>
        </div>

        <!-- Stat Card 4: Total Items Associated -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-purple-500 to-pink-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي المواد المربوطة</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_items_in_categories'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-purple-50 text-xl text-purple-600 group-hover:scale-110 transition-transform dark:bg-purple-900/20 dark:text-purple-400">
                    <i class="fa-solid fa-photo-film"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                المواد المندرجة تحت التصنيفات
            </div>
        </div>
    </div>

    <!-- Search & Filter Area -->
    <div class="admin-card mb-6 p-2 ring-1 ring-gray-900/5 dark:ring-white/10">
        <form action="{{ route('admin.categories.index') }}" method="GET" class="flex flex-col sm:flex-row gap-2">
            <!-- Search bar -->
            <div class="relative flex-1 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-magnifying-glass text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث باسم التصنيف..." 
                    class="block w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
            </div>

            <!-- Parent Filter -->
            <div class="relative w-full sm:w-64 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-filter text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <select name="parent_id" class="block w-full appearance-none rounded-xl border-0 bg-gray-50 py-3 pl-10 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
                    <option value="">جميع الأقسام الرئيسية</option>
                    @foreach($parentCategories as $parent)
                        <option value="{{ $parent->id }}" {{ request('parent_id') == $parent->id ? 'selected' : '' }} class="dark:bg-gray-800">
                            {{ $parent->title }}
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

            @if(request()->has('search') || request()->has('parent_id'))
                <a href="{{ route('admin.categories.index') }}" class="flex items-center justify-center h-[46px] rounded-xl bg-red-50 px-4 text-sm font-semibold text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20 transition-colors tooltip" title="إلغاء جميع الفلاتر">
                    <i class="fa-solid fa-times"></i>
                </a>
            @endif
        </form>
    </div>

    <!-- Main Table -->
    <div class="admin-card overflow-hidden">
        @if($categories->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full text-right text-sm border-collapse" id="categoriesTable">
                    <thead>
                        <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider w-20"># ID</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">عنوان التصنيف</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">التفرعات / المستوى الأعلى</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">اللغة</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-center">المواد</td>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                        @foreach($categories as $category)
                            <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center justify-center rounded-lg bg-gray-100 px-2.5 py-1 text-[11px] font-mono font-bold text-gray-600 dark:bg-white/5 dark:text-gray-400">
                                        {{ $category->id }}
                                    </span>
                                </td>
                                
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-indigo-50 to-blue-50 text-indigo-600 shadow-sm ring-1 ring-indigo-100 dark:from-indigo-900/20 dark:to-blue-900/20 dark:text-indigo-400 dark:ring-indigo-900/30">
                                            <i class="fa-solid {{ $category->children->count() > 0 ? 'fa-folder-tree text-sm' : 'fa-folder-open text-xs' }}"></i>
                                        </div>
                                        <div class="font-bold text-gray-900 dark:text-white line-clamp-1" title="{{ $category->title }}">
                                            {{ $category->title }}
                                        </div>
                                    </div>
                                </td>
                                
                                <td class="px-6 py-4">
                                    <div class="flex flex-col items-start gap-2">
                                        @if($category->parent)
                                            <div class="inline-flex items-center gap-1.5 rounded-md bg-blue-50 pl-2 pr-1.5 py-1 text-xs font-medium text-blue-700 dark:bg-blue-500/10 dark:text-blue-400 tooltip" title="التصنيف الأب: {{ $category->parent->title }}">
                                                <i class="fa-solid fa-level-up-alt rotate-90 text-[10px] opacity-70"></i>
                                                <a href="{{ route('admin.categories.index', ['parent_id' => $category->parent_id]) }}" class="truncate max-w-[120px] hover:underline">{{ $category->parent->title }}</a>
                                            </div>
                                        @endif
                                        
                                        @if($category->children->count() > 0)
                                            <a href="{{ route('admin.categories.index', ['parent_id' => $category->id]) }}" class="inline-flex items-center gap-1.5 rounded-md bg-amber-50 px-2 py-1 text-xs font-bold text-amber-700 hover:bg-amber-100 dark:bg-amber-500/10 dark:text-amber-400 dark:hover:bg-amber-500/20 transition-all ring-1 ring-inset ring-amber-500/20 tooltip" title="استعراض الأقسام الفرعية">
                                                <i class="fa-solid fa-diagram-project"></i>
                                                {{ $category->children->count() }} تفرعات
                                            </a>
                                        @endif
                                        
                                        @if(!$category->parent && $category->children->count() === 0)
                                            <span class="inline-flex items-center gap-1.5 rounded-md bg-gray-50 px-2 py-1 text-[11px] font-bold text-gray-500 dark:bg-white/5 dark:text-gray-400">
                                                <i class="fa-solid fa-minus text-[10px] opacity-50"></i> قسم مسطح
                                            </span>
                                        @endif
                                    </div>
                                </td>
                                
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center justify-center rounded-md bg-gray-50 px-2 py-1 text-[10px] font-bold uppercase tracking-widest text-gray-500 ring-1 ring-inset ring-gray-500/10 dark:bg-white/5 dark:text-gray-400 dark:ring-white/10 border-b-2 {{ $category->language === 'ar' ? 'border-b-emerald-500' : 'border-b-blue-500' }}">
                                        {{ $category->language }}
                                    </span>
                                </td>
                                
                                <td class="px-6 py-4 text-center">
                                    @if($category->items_count > 0)
                                        <a href="{{ route('admin.items.index', ['category_id' => $category->id]) }}" class="inline-flex items-center justify-center rounded-full bg-indigo-50 px-2.5 py-0.5 text-xs font-bold text-indigo-700 hover:bg-indigo-100 hover:scale-110 dark:bg-indigo-500/20 dark:text-indigo-300 dark:hover:bg-indigo-500/40 ring-1 ring-inset ring-indigo-600/20 transition-all tooltip" title="استعراض المواد المرتبطة بهذا التصنيف">
                                            {{ $category->items_count }}
                                        </a>
                                    @else
                                        <span class="text-xs text-gray-400">-</span>
                                    @endif
                                </td>
                                
                                <td class="px-6 py-4 text-left">
                                    <div class="flex items-center justify-end gap-1.5 opacity-100 lg:opacity-60 xl:opacity-100 group-hover:opacity-100 transition-opacity">
                                        <a href="{{ route('admin.categories.edit', $category->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:ring-blue-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400 dark:hover:ring-transparent transition-all" title="تعديل التصنيف">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form action="{{ route('admin.categories.destroy', $category->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذا التصنيف؟');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-red-50 hover:text-red-600 hover:ring-red-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400 dark:hover:ring-transparent transition-all" title="حذف التصنيف">
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
                <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                    {{ $categories->withQueryString()->links() }}
                </div>
            @endif
        @else
            <!-- Handled Empty State Without Rebuilding DOM/Colspans for DataTables compliance -->
            <div class="px-6 py-16 text-center">
                <div class="flex flex-col items-center justify-center">
                    <div class="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-gray-50 dark:bg-white/5">
                        <i class="fa-solid fa-folder-open text-3xl text-gray-400"></i>
                    </div>
                    <h3 class="mt-2 text-sm font-bold text-gray-900 dark:text-white">لا توجد تصنيفات حالياً</h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">لم يتم العثور على أي تصنيفات تطابق بحثك، أو لم يتم إضافة تصنيفات بعد.</p>
                    <div class="mt-6">
                        <a href="{{ route('admin.categories.create') }}" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                            <i class="fa-solid fa-plus ml-2"></i> إنشاء تصنيف جديد
                        </a>
                    </div>
                </div>
            </div>
        @endif
    </div>
</x-admin-layout>
