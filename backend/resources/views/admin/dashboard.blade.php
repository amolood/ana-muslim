<x-admin-layout>
    @php
        $itemsCount = max(1, (int) $stats['items_count']);
        $categoryCoverage = round(((int) $stats['items_with_categories'] / $itemsCount) * 100, 1);
        $authorCoverage = round(((int) $stats['items_with_authors'] / $itemsCount) * 100, 1);
        $lastContentUpdate = $stats['last_content_update'] ? \Illuminate\Support\Carbon::parse($stats['last_content_update']) : null;
    @endphp

    <style>
        .glass-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.05);
            border-radius: 1.5rem;
        }
        .dark .glass-card {
            background: rgba(17, 24, 39, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 15px 50px -12px rgba(0, 0, 0, 0.5);
        }
        .stat-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 3.5rem;
            height: 3.5rem;
            border-radius: 1rem;
            font-size: 1.25rem;
        }
    </style>

    <!-- Header & Status -->
    <div class="mb-8 flex flex-col items-start justify-between gap-4 md:flex-row md:items-center">
        <div>
            <h1 class="text-3xl font-black tracking-tight text-gray-900 dark:text-white">نظرة عامة على النظام</h1>
            <p class="mt-1 text-sm font-medium text-gray-500 dark:text-gray-400">متابعة إحصائيات المحتوى، الزوار، والأداء الفني للمنصة.</p>
        </div>
        <div class="flex items-center gap-4">
            <div class="flex items-center gap-3 rounded-2xl bg-emerald-50 px-4 py-2 ring-1 ring-emerald-500/10 dark:bg-emerald-500/5 dark:ring-emerald-500/20">
                <span class="flex h-2.5 w-2.5">
                    <span class="absolute inline-flex h-2.5 w-2.5 animate-ping rounded-full bg-emerald-400 opacity-75"></span>
                    <span class="relative inline-flex h-2.5 w-2.5 rounded-full bg-emerald-500"></span>
                </span>
                <span class="text-xs font-bold text-emerald-700 dark:text-emerald-400">النظام نشط الآن</span>
            </div>
        </div>
    </div>

    <!-- KPI Cards Row -->
    <div class="mb-10 grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        <!-- Content Total -->
        <div class="glass-card group p-6 transition-all hover:shadow-2xl hover:shadow-blue-500/10 dark:hover:shadow-blue-500/20">
            <div class="mb-5 flex items-center justify-between">
                <div class="stat-icon bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-400">
                    <i class="fa-solid fa-layer-group"></i>
                </div>
                <div class="text-right">
                    <div class="text-2xl font-black text-gray-900 dark:text-white">{{ number_format($stats['items_count']) }}</div>
                    <div class="text-[11px] font-bold uppercase tracking-wider text-gray-400">إجمالي المواد</div>
                </div>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-full bg-blue-500" style="width: 100%"></div>
            </div>
        </div>

        <!-- Reciters Total -->
        <div class="glass-card group p-6 transition-all hover:shadow-2xl hover:shadow-emerald-500/10 dark:hover:shadow-emerald-500/20">
            <div class="mb-5 flex items-center justify-between">
                <div class="stat-icon bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400">
                    <i class="fa-solid fa-microphone"></i>
                </div>
                <div class="text-right">
                    <div class="text-2xl font-black text-gray-900 dark:text-white">{{ number_format($stats['reciters_count']) }}</div>
                    <div class="text-[11px] font-bold uppercase tracking-wider text-gray-400">القراء المتاحون</div>
                </div>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-full bg-emerald-500" style="width: 100%"></div>
            </div>
        </div>

        <!-- Daily Unique Visitors -->
        <div class="glass-card group p-6 transition-all hover:shadow-2xl hover:shadow-amber-500/10 dark:hover:shadow-amber-500/20">
            <div class="mb-5 flex items-center justify-between">
                <div class="stat-icon bg-amber-50 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400">
                    <i class="fa-solid fa-user-check"></i>
                </div>
                <div class="text-right">
                    <div class="text-2xl font-black text-gray-900 dark:text-white">{{ number_format($stats['unique_today']) }}</div>
                    <div class="text-[11px] font-bold uppercase tracking-wider text-gray-400">زوار نشطون اليوم</div>
                </div>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-full bg-amber-500" style="width: {{ $stats['unique_visitors'] > 0 ? ($stats['unique_today'] / $stats['unique_visitors']) * 100 : 100 }}%"></div>
            </div>
        </div>

        <!-- Total Page Views -->
        <div class="glass-card group p-6 transition-all hover:shadow-2xl hover:shadow-indigo-500/10 dark:hover:shadow-indigo-500/20">
            <div class="mb-5 flex items-center justify-between">
                <div class="stat-icon bg-indigo-50 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400">
                    <i class="fa-solid fa-eye"></i>
                </div>
                <div class="text-right">
                    <div class="text-2xl font-black text-gray-900 dark:text-white">{{ number_format($stats['total_visits']) }}</div>
                    <div class="text-[11px] font-bold uppercase tracking-wider text-gray-400">مشاهدات تراكمية</div>
                </div>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-full bg-indigo-500" style="width: 100%"></div>
            </div>
        </div>
    </div>

    <!-- Main Analytics Section -->
    <div class="mb-10 grid grid-cols-1 gap-8 lg:grid-cols-12">
        <!-- Traffic Chart Area -->
        <div class="glass-card p-8 lg:col-span-8">
            <div class="mb-8 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
                <div>
                    <h3 class="text-lg font-black text-gray-900 dark:text-white">اتجاهات حركة الزوار</h3>
                    <p class="text-xs font-medium text-gray-500 dark:text-gray-400">مقارنة الزيارات اليومية خلال الأسبوع الأخير.</p>
                </div>
                <div class="flex gap-2">
                    <span class="rounded-lg bg-blue-500/10 px-3 py-1 text-[10px] font-bold text-blue-600 dark:text-blue-400">آخر 7 أيام</span>
                </div>
            </div>
            <div class="h-[320px] w-full">
                <canvas id="trafficTrendChart"></canvas>
            </div>
        </div>

        <!-- Distribution Side Panel -->
        <div class="flex flex-col gap-6 lg:col-span-4">
            <!-- Top Countries -->
            <div class="glass-card flex-1 p-6">
                <h3 class="mb-6 text-sm font-black text-gray-900 dark:text-white border-b border-gray-100 pb-3 dark:border-white/5">أعلى الدول زيارة</h3>
                <div class="space-y-4">
                    @forelse($stats['visits_by_country'] as $visit)
                        <div class="flex items-center justify-between group">
                            <div class="flex items-center gap-3">
                                <div class="h-9 w-9 flex items-center justify-center rounded-xl bg-gray-50 text-[10px] font-black text-gray-400 dark:bg-gray-800/50">
                                    {{ strtoupper(substr($visit->country, 0, 2)) }}
                                </div>
                                <span class="text-xs font-bold text-gray-700 dark:text-gray-200">{{ $visit->country }}</span>
                            </div>
                            <div class="text-right">
                                <div class="text-xs font-black text-gray-900 dark:text-white">{{ number_format($visit->count) }}</div>
                                <div class="text-[9px] font-bold text-blue-500">{{ round(($visit->count / max(1, $stats['total_visits'])) * 100, 1) }}%</div>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-4 text-xs text-gray-400">لا توجد بيانات دول متاحة</div>
                    @endforelse
                </div>
            </div>

            <!-- Platform Breakdown -->
            <div class="glass-card p-6">
                <h3 class="mb-6 text-sm font-black text-gray-900 dark:text-white border-b border-gray-100 pb-3 dark:border-white/5">أنظمة التشغيل</h3>
                <div class="space-y-5">
                    @forelse($stats['platform_distribution'] as $platform)
                        @php $share = ($stats['total_visits'] > 0 ? ($platform->count / $stats['total_visits']) * 100 : 0); @endphp
                        <div>
                            <div class="mb-2 flex items-center justify-between text-[11px] font-bold">
                                <span class="text-gray-700 dark:text-gray-300">{{ $platform->os ?: 'غير معروف' }}</span>
                                <span class="text-indigo-500">{{ round($share, 1) }}%</span>
                            </div>
                            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                <div class="h-full bg-indigo-500 transition-all duration-1000" style="width: {{ $share }}%"></div>
                            </div>
                        </div>
                    @empty
                        <p class="text-center text-xs text-gray-400">لا توجد بيانات منصات</p>
                    @endforelse
                </div>
            </div>
        </div>
    </div>

    <!-- Multi-Column Insights Grid -->
    <div class="grid grid-cols-1 gap-8 lg:grid-cols-12">
        <!-- Popular Content Table -->
        <div class="glass-card overflow-hidden lg:col-span-8">
            <div class="border-b border-gray-100 p-6 dark:border-white/5">
                <h3 class="text-lg font-black text-gray-900 dark:text-white">الصفحات الأكثر زيارة</h3>
                <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">عرض الروابط الأكثر تفاعلاً من قبل المستخدمين.</p>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-right">
                    <thead>
                        <tr class="bg-gray-50/50 text-xs font-black uppercase tracking-wider text-gray-400 dark:bg-white/[0.02]">
                            <th class="px-6 py-4">مسار الصفحة</th>
                            <th class="px-6 py-4">التدفق</th>
                            <th class="px-6 py-4 text-left">عدد الزيارات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/5">
                        @foreach($stats['top_visited_pages'] as $page)
                            @php 
                                $path = parse_url($page->url, PHP_URL_PATH) ?: '/';
                                $maxCount = $stats['top_visited_pages']->first()->count ?? 1;
                                $relativeWidth = ($page->count / $maxCount) * 100;
                            @endphp
                            <tr class="transition-colors hover:bg-gray-50/50 dark:hover:bg-white/[0.01]">
                                <td class="px-6 py-4">
                                    <div class="text-xs font-black text-gray-800 dark:text-gray-200">{{ $path }}</div>
                                    <div class="mt-0.5 text-[10px] text-gray-400 truncate max-w-[200px]">{{ $page->url }}</div>
                                </td>
                                <div class="hidden sm:table-cell px-6 py-4">
                                    <div class="w-24 bg-gray-100 dark:bg-gray-800 h-1 rounded-full overflow-hidden">
                                        <div class="bg-blue-500 h-full" style="width: {{ $relativeWidth }}%"></div>
                                    </div>
                                </div>
                                <td class="px-6 py-4 text-left font-black text-blue-600 dark:text-blue-400">
                                    {{ number_format($page->count) }}
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Data Health Scores -->
        <div class="glass-card p-8 lg:col-span-4 flex flex-col">
            <h3 class="mb-8 text-lg font-black text-gray-900 dark:text-white">جودة البيانات</h3>
            <div class="space-y-10 flex-1 flex flex-col justify-center">
                <!-- Category Coverage -->
                <div class="text-center">
                    <div class="relative inline-flex items-center justify-center">
                        <svg class="h-32 w-32 rotate-[-90deg]">
                            <circle cx="64" cy="64" r="58" stroke-width="8" stroke="currentColor" fill="transparent" class="text-gray-100 dark:text-gray-800" />
                            <circle cx="64" cy="64" r="58" stroke-width="8" stroke-dasharray="{{ (2 * 182.2) }}" stroke-dashoffset="{{ (2 * 182.2) * (1 - $categoryCoverage/100) }}" stroke-linecap="round" stroke="currentColor" fill="transparent" class="text-emerald-500" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-2xl font-black text-gray-900 dark:text-white">{{ $categoryCoverage }}%</span>
                            <span class="text-[9px] font-bold uppercase tracking-widest text-gray-400">التصنيفات</span>
                        </div>
                    </div>
                </div>

                <!-- Author Coverage -->
                <div class="text-center">
                    <div class="relative inline-flex items-center justify-center">
                        <svg class="h-32 w-32 rotate-[-90deg]">
                            <circle cx="64" cy="64" r="58" stroke-width="8" stroke="currentColor" fill="transparent" class="text-gray-100 dark:text-gray-800" />
                            <circle cx="64" cy="64" r="58" stroke-width="8" stroke-dasharray="{{ (2 * 182.2) }}" stroke-dashoffset="{{ (2 * 182.2) * (1 - $authorCoverage/100) }}" stroke-linecap="round" stroke="currentColor" fill="transparent" class="text-amber-500" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-2xl font-black text-gray-900 dark:text-white">{{ $authorCoverage }}%</span>
                            <span class="text-[9px] font-bold uppercase tracking-widest text-gray-400">المؤلفون</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer Insights -->
    <div class="mt-8 grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
        <!-- Technical Sync -->
        <div class="glass-card p-6">
            <h4 class="mb-4 text-xs font-black uppercase text-gray-400">صحة الاستيراد (API)</h4>
            <div class="flex items-center justify-between">
                <div>
                    <div class="text-xl font-black text-gray-800 dark:text-white">{{ $stats['api_health']['success_rate'] }}%</div>
                    <div class="text-[10px] text-gray-400">نسبة نجاح الربط مع Islamhouse</div>
                </div>
                <div class="h-10 w-10 flex items-center justify-center rounded-xl bg-indigo-50 text-indigo-500 dark:bg-indigo-500/10">
                    <i class="fa-solid fa-cloud-arrow-down"></i>
                </div>
            </div>
        </div>

        <!-- Metadata Overview -->
        <div class="glass-card p-6">
            <h4 class="mb-4 text-xs font-black uppercase text-gray-400">بيانات المساندة</h4>
            <div class="flex flex-wrap gap-2">
                @foreach($stats['metadata_stats']->take(4) as $row)
                    <span class="inline-flex items-center rounded-lg bg-gray-50 px-2 py-1 text-[9px] font-black text-gray-600 dark:bg-white/5 dark:text-gray-400">
                        {{ $row['label'] }}: {{ number_format($row['count']) }}
                    </span>
                @endforeach
            </div>
        </div>

        <!-- System Updates -->
        <div class="glass-card p-6">
            <h4 class="mb-4 text-xs font-black uppercase text-gray-400">حالة التحديث</h4>
            @if($lastContentUpdate)
                <div class="flex items-center gap-3">
                    <div class="stat-icon h-10 w-10 bg-gray-50 text-gray-400 dark:bg-gray-800/50">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                    </div>
                    <div>
                        <div class="text-[11px] font-black text-gray-800 dark:text-white">آخر تعديل للمحتوى</div>
                        <div class="text-[10px] text-gray-400">{{ $lastContentUpdate->diffForHumans() }}</div>
                    </div>
                </div>
            @endif
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const trendCtx = document.getElementById('trafficTrendChart').getContext('2d');
            const trendData = @json($stats['visits_last_7_days']);

            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: trendData.map(d => d.date),
                    datasets: [{
                        label: 'عدد الزيارات',
                        data: trendData.map(d => d.count),
                        borderColor: '#3b82f6',
                        backgroundColor: 'rgba(59, 130, 246, 0.05)',
                        fill: true,
                        tension: 0.4,
                        borderWidth: 4,
                        pointRadius: 6,
                        pointHoverRadius: 9,
                        pointBackgroundColor: '#3b82f6',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(0,0,0,0.03)', drawBorder: false },
                            ticks: { font: { size: 10, weight: '600' }, color: '#94a3b8' }
                        },
                        x: {
                            grid: { display: false },
                            ticks: { font: { size: 10, weight: '600' }, color: '#94a3b8' }
                        }
                    }
                }
            });
        });
    </script>
</x-admin-layout>
