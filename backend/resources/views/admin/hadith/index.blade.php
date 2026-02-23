<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">مكتبة الحديث الشريف</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إدارة مجموعات الحديث المستوردة من مكتبة hadith-json</p>
        </div>
        <a href="{{ route('admin.hadith.index') }}"
            class="admin-btn bg-gradient-to-r from-emerald-600 to-teal-600 text-white shadow-lg shadow-emerald-500/30 hover:shadow-emerald-500/50 hover:-translate-y-0.5 transition-all">
            <i class="fa-solid fa-arrows-rotate ml-2"></i> تحديث العرض
        </a>
    </div>

    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-emerald-500 to-teal-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">مجموعات الحديث</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['books_count']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 text-xl text-emerald-600 dark:bg-emerald-900/20 dark:text-emerald-400">
                    <i class="fa-solid fa-books"></i>
                </div>
            </div>
        </div>

        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-blue-500 to-indigo-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">عدد الأبواب</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['chapters_count']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-xl text-blue-600 dark:bg-blue-900/20 dark:text-blue-400">
                    <i class="fa-solid fa-folder-tree"></i>
                </div>
            </div>
        </div>

        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-amber-500 to-orange-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">عدد الأحاديث</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['hadith_count']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-xl text-amber-600 dark:bg-amber-900/20 dark:text-amber-400">
                    <i class="fa-solid fa-book-quran"></i>
                </div>
            </div>
        </div>

        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-purple-500 to-fuchsia-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">الصحيحان متوفران</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['sahih_collections']) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-purple-50 text-xl text-purple-600 dark:bg-purple-900/20 dark:text-purple-400">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="admin-card mb-6 p-5">
        <h3 class="mb-2 text-sm font-black text-gray-900 dark:text-white">
            <i class="fa-solid fa-terminal text-emerald-500"></i>
            أمر الاستيراد
        </h3>
        <p class="mb-2 text-xs text-gray-500 dark:text-gray-400">
            لاستيراد مكتبة الحديث من الملفات المحلية شغّل هذا الأمر من مجلد <span dir="ltr">backend/</span>:
        </p>
        <code dir="ltr" class="block rounded-xl bg-gray-900 px-4 py-3 text-xs text-emerald-300">
            php artisan hadith:import --path="/Users/molood/Downloads/hadith-json-main/db" --truncate
        </code>
    </div>

    <div class="admin-card mb-6 p-2 ring-1 ring-gray-900/5 dark:ring-white/10">
        <form action="{{ route('admin.hadith.index') }}" method="GET" class="flex flex-col sm:flex-row gap-2">
            <div class="relative flex-1 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-magnifying-glass text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث باسم المجموعة أو المؤلف..."
                    class="block w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
            </div>

            <button type="submit" class="flex items-center justify-center h-[46px] rounded-xl bg-gray-900 px-6 text-sm font-semibold text-white shadow-sm hover:bg-gray-800 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100 transition-colors">
                بحث
            </button>

            @if(request('search'))
                <a href="{{ route('admin.hadith.index') }}" class="flex items-center justify-center h-[46px] rounded-xl bg-red-50 px-4 text-sm font-semibold text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20 transition-colors">
                    <i class="fa-solid fa-times"></i>
                </a>
            @endif
        </form>
    </div>

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">المجموعة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">العنوان</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">المؤلف</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الأبواب</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الأحاديث</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($books as $book)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1.5 rounded-lg bg-gray-100 px-2.5 py-1 text-[11px] font-mono font-bold text-gray-600 dark:bg-white/5 dark:text-gray-300">
                                    {{ $book->slug }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="font-bold text-gray-900 dark:text-white">{{ $book->title_ar }}</div>
                                @if($book->title_en)
                                    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1" dir="ltr">{{ $book->title_en }}</div>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <div class="text-sm text-gray-700 dark:text-gray-200">{{ $book->author_ar ?: '-' }}</div>
                                @if($book->author_en)
                                    <div class="text-xs text-gray-500 dark:text-gray-400 mt-1" dir="ltr">{{ $book->author_en }}</div>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center justify-center rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-bold text-blue-700 dark:bg-blue-500/20 dark:text-blue-300">
                                    {{ number_format($book->chapters_count) }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center justify-center rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-bold text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300">
                                    {{ number_format($book->hadiths_count) }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-left">
                                <a href="{{ route('admin.hadith.show', $book) }}"
                                    class="inline-flex items-center rounded-xl bg-white px-3 py-2 text-xs font-bold text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-emerald-50 hover:text-emerald-700 hover:ring-emerald-200 dark:bg-white/5 dark:text-gray-300 dark:ring-white/10 dark:hover:bg-emerald-500/20 dark:hover:text-emerald-300">
                                    <i class="fa-solid fa-eye ml-1"></i>
                                    استعراض
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-6 py-16 text-center">
                                <div class="text-sm font-bold text-gray-600 dark:text-gray-300">لا توجد بيانات حديث مستوردة بعد.</div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($books->hasPages())
            <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                {{ $books->withQueryString()->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
