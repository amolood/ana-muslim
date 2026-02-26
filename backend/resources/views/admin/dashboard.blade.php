<x-admin-layout>
    @php
        $itemsCount = max(1, (int) $stats['items_count']);
        $categoryCoverage = round(((int) $stats['items_with_categories'] / $itemsCount) * 100, 1);
        $authorCoverage = round(((int) $stats['items_with_authors'] / $itemsCount) * 100, 1);
        $lastContentUpdate = $stats['last_content_update'] ? \Illuminate\Support\Carbon::parse($stats['last_content_update']) : null;

        $kpiCards = [
            ['label' => 'إجمالي المواد', 'value' => $stats['items_count'], 'icon' => 'fa-layer-group', 'color' => 'blue', 'sub' => $stats['categories_count'] . ' تصنيف'],
            ['label' => 'القراء المتاحون', 'value' => $stats['reciters_count'], 'icon' => 'fa-microphone', 'color' => 'emerald', 'sub' => $stats['authors_count'] . ' مؤلف'],
            ['label' => 'زوار اليوم', 'value' => $stats['unique_today'], 'icon' => 'fa-user-check', 'color' => 'amber', 'sub' => number_format($stats['visits_today']) . ' مشاهدة'],
            ['label' => 'مشاهدات تراكمية', 'value' => $stats['total_visits'], 'icon' => 'fa-eye', 'color' => 'violet', 'sub' => number_format($stats['unique_visitors']) . ' زائر فريد'],
        ];

        $colorMap = [
            'blue' => ['bg' => 'bg-blue-500/10 dark:bg-blue-500/15', 'text' => 'text-blue-600 dark:text-blue-400', 'ring' => 'ring-blue-500/20', 'gradient' => 'from-blue-500 to-blue-600'],
            'emerald' => ['bg' => 'bg-emerald-500/10 dark:bg-emerald-500/15', 'text' => 'text-emerald-600 dark:text-emerald-400', 'ring' => 'ring-emerald-500/20', 'gradient' => 'from-emerald-500 to-emerald-600'],
            'amber' => ['bg' => 'bg-amber-500/10 dark:bg-amber-500/15', 'text' => 'text-amber-600 dark:text-amber-400', 'ring' => 'ring-amber-500/20', 'gradient' => 'from-amber-500 to-amber-600'],
            'violet' => ['bg' => 'bg-violet-500/10 dark:bg-violet-500/15', 'text' => 'text-violet-600 dark:text-violet-400', 'ring' => 'ring-violet-500/20', 'gradient' => 'from-violet-500 to-violet-600'],
        ];
    @endphp

    <style>
        .dash-card {
            background: rgba(255,255,255,0.85);
            backdrop-filter: blur(20px) saturate(180%);
            border: 1px solid rgba(255,255,255,0.5);
            border-radius: 1.25rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .dash-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 50px -15px rgba(0,0,0,0.08);
        }
        .dark .dash-card {
            background: rgba(17,24,39,0.75);
            border: 1px solid rgba(255,255,255,0.06);
        }
        .dark .dash-card:hover {
            box-shadow: 0 20px 50px -15px rgba(0,0,0,0.4);
        }
        .kpi-card {
            position: relative;
            overflow: hidden;
        }
        .kpi-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            filter: blur(40px);
            opacity: 0.15;
            transition: opacity 0.3s;
        }
        .kpi-card:hover::before { opacity: 0.25; }
        .kpi-blue::before { background: #3b82f6; }
        .kpi-emerald::before { background: #10b981; }
        .kpi-amber::before { background: #f59e0b; }
        .kpi-violet::before { background: #8b5cf6; }

        .counter { font-variant-numeric: tabular-nums; }

        .chart-container { position: relative; }
        .chart-container canvas { border-radius: 0.75rem; }

        .progress-ring { transition: stroke-dashoffset 1s cubic-bezier(0.4, 0, 0.2, 1); }

        .table-row-hover:hover { background: rgba(59,130,246,0.03); }
        .dark .table-row-hover:hover { background: rgba(59,130,246,0.05); }

        @keyframes countUp {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-count { animation: countUp 0.6s ease-out forwards; }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(12px); }
            to { opacity: 1; transform: translateX(0); }
        }
        .animate-slide { animation: slideIn 0.5s ease-out forwards; }
    </style>

    {{-- Page Header --}}
    <div class="mb-8 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
        <div>
            <h1 class="text-2xl font-black tracking-tight text-gray-900 dark:text-white sm:text-3xl">لوحة التحكم</h1>
            <p class="mt-1.5 text-sm text-gray-500 dark:text-gray-400">مرحباً <span class="font-bold text-gray-700 dark:text-gray-200">{{ Auth::user()->name ?? 'المدير' }}</span> — إليك ملخص النظام الآن</p>
        </div>
        <div class="flex items-center gap-3">
            <div class="flex items-center gap-2.5 rounded-full bg-emerald-50 px-4 py-2 ring-1 ring-emerald-500/15 dark:bg-emerald-500/10 dark:ring-emerald-500/20">
                <span class="relative flex h-2 w-2">
                    <span class="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
                    <span class="relative inline-flex h-2 w-2 rounded-full bg-emerald-500"></span>
                </span>
                <span class="text-xs font-bold text-emerald-700 dark:text-emerald-400">نشط</span>
            </div>
            @if($lastContentUpdate)
                <div class="hidden items-center gap-2 rounded-full bg-gray-50 px-4 py-2 text-xs text-gray-500 ring-1 ring-gray-200/50 dark:bg-gray-800/50 dark:text-gray-400 dark:ring-gray-700/50 sm:flex">
                    <i class="fa-solid fa-clock text-[10px]"></i>
                    آخر تحديث: {{ $lastContentUpdate->diffForHumans() }}
                </div>
            @endif
        </div>
    </div>

    {{-- KPI Cards --}}
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        @foreach($kpiCards as $i => $card)
            @php $c = $colorMap[$card['color']]; @endphp
            <div class="dash-card kpi-card kpi-{{ $card['color'] }} p-5 animate-slide" style="animation-delay: {{ $i * 80 }}ms">
                <div class="flex items-start justify-between">
                    <div class="flex h-12 w-12 items-center justify-center rounded-2xl {{ $c['bg'] }} ring-1 {{ $c['ring'] }}">
                        <i class="fa-solid {{ $card['icon'] }} text-lg {{ $c['text'] }}"></i>
                    </div>
                    <div class="text-left">
                        <div class="counter text-3xl font-black text-gray-900 dark:text-white animate-count">
                            {{ number_format($card['value']) }}
                        </div>
                    </div>
                </div>
                <div class="mt-4 flex items-center justify-between">
                    <span class="text-[11px] font-bold uppercase tracking-widest text-gray-400 dark:text-gray-500">{{ $card['label'] }}</span>
                    <span class="text-[11px] font-medium {{ $c['text'] }}">{{ $card['sub'] }}</span>
                </div>
            </div>
        @endforeach
    </div>

    {{-- Main Analytics Row --}}
    <div class="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-12">
        {{-- Traffic Chart --}}
        <div class="dash-card p-6 lg:col-span-8">
            <div class="mb-6 flex items-center justify-between">
                <div>
                    <h3 class="text-base font-black text-gray-900 dark:text-white">حركة الزوار</h3>
                    <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">آخر 7 أيام</p>
                </div>
                <div class="flex gap-3 text-[10px] font-bold">
                    <span class="flex items-center gap-1.5 text-blue-500"><span class="h-2 w-2 rounded-full bg-blue-500"></span> الزيارات</span>
                </div>
            </div>
            <div class="chart-container h-[280px] w-full sm:h-[320px]">
                <canvas id="trafficTrendChart"></canvas>
            </div>
        </div>

        {{-- Side Panels --}}
        <div class="flex flex-col gap-6 lg:col-span-4">
            {{-- Top Countries --}}
            <div class="dash-card flex-1 p-5">
                <div class="mb-5 flex items-center justify-between">
                    <h3 class="text-sm font-black text-gray-900 dark:text-white">أعلى الدول</h3>
                    <span class="text-[10px] font-medium text-gray-400">{{ $stats['visits_by_country']->count() }} دولة</span>
                </div>
                <div class="space-y-3">
                    @forelse($stats['visits_by_country'] as $index => $visit)
                        @php $pct = round(($visit->count / max(1, $stats['total_visits'])) * 100, 1); @endphp
                        <div class="group flex items-center gap-3 rounded-xl px-3 py-2 transition-colors hover:bg-gray-50 dark:hover:bg-gray-800/50">
                            <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-gray-50 text-[10px] font-black text-gray-400 dark:bg-gray-800">
                                {{ $index + 1 }}
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="text-xs font-bold text-gray-700 dark:text-gray-200 truncate">{{ $visit->country ?: 'غير معروف' }}</div>
                                <div class="mt-1 h-1 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                    <div class="h-full rounded-full bg-blue-500 transition-all duration-700" style="width: {{ $pct }}%"></div>
                                </div>
                            </div>
                            <div class="text-left">
                                <div class="text-xs font-black text-gray-900 dark:text-white">{{ number_format($visit->count) }}</div>
                                <div class="text-[9px] font-bold text-blue-500">{{ $pct }}%</div>
                            </div>
                        </div>
                    @empty
                        <div class="py-8 text-center text-xs text-gray-400">
                            <i class="fa-solid fa-globe mb-2 text-2xl text-gray-300 dark:text-gray-600"></i>
                            <p>لا توجد بيانات</p>
                        </div>
                    @endforelse
                </div>
            </div>

            {{-- Platform Distribution --}}
            <div class="dash-card p-5">
                <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">أنظمة التشغيل</h3>
                <div class="space-y-4">
                    @php
                        $platformColors = ['bg-blue-500', 'bg-emerald-500', 'bg-amber-500', 'bg-violet-500', 'bg-rose-500'];
                        $platformTextColors = ['text-blue-500', 'text-emerald-500', 'text-amber-500', 'text-violet-500', 'text-rose-500'];
                    @endphp
                    @forelse($stats['platform_distribution'] as $pi => $platform)
                        @php $share = $stats['total_visits'] > 0 ? ($platform->count / $stats['total_visits']) * 100 : 0; @endphp
                        <div>
                            <div class="mb-1.5 flex items-center justify-between text-[11px] font-bold">
                                <span class="text-gray-700 dark:text-gray-300">{{ $platform->os ?: 'غير معروف' }}</span>
                                <span class="{{ $platformTextColors[$pi % 5] }}">{{ round($share, 1) }}%</span>
                            </div>
                            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                <div class="h-full rounded-full {{ $platformColors[$pi % 5] }} transition-all duration-1000" style="width: {{ $share }}%"></div>
                            </div>
                        </div>
                    @empty
                        <p class="py-4 text-center text-xs text-gray-400">لا توجد بيانات</p>
                    @endforelse
                </div>
            </div>
        </div>
    </div>

    {{-- Content & Quality Row --}}
    <div class="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-12">
        {{-- Most Visited Pages Table --}}
        <div class="dash-card overflow-hidden lg:col-span-8">
            <div class="border-b border-gray-100 px-6 py-5 dark:border-white/5">
                <h3 class="text-base font-black text-gray-900 dark:text-white">الصفحات الأكثر زيارة</h3>
                <p class="mt-0.5 text-xs text-gray-500 dark:text-gray-400">الروابط الأعلى تفاعلاً</p>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-right">
                    <thead>
                        <tr class="bg-gray-50/80 dark:bg-white/[0.02]">
                            <th class="px-6 py-3.5 text-[10px] font-black uppercase tracking-wider text-gray-400">#</th>
                            <th class="px-6 py-3.5 text-[10px] font-black uppercase tracking-wider text-gray-400">الصفحة</th>
                            <th class="hidden px-6 py-3.5 text-[10px] font-black uppercase tracking-wider text-gray-400 sm:table-cell">النسبة</th>
                            <th class="px-6 py-3.5 text-left text-[10px] font-black uppercase tracking-wider text-gray-400">الزيارات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50 dark:divide-white/[0.03]">
                        @foreach($stats['top_visited_pages'] as $pi => $page)
                            @php
                                $path = parse_url($page->url, PHP_URL_PATH) ?: '/';
                                $maxCount = $stats['top_visited_pages']->first()->count ?? 1;
                                $relativeWidth = ($page->count / $maxCount) * 100;
                            @endphp
                            <tr class="table-row-hover transition-colors">
                                <td class="px-6 py-3.5">
                                    <span class="flex h-6 w-6 items-center justify-center rounded-md bg-gray-50 text-[10px] font-black text-gray-400 dark:bg-gray-800">{{ $pi + 1 }}</span>
                                </td>
                                <td class="px-6 py-3.5">
                                    <div class="text-xs font-bold text-gray-800 dark:text-gray-200">{{ Str::limit($path, 40) }}</div>
                                </td>
                                <td class="hidden px-6 py-3.5 sm:table-cell">
                                    <div class="w-24">
                                        <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                            <div class="h-full rounded-full bg-blue-500" style="width: {{ $relativeWidth }}%"></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-3.5 text-left">
                                    <span class="text-xs font-black text-blue-600 dark:text-blue-400">{{ number_format($page->count) }}</span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        {{-- Data Quality Gauges --}}
        <div class="dash-card p-6 lg:col-span-4">
            <h3 class="mb-2 text-base font-black text-gray-900 dark:text-white">جودة البيانات</h3>
            <p class="mb-6 text-xs text-gray-500 dark:text-gray-400">تغطية التصنيف والمؤلفين</p>

            <div class="flex flex-col items-center gap-8">
                {{-- Category Coverage Ring --}}
                <div class="text-center">
                    <div class="relative inline-flex items-center justify-center">
                        <svg class="h-28 w-28" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="52" fill="none" stroke-width="8"
                                class="stroke-gray-100 dark:stroke-gray-800" />
                            <circle cx="60" cy="60" r="52" fill="none" stroke-width="8"
                                stroke-dasharray="{{ 2 * 3.14159 * 52 }}"
                                stroke-dashoffset="{{ 2 * 3.14159 * 52 * (1 - $categoryCoverage / 100) }}"
                                stroke-linecap="round"
                                class="progress-ring stroke-emerald-500"
                                transform="rotate(-90 60 60)" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-xl font-black text-gray-900 dark:text-white">{{ $categoryCoverage }}%</span>
                        </div>
                    </div>
                    <p class="mt-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">التصنيفات</p>
                    <p class="text-[10px] text-gray-500 dark:text-gray-400">{{ number_format($stats['items_with_categories']) }} من {{ number_format($stats['items_count']) }}</p>
                </div>

                {{-- Author Coverage Ring --}}
                <div class="text-center">
                    <div class="relative inline-flex items-center justify-center">
                        <svg class="h-28 w-28" viewBox="0 0 120 120">
                            <circle cx="60" cy="60" r="52" fill="none" stroke-width="8"
                                class="stroke-gray-100 dark:stroke-gray-800" />
                            <circle cx="60" cy="60" r="52" fill="none" stroke-width="8"
                                stroke-dasharray="{{ 2 * 3.14159 * 52 }}"
                                stroke-dashoffset="{{ 2 * 3.14159 * 52 * (1 - $authorCoverage / 100) }}"
                                stroke-linecap="round"
                                class="progress-ring stroke-amber-500"
                                transform="rotate(-90 60 60)" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span class="text-xl font-black text-gray-900 dark:text-white">{{ $authorCoverage }}%</span>
                        </div>
                    </div>
                    <p class="mt-2 text-[11px] font-bold uppercase tracking-widest text-gray-400">المؤلفون</p>
                    <p class="text-[10px] text-gray-500 dark:text-gray-400">{{ number_format($stats['items_with_authors']) }} من {{ number_format($stats['items_count']) }}</p>
                </div>
            </div>
        </div>
    </div>

    {{-- Content Distribution + System Health Row --}}
    <div class="mb-8 grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        {{-- Content Types --}}
        <div class="dash-card p-5">
            <div class="mb-4 flex items-center gap-2">
                <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-500/10 dark:bg-blue-500/15">
                    <i class="fa-solid fa-chart-pie text-xs text-blue-500"></i>
                </div>
                <h4 class="text-xs font-black text-gray-900 dark:text-white">توزيع المحتوى</h4>
            </div>
            <div class="space-y-2.5">
                @foreach($stats['type_distribution']->take(5) as $type)
                    <div class="flex items-center justify-between">
                        <span class="text-[11px] font-medium text-gray-600 dark:text-gray-400">{{ $type['label'] }}</span>
                        <div class="flex items-center gap-2">
                            <div class="h-1 w-12 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                <div class="h-full rounded-full bg-blue-500" style="width: {{ $type['share'] }}%"></div>
                            </div>
                            <span class="text-[10px] font-black text-gray-900 dark:text-white">{{ number_format($type['count']) }}</span>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>

        {{-- API Health --}}
        <div class="dash-card p-5">
            <div class="mb-4 flex items-center gap-2">
                <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-500/10 dark:bg-emerald-500/15">
                    <i class="fa-solid fa-cloud-arrow-down text-xs text-emerald-500"></i>
                </div>
                <h4 class="text-xs font-black text-gray-900 dark:text-white">صحة الـ API</h4>
            </div>
            <div class="mb-3 flex items-end justify-between">
                <div>
                    <div class="text-2xl font-black {{ $stats['api_health']['success_rate'] >= 90 ? 'text-emerald-600 dark:text-emerald-400' : ($stats['api_health']['success_rate'] >= 70 ? 'text-amber-600 dark:text-amber-400' : 'text-red-600 dark:text-red-400') }}">
                        {{ $stats['api_health']['success_rate'] }}%
                    </div>
                    <p class="text-[10px] text-gray-400">نسبة النجاح</p>
                </div>
                <div class="flex h-10 w-10 items-center justify-center rounded-xl {{ $stats['api_health']['success_rate'] >= 90 ? 'bg-emerald-50 dark:bg-emerald-500/10' : 'bg-amber-50 dark:bg-amber-500/10' }}">
                    <i class="fa-solid {{ $stats['api_health']['success_rate'] >= 90 ? 'fa-check text-emerald-500' : 'fa-exclamation text-amber-500' }}"></i>
                </div>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-full rounded-full {{ $stats['api_health']['success_rate'] >= 90 ? 'bg-emerald-500' : ($stats['api_health']['success_rate'] >= 70 ? 'bg-amber-500' : 'bg-red-500') }}" style="width: {{ $stats['api_health']['success_rate'] }}%"></div>
            </div>
            <div class="mt-3 flex justify-between text-[10px] text-gray-400">
                <span>{{ number_format($stats['api_health']['snapshots_success']) }} ناجح</span>
                <span>{{ number_format($stats['api_health']['snapshots_failed']) }} فشل</span>
            </div>
        </div>

        {{-- Queue Health --}}
        <div class="dash-card p-5">
            <div class="mb-4 flex items-center gap-2">
                <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-violet-500/10 dark:bg-violet-500/15">
                    <i class="fa-solid fa-list-check text-xs text-violet-500"></i>
                </div>
                <h4 class="text-xs font-black text-gray-900 dark:text-white">قائمة المهام</h4>
            </div>
            <div class="flex gap-4">
                <div class="flex-1 rounded-xl bg-gray-50 p-3 text-center dark:bg-gray-800/50">
                    <div class="text-xl font-black text-gray-900 dark:text-white">{{ $stats['queue_health']['pending'] }}</div>
                    <div class="text-[10px] font-medium text-gray-400">معلقة</div>
                </div>
                <div class="flex-1 rounded-xl bg-gray-50 p-3 text-center dark:bg-gray-800/50">
                    <div class="text-xl font-black {{ $stats['queue_health']['failed'] > 0 ? 'text-red-600 dark:text-red-400' : 'text-gray-900 dark:text-white' }}">{{ $stats['queue_health']['failed'] }}</div>
                    <div class="text-[10px] font-medium text-gray-400">فاشلة</div>
                </div>
            </div>
        </div>

        {{-- Metadata Overview --}}
        <div class="dash-card p-5">
            <div class="mb-4 flex items-center gap-2">
                <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-amber-500/10 dark:bg-amber-500/15">
                    <i class="fa-solid fa-database text-xs text-amber-500"></i>
                </div>
                <h4 class="text-xs font-black text-gray-900 dark:text-white">البيانات المساندة</h4>
            </div>
            <div class="space-y-2">
                @foreach($stats['metadata_stats']->take(5) as $row)
                    <div class="flex items-center justify-between rounded-lg px-2 py-1.5 transition-colors hover:bg-gray-50 dark:hover:bg-gray-800/50">
                        <span class="text-[11px] font-medium text-gray-600 dark:text-gray-400">{{ $row['label'] }}</span>
                        <span class="text-[11px] font-black text-gray-900 dark:text-white">{{ number_format($row['count']) }}</span>
                    </div>
                @endforeach
            </div>
        </div>
    </div>

    {{-- Quick Stats Footer --}}
    <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
        @php
            $quickStats = [
                ['label' => 'التصنيفات', 'value' => $stats['categories_count'], 'icon' => 'fa-tags', 'color' => 'blue'],
                ['label' => 'المؤلفون', 'value' => $stats['authors_count'], 'icon' => 'fa-users', 'color' => 'emerald'],
                ['label' => 'المرفقات', 'value' => $stats['attachments_count'], 'icon' => 'fa-paperclip', 'color' => 'amber'],
                ['label' => 'بدون تصنيف', 'value' => $stats['uncategorized_items'], 'icon' => 'fa-circle-question', 'color' => 'red'],
                ['label' => 'بدون مؤلف', 'value' => $stats['unattributed_items'], 'icon' => 'fa-user-slash', 'color' => 'orange'],
                ['label' => 'القرآن', 'value' => $stats['quran_stats']['recitations'] ?? 0, 'icon' => 'fa-book-quran', 'color' => 'violet'],
            ];
            $quickColors = [
                'blue' => 'text-blue-500',
                'emerald' => 'text-emerald-500',
                'amber' => 'text-amber-500',
                'red' => 'text-red-500',
                'orange' => 'text-orange-500',
                'violet' => 'text-violet-500',
            ];
        @endphp
        @foreach($quickStats as $qs)
            <div class="dash-card p-4 text-center">
                <i class="fa-solid {{ $qs['icon'] }} mb-2 text-lg {{ $quickColors[$qs['color']] }}"></i>
                <div class="text-lg font-black text-gray-900 dark:text-white">{{ number_format($qs['value']) }}</div>
                <div class="text-[10px] font-bold uppercase tracking-wider text-gray-400">{{ $qs['label'] }}</div>
            </div>
        @endforeach
    </div>

    {{-- Chart.js Script --}}
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const isDark = document.documentElement.classList.contains('dark');
            const gridColor = isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.04)';
            const tickColor = isDark ? '#64748b' : '#94a3b8';

            const trendData = @json($stats['visits_last_7_days']);
            const ctx = document.getElementById('trafficTrendChart').getContext('2d');

            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, isDark ? 'rgba(59,130,246,0.15)' : 'rgba(59,130,246,0.08)');
            gradient.addColorStop(1, 'rgba(59,130,246,0)');

            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: trendData.map(d => {
                        const date = new Date(d.date);
                        return date.toLocaleDateString('ar-SA', { weekday: 'short', day: 'numeric' });
                    }),
                    datasets: [{
                        label: 'الزيارات',
                        data: trendData.map(d => d.count),
                        borderColor: '#3b82f6',
                        backgroundColor: gradient,
                        fill: true,
                        tension: 0.45,
                        borderWidth: 3,
                        pointRadius: 5,
                        pointHoverRadius: 8,
                        pointBackgroundColor: '#3b82f6',
                        pointBorderColor: isDark ? '#1f2937' : '#ffffff',
                        pointBorderWidth: 3,
                        pointHoverBorderWidth: 3,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { intersect: false, mode: 'index' },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: isDark ? '#1e293b' : '#ffffff',
                            titleColor: isDark ? '#f1f5f9' : '#1e293b',
                            bodyColor: isDark ? '#94a3b8' : '#64748b',
                            borderColor: isDark ? '#334155' : '#e2e8f0',
                            borderWidth: 1,
                            cornerRadius: 12,
                            padding: 12,
                            titleFont: { weight: '700', size: 13 },
                            bodyFont: { size: 12 },
                            displayColors: false,
                            callbacks: {
                                label: (ctx) => ctx.parsed.y.toLocaleString('ar-SA') + ' زيارة'
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: gridColor, drawBorder: false },
                            border: { display: false },
                            ticks: {
                                font: { size: 11, weight: '600' },
                                color: tickColor,
                                padding: 8,
                            }
                        },
                        x: {
                            grid: { display: false },
                            border: { display: false },
                            ticks: {
                                font: { size: 11, weight: '600' },
                                color: tickColor,
                                padding: 8,
                            }
                        }
                    }
                }
            });
        });
    </script>
</x-admin-layout>
