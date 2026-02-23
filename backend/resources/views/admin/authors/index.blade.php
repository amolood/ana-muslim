<x-admin-layout>
    <!-- Header Section -->
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إدارة المؤلفين والقراء</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">قائمة الشيوخ، الدعاة، والقراء المرتبطين بالمواد العلمية</p>
        </div>
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.authors.create') }}" class="admin-btn bg-gradient-to-r from-amber-500 to-orange-500 text-white shadow-lg shadow-amber-500/30 hover:shadow-amber-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-user-plus ml-2"></i> إضافة مؤلف جديد
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
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <!-- Stat Card 1: Total Authors -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي المؤلفين</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total_authors'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-xl text-amber-600 group-hover:scale-110 transition-transform dark:bg-amber-900/20 dark:text-amber-400">
                    <i class="fa-solid fa-users"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                كافة الأشخاص المسجلين كمؤلفين بالمنصة
            </div>
        </div>

        <!-- Stat Card 2: Active Authors (With Items) -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-emerald-500 to-teal-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">مؤلفون نشطون (بمواد)</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['authors_with_items'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-xl text-emerald-600 group-hover:scale-110 transition-transform dark:bg-emerald-900/20 dark:text-emerald-400">
                    <i class="fa-solid fa-microphone-lines"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                مؤلفون يمتلكون مواد معروضة في النظام
            </div>
        </div>

        <!-- Stat Card 3: Inactive Authors -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-rose-500 to-pink-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">مؤلفون غير مستخدمين</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['authors_without_items'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-rose-50 text-xl text-rose-600 group-hover:scale-110 transition-transform dark:bg-rose-900/20 dark:text-rose-400">
                    <i class="fa-solid fa-ghost"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                مسجلون ولكن ليس لديهم أية مواد مرتبطة
            </div>
        </div>
    </div>

    <!-- Search Area -->
    <div class="admin-card mb-6 p-2 ring-1 ring-gray-900/5 dark:ring-white/10">
        <form action="{{ route('admin.authors.index') }}" method="GET" class="flex flex-col sm:flex-row gap-2">
            <div class="relative flex-1 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-magnifying-glass text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث باسم المؤلف، القارئ، أو الوصف..." 
                    class="block w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
            </div>

            <button type="submit" class="flex items-center justify-center h-[46px] rounded-xl bg-gray-900 px-6 text-sm font-semibold text-white shadow-sm hover:bg-gray-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-900 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100 transition-colors">
                فلترة النتائج
            </button>

            @if(request()->has('search') && request('search') !== '')
                <a href="{{ route('admin.authors.index') }}" class="flex items-center justify-center h-[46px] rounded-xl bg-red-50 px-4 text-sm font-semibold text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20 transition-colors tooltip" title="إلغاء البحث">
                    <i class="fa-solid fa-times"></i>
                </a>
            @endif
        </form>
    </div>

    <!-- Main Table -->
    <div class="admin-card overflow-hidden">
        @if($authors->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full text-right text-sm border-collapse">
                    <thead>
                        <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider w-20"># ID</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">اسم المؤلف / التوصيف</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider w-32">النوع</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الوصف المختصر</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left w-32">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                        @foreach($authors as $index => $author)
                            <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                                <!-- ID Column -->
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center justify-center rounded-lg bg-gray-100 px-2.5 py-1 text-[11px] font-mono font-bold text-gray-600 dark:bg-white/5 dark:text-gray-400">
                                        {{ $author->id }}
                                    </span>
                                </td>
                                
                                <!-- Author Name & Avatar -->
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-4">
                                        @php
                                            $words = explode(' ', trim($author->title));
                                            $initials = mb_substr($words[0], 0, 1, 'UTF-8');
                                            if (isset($words[1])) {
                                                $initials .= ' ' . mb_substr($words[1], 0, 1, 'UTF-8');
                                            }
                                            $colors = [
                                                'bg-rose-100 text-rose-700 dark:bg-rose-900/50 dark:text-rose-300 ring-rose-50 dark:ring-rose-900/20',
                                                'bg-purple-100 text-purple-700 dark:bg-purple-900/50 dark:text-purple-300 ring-purple-50 dark:ring-purple-900/20',
                                                'bg-blue-100 text-blue-700 dark:bg-blue-900/50 dark:text-blue-300 ring-blue-50 dark:ring-blue-900/20',
                                                'bg-teal-100 text-teal-700 dark:bg-teal-900/50 dark:text-teal-300 ring-teal-50 dark:ring-teal-900/20'
                                            ];
                                            $colorClass = $colors[$index % 4];
                                        @endphp
                                        <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full ring-4 {{ $colorClass }} font-black text-lg shadow-sm">
                                            {{ $initials }}
                                        </div>
                                        <div>
                                            <div class="font-bold text-gray-900 dark:text-white mb-0.5 text-base">
                                                {{ $author->title }}
                                            </div>
                                            @if($author->kind)
                                                <div class="text-xs text-gray-500 dark:text-gray-400">
                                                    {{ $author->kind }}
                                                </div>
                                            @endif
                                        </div>
                                    </div>
                                </td>
                                
                                <!-- Type Badge -->
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1.5 rounded-lg bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-600 ring-1 ring-inset ring-amber-600/10 dark:bg-amber-500/10 dark:text-amber-400 dark:ring-amber-500/20">
                                        <i class="fa-solid fa-user-tag text-[10px]"></i>
                                        {{ $author->type ?? 'غير محدد' }}
                                    </span>
                                </td>
                                
                                <!-- Description -->
                                <td class="px-6 py-4">
                                    @if($author->description)
                                        <p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-2 max-w-sm leading-relaxed" title="{{ $author->description }}">
                                            {{ $author->description }}
                                        </p>
                                    @else
                                        <span class="inline-flex items-center gap-1.5 rounded bg-gray-50 px-2 py-0.5 text-[11px] font-medium text-gray-500 dark:bg-white/5 dark:text-gray-400">
                                            لا يوجد تفاصيل
                                        </span>
                                    @endif
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-4 text-left">
                                    <div class="flex items-center justify-end gap-1.5 opacity-100 lg:opacity-60 xl:opacity-100 group-hover:opacity-100 transition-opacity">
                                        <a href="{{ route('admin.authors.edit', $author->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:ring-blue-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400 dark:hover:ring-transparent transition-all" title="تعديل بيانات المؤلف">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form action="{{ route('admin.authors.destroy', $author->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذا المؤلف؟ سيتم إزالة ارتباطه بجميع المواد بشكل نهائي.');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-red-50 hover:text-red-600 hover:ring-red-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400 dark:hover:ring-transparent transition-all" title="حذف المؤلف">
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
            
            @if($authors->hasPages())
                <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                    {{ $authors->withQueryString()->links() }}
                </div>
            @endif

        @else
            <!-- Handled Empty State (Matches other index pages without breaking tables) -->
            <div class="px-6 py-16 text-center">
                <div class="flex flex-col items-center justify-center">
                    <div class="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-amber-50 dark:bg-amber-900/20">
                        <i class="fa-solid fa-user-ninja text-3xl text-amber-500 dark:text-amber-400"></i>
                    </div>
                    <h3 class="mt-2 text-sm font-bold text-gray-900 dark:text-white">لا يوجد مؤلفون حالياً</h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">لم يتم العثور على أي مؤلفين أو قراء، أو ربما لم تتم إضافتهم بعد.</p>
                    <div class="mt-6">
                        <a href="{{ route('admin.authors.create') }}" class="admin-btn bg-amber-500 text-white hover:bg-amber-600">
                            <i class="fa-solid fa-user-plus ml-2"></i> إضافة مؤلف / قارئ
                        </a>
                    </div>
                </div>
            </div>
        @endif
    </div>
</x-admin-layout>
