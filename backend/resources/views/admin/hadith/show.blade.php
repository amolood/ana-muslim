<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <div class="mb-2">
                <a href="{{ route('admin.hadith.index') }}" class="text-sm font-bold text-gray-500 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400">
                    <i class="fa-solid fa-arrow-right ml-1"></i> الرجوع لمكتبة الحديث
                </a>
            </div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">{{ $book->title_ar }}</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400" dir="ltr">{{ $book->title_en }}</p>
        </div>
        <div class="flex items-center gap-2">
            <span class="inline-flex items-center rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700 dark:bg-blue-500/20 dark:text-blue-300">
                الأبواب: {{ number_format($book->total_chapters) }}
            </span>
            <span class="inline-flex items-center rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300">
                الأحاديث: {{ number_format($book->total_hadith) }}
            </span>
        </div>
    </div>

    <div class="admin-card mb-6 p-2 ring-1 ring-gray-900/5 dark:ring-white/10">
        <form action="{{ route('admin.hadith.show', $book) }}" method="GET" class="grid grid-cols-1 gap-2 lg:grid-cols-12">
            <div class="relative lg:col-span-7 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-magnifying-glass text-gray-400 group-focus-within:text-blue-500 transition-colors"></i>
                </div>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث برقم الحديث أو نص عربي/إنجليزي..."
                    class="block w-full rounded-xl border-0 bg-gray-50 py-3 pl-4 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
            </div>

            <div class="relative lg:col-span-3 group">
                <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4">
                    <i class="fa-solid fa-filter text-gray-400"></i>
                </div>
                <select name="chapter" class="block w-full appearance-none rounded-xl border-0 bg-gray-50 py-3 pl-10 pr-11 text-sm text-gray-900 shadow-inner ring-1 ring-inset ring-transparent focus:bg-white focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:bg-white/5 dark:text-white dark:focus:bg-white/10 transition-all">
                    <option value="">كل الأبواب</option>
                    @foreach($chapters as $chapter)
                        <option value="{{ $chapter->source_chapter_id }}" {{ (string) request('chapter') === (string) $chapter->source_chapter_id ? 'selected' : '' }}>
                            {{ $chapter->source_chapter_id }} - {{ $chapter->title_ar ?: 'باب' }}
                        </option>
                    @endforeach
                </select>
                <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
                    <i class="fa-solid fa-chevron-down text-gray-400 text-xs"></i>
                </div>
            </div>

            <button type="submit" class="lg:col-span-1 flex items-center justify-center h-[46px] rounded-xl bg-gray-900 px-4 text-sm font-semibold text-white shadow-sm hover:bg-gray-800 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-100 transition-colors">
                تطبيق
            </button>

            <a href="{{ route('admin.hadith.show', $book) }}" class="lg:col-span-1 flex items-center justify-center h-[46px] rounded-xl bg-red-50 px-4 text-sm font-semibold text-red-600 hover:bg-red-100 dark:bg-red-400/10 dark:text-red-400 dark:hover:bg-red-400/20 transition-colors">
                <i class="fa-solid fa-rotate-left"></i>
            </a>
        </form>
    </div>

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الرقم</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الباب</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">النص العربي</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الترجمة الإنجليزية</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($hadiths as $hadith)
                        @php
                            $chapter = $hadith->chapter;
                            $arabicPreview = trim((string) ($hadith->arabic_text ?? ''));
                            $englishPreview = trim((string) implode(' ', array_filter([$hadith->english_narrator, $hadith->english_text])));
                        @endphp
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors align-top">
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center justify-center rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-bold text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300">
                                    {{ $hadith->hadith_number }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="text-xs font-bold text-blue-700 dark:text-blue-300">
                                    {{ $chapter?->source_chapter_id ?? '-' }}
                                </div>
                                <div class="mt-1 text-xs text-gray-600 dark:text-gray-300 max-w-[240px] leading-relaxed">
                                    {{ $chapter?->title_ar ?: 'باب غير محدد' }}
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <p class="text-xs leading-7 text-gray-700 dark:text-gray-200 line-clamp-5 max-w-[460px]">
                                    {{ $arabicPreview !== '' ? $arabicPreview : '—' }}
                                </p>
                            </td>
                            <td class="px-6 py-4">
                                <p class="text-xs leading-6 text-gray-600 dark:text-gray-300 line-clamp-5 max-w-[420px]" dir="ltr">
                                    {{ $englishPreview !== '' ? $englishPreview : '—' }}
                                </p>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-6 py-16 text-center">
                                <div class="text-sm font-bold text-gray-600 dark:text-gray-300">لا توجد نتائج مطابقة للفلاتر الحالية.</div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($hadiths->hasPages())
            <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                {{ $hadiths->withQueryString()->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
