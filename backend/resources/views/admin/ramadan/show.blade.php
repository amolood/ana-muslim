<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.ramadan.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-emerald-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-emerald-400 transition-colors">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <div>
                <h2 class="text-xl font-black text-gray-800 dark:text-white">جدول مدينة: {{ $cityKey }}</h2>
                <p class="text-xs text-gray-400">{{ $days->total() }} يوم في قاعدة البيانات</p>
            </div>
        </div>
        <a href="{{ route('admin.ramadan.create', ['city_key' => $cityKey]) }}"
            class="admin-btn bg-emerald-600 text-white hover:bg-emerald-700 shadow-lg shadow-emerald-600/20">
            <i class="fa-solid fa-plus ml-2"></i> إضافة يوم
        </a>
    </div>

    @if(session('success'))
        <div class="mb-6 bg-gradient-to-l from-emerald-500/10 to-transparent border-r-4 border-emerald-500 p-4 rounded-xl flex items-center gap-3">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                <i class="fa-solid fa-check"></i>
            </div>
            <p class="text-sm font-bold text-emerald-700 dark:text-emerald-400">{{ session('success') }}</p>
        </div>
    @endif

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 dark:bg-white/5 border-b border-gray-100 dark:border-white/10">
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">التاريخ</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">الهجري</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">السحور</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">الإفطار</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">مدة الصوم</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">الأيام البيض</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">دعاء</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">حديث</th>
                        <th class="px-4 py-3 text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">إجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @foreach($days as $day)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors {{ $day->is_white_day ? 'bg-amber-50/40 dark:bg-amber-500/5' : '' }}">
                            <td class="px-4 py-3">
                                <p class="font-bold text-gray-900 dark:text-white">{{ $day->date->format('d M') }}</p>
                                <p class="text-[11px] text-gray-400">{{ $day->day_name_ar ?? $day->day_name }}</p>
                            </td>
                            <td class="px-4 py-3 text-xs text-gray-500 dark:text-gray-400">{{ $day->hijri_readable_ar ?? $day->hijri_date }}</td>
                            <td class="px-4 py-3">
                                <span class="inline-flex items-center gap-1 rounded-lg bg-blue-50 dark:bg-blue-500/10 px-2 py-1 text-xs font-bold text-blue-700 dark:text-blue-400">
                                    <i class="fa-solid fa-bowl-food text-[10px]"></i> {{ $day->sahur_time }}
                                </span>
                            </td>
                            <td class="px-4 py-3">
                                <span class="inline-flex items-center gap-1 rounded-lg bg-orange-50 dark:bg-orange-500/10 px-2 py-1 text-xs font-bold text-orange-700 dark:text-orange-400">
                                    <i class="fa-solid fa-sun text-[10px]"></i> {{ $day->iftar_time }}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-xs text-gray-500 dark:text-gray-400">{{ $day->fasting_duration_ar ?? $day->fasting_duration }}</td>
                            <td class="px-4 py-3 text-center">
                                @if($day->is_white_day)
                                    <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-amber-100 dark:bg-amber-500/20 text-amber-600 dark:text-amber-400">
                                        <i class="fa-solid fa-star text-[10px]"></i>
                                    </span>
                                @else
                                    <span class="text-gray-300 dark:text-gray-700">—</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 text-center">
                                @if($day->dua_arabic)
                                    <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                                        <i class="fa-solid fa-check text-[10px]"></i>
                                    </span>
                                @else
                                    <span class="text-gray-300 dark:text-gray-700">—</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 text-center">
                                @if($day->hadith_arabic)
                                    <span class="inline-flex h-6 w-6 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                                        <i class="fa-solid fa-check text-[10px]"></i>
                                    </span>
                                @else
                                    <span class="text-gray-300 dark:text-gray-700">—</span>
                                @endif
                            </td>
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-2">
                                    <a href="{{ route('admin.ramadan.edit', $day->id) }}"
                                        class="flex h-8 w-8 items-center justify-center rounded-lg bg-gray-100 text-gray-500 hover:bg-blue-50 hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:bg-blue-500/10 dark:hover:text-blue-400 transition-colors">
                                        <i class="fa-solid fa-pen text-xs"></i>
                                    </a>
                                    <form method="POST" action="{{ route('admin.ramadan.destroy', $day->id) }}"
                                        onsubmit="return confirm('حذف يوم {{ $day->date->format('d M') }}؟')">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="flex h-8 w-8 items-center justify-center rounded-lg bg-gray-100 text-gray-500 hover:bg-red-50 hover:text-red-600 dark:bg-white/5 dark:text-gray-400 dark:hover:bg-red-500/10 dark:hover:text-red-400 transition-colors">
                                            <i class="fa-solid fa-trash text-xs"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        @if($days->hasPages())
            <div class="p-4 border-t border-gray-100 dark:border-white/10">
                {{ $days->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
