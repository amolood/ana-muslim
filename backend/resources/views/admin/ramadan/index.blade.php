<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">جداول رمضان</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إدارة جداول الإمساك والإفطار حسب المدن</p>
        </div>
        <div class="flex items-center gap-3">
            <span class="inline-flex items-center gap-2 rounded-xl bg-emerald-50 dark:bg-emerald-500/10 px-4 py-2 text-sm font-bold text-emerald-700 dark:text-emerald-400">
                <i class="fa-solid fa-database text-xs"></i>
                {{ number_format($totalRows) }} سجل إجمالي
            </span>
            <a href="{{ route('admin.ramadan.create') }}"
                class="admin-btn bg-emerald-600 text-white hover:bg-emerald-700 shadow-lg shadow-emerald-600/20">
                <i class="fa-solid fa-plus ml-2"></i> إضافة مدينة جديدة
            </a>
        </div>
    </div>

    @if(session('success'))
        <div class="mb-6 bg-gradient-to-l from-emerald-500/10 to-transparent border-r-4 border-emerald-500 p-4 rounded-xl flex items-center gap-3">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                <i class="fa-solid fa-check"></i>
            </div>
            <p class="text-sm font-bold text-emerald-700 dark:text-emerald-400">{{ session('success') }}</p>
        </div>
    @endif

    @if($cities->isEmpty())
        <div class="admin-card p-12 text-center">
            <div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-100 dark:bg-white/5">
                <i class="fa-solid fa-moon text-2xl text-gray-400"></i>
            </div>
            <p class="text-base font-bold text-gray-700 dark:text-gray-300">لا توجد بيانات رمضان</p>
            <p class="mt-1 text-sm text-gray-400">يمكنك استيراد الجداول عبر Artisan: <code class="rounded bg-gray-100 dark:bg-white/5 px-1.5 py-0.5 text-xs">import:ramadan-schedule</code></p>
        </div>
    @else
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            @foreach($cities as $city)
                <div class="admin-card p-5 flex flex-col gap-4">
                    {{-- Header --}}
                    <div class="flex items-start justify-between gap-3">
                        <div class="flex items-center gap-3">
                            <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-50 dark:bg-emerald-500/10">
                                <i class="fa-solid fa-moon text-emerald-600 dark:text-emerald-400"></i>
                            </div>
                            <div>
                                <p class="text-sm font-black text-gray-900 dark:text-white">{{ $city->city_key }}</p>
                                <p class="text-xs text-gray-400">
                                    {{ \Carbon\Carbon::parse($city->start_date)->format('d M') }}
                                    &ndash;
                                    {{ \Carbon\Carbon::parse($city->end_date)->format('d M Y') }}
                                </p>
                            </div>
                        </div>
                        {{-- Delete city --}}
                        <form method="POST" action="{{ route('admin.ramadan.city.destroy', $city->city_key) }}"
                            onsubmit="return confirm('حذف كامل جدول مدينة {{ $city->city_key }}؟ لا يمكن التراجع.')">
                            @csrf @method('DELETE')
                            <button type="submit" class="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-red-50 hover:text-red-500 dark:hover:bg-red-500/10 transition-colors">
                                <i class="fa-solid fa-trash text-xs"></i>
                            </button>
                        </form>
                    </div>

                    {{-- Stats row --}}
                    <div class="grid grid-cols-3 gap-2 text-center">
                        <div class="rounded-lg bg-gray-50 dark:bg-white/5 px-2 py-2">
                            <p class="text-lg font-black text-gray-900 dark:text-white">{{ $city->days_count }}</p>
                            <p class="text-[10px] text-gray-400">يوم</p>
                        </div>
                        <div class="rounded-lg bg-gray-50 dark:bg-white/5 px-2 py-2">
                            <p class="text-lg font-black text-amber-500">{{ $city->white_days_count }}</p>
                            <p class="text-[10px] text-gray-400">أيام بيض</p>
                        </div>
                        <div class="rounded-lg bg-gray-50 dark:bg-white/5 px-2 py-2">
                            <p class="text-lg font-black text-blue-500">{{ $city->days_count - $city->white_days_count }}</p>
                            <p class="text-[10px] text-gray-400">عادية</p>
                        </div>
                    </div>

                    <a href="{{ route('admin.ramadan.show', $city->city_key) }}"
                        class="admin-btn bg-emerald-600 text-white hover:bg-emerald-700 justify-center text-center">
                        <i class="fa-solid fa-table-list ml-2 text-xs"></i> عرض الجدول
                    </a>
                </div>
            @endforeach
        </div>
    @endif
</x-admin-layout>
