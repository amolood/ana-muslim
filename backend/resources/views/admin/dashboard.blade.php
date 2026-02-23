<x-admin-layout>
    @php
        $itemsCount = max(1, (int) $stats['items_count']);
        $categoryCoverage = round(((int) $stats['items_with_categories'] / $itemsCount) * 100, 1);
        $authorCoverage = round(((int) $stats['items_with_authors'] / $itemsCount) * 100, 1);
        $attachmentCoverage = round(((int) $stats['items_with_attachments'] / $itemsCount) * 100, 1);
        $lastContentUpdate = $stats['last_content_update'] ? \Illuminate\Support\Carbon::parse($stats['last_content_update']) : null;
        $lastSnapshotFetch = $stats['api_health']['last_fetched_at'] ? \Illuminate\Support\Carbon::parse($stats['api_health']['last_fetched_at']) : null;
        $lastFailedJobAt = $stats['queue_health']['last_failed_at'] ? \Illuminate\Support\Carbon::parse($stats['queue_health']['last_failed_at']) : null;
    @endphp

    <div class="mb-8 relative overflow-hidden rounded-2xl bg-gradient-to-r from-blue-700 via-indigo-700 to-cyan-700 p-8 text-white shadow-xl">
        <div class="absolute -right-16 -top-16 h-56 w-56 rounded-full bg-white/10 blur-3xl"></div>
        <div class="absolute -bottom-24 left-6 h-52 w-52 rounded-full bg-cyan-400/20 blur-3xl"></div>

        <div class="relative z-10 flex flex-col gap-5 xl:flex-row xl:items-center xl:justify-between">
            <div>
                <h1 class="mb-2 flex items-center gap-3 text-3xl font-black">
                    <i class="fa-solid fa-chart-line text-yellow-300"></i>
                    لوحة تحكم المحتوى والاستيراد
                </h1>
                <p class="max-w-3xl text-sm text-blue-100 md:text-base">
                    متابعة شاملة للمواد (فيديو، فتاوى، مقالات، قرآن، صوتيات) مع مراقبة حالة الاستيراد من API والـ Queue.
                </p>
            </div>

            <div class="grid gap-2 text-xs sm:grid-cols-2">
                <div class="rounded-xl bg-white/10 px-4 py-2 ring-1 ring-white/20 backdrop-blur-sm">
                    <div class="mb-1 text-blue-100">آخر تحديث للمحتوى</div>
                    <div class="font-bold text-white">{{ $lastContentUpdate ? $lastContentUpdate->diffForHumans() : 'غير متاح' }}</div>
                </div>
                <div class="rounded-xl bg-white/10 px-4 py-2 ring-1 ring-white/20 backdrop-blur-sm">
                    <div class="mb-1 text-blue-100">آخر جلب من API</div>
                    <div class="font-bold text-white">{{ $lastSnapshotFetch ? $lastSnapshotFetch->diffForHumans() : 'غير متاح' }}</div>
                </div>
            </div>
        </div>
    </div>

    <div class="mb-8 grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        <div class="admin-card overflow-hidden">
            <div class="p-6">
                <div class="mb-3 flex items-center justify-between">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-blue-50 text-lg text-blue-600 dark:bg-blue-900/20 dark:text-blue-400">
                        <i class="fa-solid fa-photo-film"></i>
                    </div>
                    <span class="rounded-full bg-blue-50 px-2 py-0.5 text-[11px] font-bold text-blue-700 dark:bg-blue-500/10 dark:text-blue-400">محتوى</span>
                </div>
                <div class="text-4xl font-black text-gray-900 dark:text-white">{{ number_format($stats['items_count']) }}</div>
                <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">إجمالي المواد</div>
            </div>
            <a href="{{ route('admin.items.index') }}" class="flex items-center justify-between bg-gray-50/80 px-6 py-3 text-xs font-bold text-blue-600 transition-colors hover:bg-gray-100 dark:bg-white/[0.02] dark:text-blue-400 dark:hover:bg-white/[0.06]">
                <span>إدارة المواد</span>
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
            </a>
        </div>

        <div class="admin-card overflow-hidden">
            <div class="p-6">
                <div class="mb-3 flex items-center justify-between">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-emerald-50 text-lg text-emerald-600 dark:bg-emerald-900/20 dark:text-emerald-400">
                        <i class="fa-solid fa-folder-tree"></i>
                    </div>
                    <span class="rounded-full bg-emerald-50 px-2 py-0.5 text-[11px] font-bold text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400">تصنيفات</span>
                </div>
                <div class="text-4xl font-black text-gray-900 dark:text-white">{{ number_format($stats['categories_count']) }}</div>
                <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">إجمالي التصنيفات</div>
            </div>
            <a href="{{ route('admin.categories.index') }}" class="flex items-center justify-between bg-gray-50/80 px-6 py-3 text-xs font-bold text-emerald-600 transition-colors hover:bg-gray-100 dark:bg-white/[0.02] dark:text-emerald-400 dark:hover:bg-white/[0.06]">
                <span>إدارة التصنيفات</span>
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
            </a>
        </div>

        <div class="admin-card overflow-hidden">
            <div class="p-6">
                <div class="mb-3 flex items-center justify-between">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-amber-50 text-lg text-amber-600 dark:bg-amber-900/20 dark:text-amber-400">
                        <i class="fa-solid fa-users-rectangle"></i>
                    </div>
                    <span class="rounded-full bg-amber-50 px-2 py-0.5 text-[11px] font-bold text-amber-700 dark:bg-amber-500/10 dark:text-amber-400">مؤلفون</span>
                </div>
                <div class="text-4xl font-black text-gray-900 dark:text-white">{{ number_format($stats['authors_count']) }}</div>
                <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">إجمالي المؤلفين</div>
            </div>
            <a href="{{ route('admin.authors.index') }}" class="flex items-center justify-between bg-gray-50/80 px-6 py-3 text-xs font-bold text-amber-600 transition-colors hover:bg-gray-100 dark:bg-white/[0.02] dark:text-amber-400 dark:hover:bg-white/[0.06]">
                <span>إدارة المؤلفين</span>
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
            </a>
        </div>

        <div class="admin-card overflow-hidden">
            <div class="p-6">
                <div class="mb-3 flex items-center justify-between">
                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-fuchsia-50 text-lg text-fuchsia-600 dark:bg-fuchsia-900/20 dark:text-fuchsia-400">
                        <i class="fa-solid fa-file-audio"></i>
                    </div>
                    <span class="rounded-full bg-fuchsia-50 px-2 py-0.5 text-[11px] font-bold text-fuchsia-700 dark:bg-fuchsia-500/10 dark:text-fuchsia-400">مرفقات</span>
                </div>
                <div class="text-4xl font-black text-gray-900 dark:text-white">{{ number_format($stats['attachments_count']) }}</div>
                <div class="mt-1 text-xs text-gray-500 dark:text-gray-400">إجمالي الملفات</div>
            </div>
            <a href="{{ route('admin.attachments.index') }}" class="flex items-center justify-between bg-gray-50/80 px-6 py-3 text-xs font-bold text-fuchsia-600 transition-colors hover:bg-gray-100 dark:bg-white/[0.02] dark:text-fuchsia-400 dark:hover:bg-white/[0.06]">
                <span>مراجعة المرفقات</span>
                <i class="fa-solid fa-arrow-left text-[10px]"></i>
            </a>
        </div>
    </div>

    <div class="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div class="admin-card p-5">
            <div class="mb-2 flex items-center justify-between text-sm">
                <h3 class="font-bold text-gray-900 dark:text-white">تغطية التصنيفات</h3>
                <span class="font-black text-emerald-600 dark:text-emerald-400">{{ $categoryCoverage }}%</span>
            </div>
            <div class="mb-2 h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-2 rounded-full bg-emerald-500" style="width: {{ min(100, $categoryCoverage) }}%"></div>
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400">
                {{ number_format($stats['items_with_categories']) }} مادة مرتبطة بتصنيفات، و{{ number_format($stats['uncategorized_items']) }} بدون تصنيف.
            </div>
        </div>

        <div class="admin-card p-5">
            <div class="mb-2 flex items-center justify-between text-sm">
                <h3 class="font-bold text-gray-900 dark:text-white">تغطية المؤلفين</h3>
                <span class="font-black text-amber-600 dark:text-amber-400">{{ $authorCoverage }}%</span>
            </div>
            <div class="mb-2 h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-2 rounded-full bg-amber-500" style="width: {{ min(100, $authorCoverage) }}%"></div>
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400">
                {{ number_format($stats['items_with_authors']) }} مادة مرتبطة بمؤلفين، و{{ number_format($stats['unattributed_items']) }} بدون مؤلف.
            </div>
        </div>

        <div class="admin-card p-5">
            <div class="mb-2 flex items-center justify-between text-sm">
                <h3 class="font-bold text-gray-900 dark:text-white">تغطية المرفقات</h3>
                <span class="font-black text-fuchsia-600 dark:text-fuchsia-400">{{ $attachmentCoverage }}%</span>
            </div>
            <div class="mb-2 h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                <div class="h-2 rounded-full bg-fuchsia-500" style="width: {{ min(100, $attachmentCoverage) }}%"></div>
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400">
                {{ number_format($stats['items_with_attachments']) }} مادة لها مرفقات.
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 gap-8 xl:grid-cols-4">
        <div class="space-y-6 xl:col-span-3">
            <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
                <div class="admin-card p-5">
                    <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                        <i class="fa-solid fa-layer-group text-blue-500"></i>
                        توزيع أنواع المحتوى
                    </h3>
                    <div class="space-y-3">
                        @forelse($stats['type_distribution'] as $entry)
                            <div>
                                <div class="mb-1 flex items-center justify-between text-xs">
                                    <span class="font-bold text-gray-700 dark:text-gray-200">{{ $entry['label'] }}</span>
                                    <span class="text-gray-500 dark:text-gray-400">{{ number_format($entry['count']) }} ({{ $entry['share'] }}%)</span>
                                </div>
                                <div class="h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                                    <div class="h-2 rounded-full bg-blue-500" style="width: {{ min(100, $entry['share']) }}%"></div>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>

                <div class="admin-card p-5">
                    <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                        <i class="fa-solid fa-language text-emerald-500"></i>
                        لغات المصدر
                    </h3>
                    <div class="space-y-3">
                        @forelse($stats['source_language_distribution'] as $entry)
                            <div>
                                <div class="mb-1 flex items-center justify-between text-xs">
                                    <span class="font-bold text-gray-700 dark:text-gray-200">{{ $entry['label'] }}</span>
                                    <span class="text-gray-500 dark:text-gray-400">{{ number_format($entry['count']) }} ({{ $entry['share'] }}%)</span>
                                </div>
                                <div class="h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                                    <div class="h-2 rounded-full bg-emerald-500" style="width: {{ min(100, $entry['share']) }}%"></div>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>

                <div class="admin-card p-5">
                    <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                        <i class="fa-solid fa-globe text-purple-500"></i>
                        لغات الترجمة
                    </h3>
                    <div class="space-y-3">
                        @forelse($stats['translated_language_distribution'] as $entry)
                            <div>
                                <div class="mb-1 flex items-center justify-between text-xs">
                                    <span class="font-bold text-gray-700 dark:text-gray-200">{{ $entry['label'] }}</span>
                                    <span class="text-gray-500 dark:text-gray-400">{{ number_format($entry['count']) }} ({{ $entry['share'] }}%)</span>
                                </div>
                                <div class="h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                                    <div class="h-2 rounded-full bg-purple-500" style="width: {{ min(100, $entry['share']) }}%"></div>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>

                <div class="admin-card p-5">
                    <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                        <i class="fa-solid fa-file-circle-check text-fuchsia-500"></i>
                        أنواع المرفقات
                    </h3>
                    <div class="space-y-3">
                        @forelse($stats['attachment_type_distribution'] as $entry)
                            <div>
                                <div class="mb-1 flex items-center justify-between text-xs">
                                    <span class="font-bold text-gray-700 dark:text-gray-200">{{ $entry['label'] }}</span>
                                    <span class="text-gray-500 dark:text-gray-400">{{ number_format($entry['count']) }} ({{ $entry['share'] }}%)</span>
                                </div>
                                <div class="h-2 rounded-full bg-gray-100 dark:bg-gray-800">
                                    <div class="h-2 rounded-full bg-fuchsia-500" style="width: {{ min(100, $entry['share']) }}%"></div>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
                <div class="admin-card p-5">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-sm font-black text-gray-900 dark:text-white">
                            <i class="fa-solid fa-ranking-star text-emerald-500"></i>
                            التصنيفات الأكثر ارتباطًا بالمواد
                        </h3>
                        <a href="{{ route('admin.categories.index') }}" class="text-xs font-bold text-emerald-600 dark:text-emerald-400">عرض الكل</a>
                    </div>
                    <div class="space-y-3">
                        @forelse($stats['top_categories'] as $category)
                            <div class="rounded-xl border border-gray-100 bg-gray-50/70 p-3 dark:border-white/10 dark:bg-white/[0.03]">
                                <div class="mb-1 flex items-center justify-between gap-2">
                                    <div class="truncate text-sm font-bold text-gray-800 dark:text-gray-100">{{ $category['title'] }}</div>
                                    <span class="text-[11px] text-gray-500 dark:text-gray-400">{{ $category['language'] }}</span>
                                </div>
                                <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
                                    <span>{{ number_format($category['linked_items']) }} مادة</span>
                                    <span>{{ $category['share'] }}%</span>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>

                <div class="admin-card p-5">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-sm font-black text-gray-900 dark:text-white">
                            <i class="fa-solid fa-user-check text-amber-500"></i>
                            المؤلفون الأكثر ارتباطًا بالمواد
                        </h3>
                        <a href="{{ route('admin.authors.index') }}" class="text-xs font-bold text-amber-600 dark:text-amber-400">عرض الكل</a>
                    </div>
                    <div class="space-y-3">
                        @forelse($stats['top_authors'] as $author)
                            <div class="rounded-xl border border-gray-100 bg-gray-50/70 p-3 dark:border-white/10 dark:bg-white/[0.03]">
                                <div class="mb-1 flex items-center justify-between gap-2">
                                    <div class="truncate text-sm font-bold text-gray-800 dark:text-gray-100">{{ $author['title'] }}</div>
                                    <span class="text-[11px] text-gray-500 dark:text-gray-400">{{ $author['type'] }}</span>
                                </div>
                                <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
                                    <span>{{ number_format($author['linked_items']) }} مادة</span>
                                    <span>{{ $author['share'] }}%</span>
                                </div>
                            </div>
                        @empty
                            <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد بيانات.</p>
                        @endforelse
                    </div>
                </div>
            </div>

            <div class="admin-card overflow-hidden">
                <div class="flex items-center justify-between border-b border-gray-100 px-5 py-4 dark:border-white/10">
                    <h3 class="text-sm font-black text-gray-900 dark:text-white">
                        <i class="fa-solid fa-clock-rotate-left text-blue-500"></i>
                        أحدث المواد
                    </h3>
                    <a href="{{ route('admin.items.index') }}" class="text-xs font-bold text-blue-600 dark:text-blue-400">عرض الكل</a>
                </div>
                <div class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($stats['recent_items'] as $item)
                        <div class="group flex items-center gap-3 p-4 transition-colors hover:bg-gray-50/70 dark:hover:bg-white/[0.03]">
                            <div class="shrink-0">
                                @if($item->image)
                                    <div class="h-12 w-12 overflow-hidden rounded-xl ring-1 ring-gray-900/10">
                                        <img src="{{ $item->image }}" alt="" class="h-full w-full object-cover">
                                    </div>
                                @else
                                    <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600 ring-1 ring-gray-900/10 dark:bg-blue-900/20 dark:text-blue-400 dark:ring-white/10">
                                        <i class="fa-solid fa-play"></i>
                                    </div>
                                @endif
                            </div>
                            <div class="min-w-0 flex-1">
                                <div class="truncate text-sm font-bold text-gray-900 dark:text-white">{{ $item->title }}</div>
                                <div class="mt-0.5 flex items-center gap-2 text-[11px] text-gray-500 dark:text-gray-400">
                                    <span class="rounded bg-gray-100 px-1.5 py-0.5 dark:bg-white/10">{{ $item->type ?: 'غير مصنف' }}</span>
                                    <span>•</span>
                                    <span>{{ $item->created_at->diffForHumans() }}</span>
                                </div>
                            </div>
                            <a href="{{ route('admin.items.edit', $item->id) }}" class="opacity-0 transition-opacity group-hover:opacity-100">
                                <span class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400">
                                    <i class="fa-solid fa-pen text-xs"></i>
                                </span>
                            </a>
                        </div>
                    @empty
                        <div class="p-8 text-center text-sm text-gray-500 dark:text-gray-400">لا توجد مواد مضافة بعد.</div>
                    @endforelse
                </div>
            </div>

            @if($stats['api_health']['enabled'])
                <div class="admin-card p-5">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-sm font-black text-gray-900 dark:text-white">
                            <i class="fa-solid fa-triangle-exclamation text-rose-500"></i>
                            أحدث أخطاء API
                        </h3>
                        <span class="rounded-full bg-rose-50 px-2 py-1 text-[11px] font-bold text-rose-700 dark:bg-rose-500/10 dark:text-rose-300">
                            {{ number_format($stats['api_health']['snapshots_failed']) }} خطأ
                        </span>
                    </div>

                    @if($stats['api_health']['recent_failures']->isEmpty())
                        <p class="text-xs text-gray-500 dark:text-gray-400">لا توجد أخطاء مسجلة في اللقطات الحالية.</p>
                    @else
                        <div class="space-y-2">
                            @foreach($stats['api_health']['recent_failures'] as $failure)
                                <div class="rounded-xl border border-gray-100 bg-gray-50/70 p-3 text-xs dark:border-white/10 dark:bg-white/[0.03]">
                                    <div class="mb-1 font-bold text-gray-800 dark:text-gray-100">{{ $failure->endpoint_name }}</div>
                                    <div class="flex flex-wrap items-center gap-2 text-gray-500 dark:text-gray-400">
                                        <span class="rounded bg-gray-100 px-1.5 py-0.5 dark:bg-white/10">{{ $failure->endpoint_group ?: 'General' }}</span>
                                        <span class="rounded bg-rose-50 px-1.5 py-0.5 text-rose-700 dark:bg-rose-500/10 dark:text-rose-300">
                                            {{ $failure->status_code ? 'HTTP '.$failure->status_code : 'Timeout/Exception' }}
                                        </span>
                                        <span>{{ $failure->fetched_at ? \Illuminate\Support\Carbon::parse($failure->fetched_at)->diffForHumans() : 'غير معروف' }}</span>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    @endif
                </div>
            @endif
        </div>

        <div class="space-y-6">
            <div class="admin-card p-4">
                <h3 class="mb-3 text-sm font-black text-gray-900 dark:text-white">
                    <i class="fa-solid fa-bolt text-amber-500"></i>
                    إجراءات سريعة
                </h3>
                <div class="space-y-2">
                    <a href="{{ route('admin.items.create') }}" class="group flex items-center justify-between rounded-xl border border-transparent p-3 transition hover:border-gray-100 hover:bg-gray-50 dark:hover:border-white/10 dark:hover:bg-white/[0.03]">
                        <div class="flex items-center gap-3">
                            <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400">
                                <i class="fa-solid fa-plus"></i>
                            </div>
                            <span class="text-xs font-bold text-gray-700 dark:text-gray-200">إضافة مادة جديدة</span>
                        </div>
                        <i class="fa-solid fa-chevron-left text-[10px] text-gray-300 group-hover:text-blue-500"></i>
                    </a>

                    <a href="{{ route('admin.categories.create') }}" class="group flex items-center justify-between rounded-xl border border-transparent p-3 transition hover:border-gray-100 hover:bg-gray-50 dark:hover:border-white/10 dark:hover:bg-white/[0.03]">
                        <div class="flex items-center gap-3">
                            <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-emerald-100 text-emerald-600 dark:bg-emerald-900/30 dark:text-emerald-400">
                                <i class="fa-solid fa-folder-plus"></i>
                            </div>
                            <span class="text-xs font-bold text-gray-700 dark:text-gray-200">إنشاء تصنيف</span>
                        </div>
                        <i class="fa-solid fa-chevron-left text-[10px] text-gray-300 group-hover:text-emerald-500"></i>
                    </a>

                    <a href="{{ route('admin.authors.create') }}" class="group flex items-center justify-between rounded-xl border border-transparent p-3 transition hover:border-gray-100 hover:bg-gray-50 dark:hover:border-white/10 dark:hover:bg-white/[0.03]">
                        <div class="flex items-center gap-3">
                            <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-amber-100 text-amber-600 dark:bg-amber-900/30 dark:text-amber-400">
                                <i class="fa-solid fa-user-plus"></i>
                            </div>
                            <span class="text-xs font-bold text-gray-700 dark:text-gray-200">إضافة مؤلف</span>
                        </div>
                        <i class="fa-solid fa-chevron-left text-[10px] text-gray-300 group-hover:text-amber-500"></i>
                    </a>

                    <a href="{{ route('admin.attachments.index') }}" class="group flex items-center justify-between rounded-xl border border-transparent p-3 transition hover:border-gray-100 hover:bg-gray-50 dark:hover:border-white/10 dark:hover:bg-white/[0.03]">
                        <div class="flex items-center gap-3">
                            <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-fuchsia-100 text-fuchsia-600 dark:bg-fuchsia-900/30 dark:text-fuchsia-400">
                                <i class="fa-solid fa-file-waveform"></i>
                            </div>
                            <span class="text-xs font-bold text-gray-700 dark:text-gray-200">فحص المرفقات</span>
                        </div>
                        <i class="fa-solid fa-chevron-left text-[10px] text-gray-300 group-hover:text-fuchsia-500"></i>
                    </a>
                </div>
            </div>

            <div class="admin-card p-5">
                <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                    <i class="fa-solid fa-heart-pulse text-red-500"></i>
                    صحة الاستيراد والنظام
                </h3>

                <div class="space-y-3 text-xs">
                    <div class="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <span class="text-gray-600 dark:text-gray-300">نجاح API</span>
                        <span class="font-black text-emerald-600 dark:text-emerald-400">{{ $stats['api_health']['success_rate'] }}%</span>
                    </div>
                    <div class="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <span class="text-gray-600 dark:text-gray-300">Snapshots</span>
                        <span class="font-black text-gray-900 dark:text-white">{{ number_format($stats['api_health']['snapshots_total']) }}</span>
                    </div>
                    <div class="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <span class="text-gray-600 dark:text-gray-300">Jobs Pending</span>
                        <span class="font-black text-blue-600 dark:text-blue-400">{{ number_format($stats['queue_health']['pending']) }}</span>
                    </div>
                    <div class="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <span class="text-gray-600 dark:text-gray-300">Failed Jobs</span>
                        <span class="font-black text-rose-600 dark:text-rose-400">{{ number_format($stats['queue_health']['failed']) }}</span>
                    </div>
                    <div class="text-gray-500 dark:text-gray-400">
                        آخر فشل Queue: {{ $lastFailedJobAt ? $lastFailedJobAt->diffForHumans() : 'غير متاح' }}
                    </div>
                </div>

                @if($stats['api_health']['failed_groups']->isNotEmpty())
                    <div class="mt-4 border-t border-gray-100 pt-4 dark:border-white/10">
                        <div class="mb-2 text-xs font-bold text-gray-700 dark:text-gray-200">أكثر مجموعات endpoints فشلًا</div>
                        <div class="space-y-1.5">
                            @foreach($stats['api_health']['failed_groups'] as $group)
                                <div class="flex items-center justify-between text-[11px] text-gray-500 dark:text-gray-400">
                                    <span>{{ $group['group'] }}</span>
                                    <span class="font-bold text-rose-600 dark:text-rose-400">{{ number_format($group['count']) }}</span>
                                </div>
                            @endforeach
                        </div>
                    </div>
                @endif
            </div>

            <div class="admin-card p-5">
                <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                    <i class="fa-solid fa-book-quran text-indigo-500"></i>
                    موارد القرآن (Islamhouse)
                </h3>
                <div class="grid grid-cols-2 gap-2 text-xs">
                    <div class="rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <div class="text-gray-500 dark:text-gray-400">تصنيفات</div>
                        <div class="font-black text-gray-900 dark:text-white">{{ number_format($stats['quran_stats']['categories']) }}</div>
                    </div>
                    <div class="rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <div class="text-gray-500 dark:text-gray-400">مؤلفون</div>
                        <div class="font-black text-gray-900 dark:text-white">{{ number_format($stats['quran_stats']['authors']) }}</div>
                    </div>
                    <div class="rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <div class="text-gray-500 dark:text-gray-400">تلاوات</div>
                        <div class="font-black text-gray-900 dark:text-white">{{ number_format($stats['quran_stats']['recitations']) }}</div>
                    </div>
                    <div class="rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                        <div class="text-gray-500 dark:text-gray-400">سور</div>
                        <div class="font-black text-gray-900 dark:text-white">{{ number_format($stats['quran_stats']['suras']) }}</div>
                    </div>
                </div>
            </div>

            <div class="admin-card p-5">
                <h3 class="mb-4 text-sm font-black text-gray-900 dark:text-white">
                    <i class="fa-solid fa-database text-cyan-500"></i>
                    جداول بيانات API المساندة
                </h3>
                <div class="space-y-2 text-xs">
                    @forelse($stats['metadata_stats'] as $row)
                        <div class="flex items-center justify-between rounded-xl bg-gray-50 px-3 py-2 dark:bg-white/[0.03]">
                            <span class="text-gray-600 dark:text-gray-300">{{ $row['label'] }}</span>
                            <span class="font-black text-gray-900 dark:text-white">{{ number_format($row['count']) }}</span>
                        </div>
                    @empty
                        <p class="text-gray-500 dark:text-gray-400">لا توجد جداول ميتاداتا متاحة حاليًا.</p>
                    @endforelse
                </div>
            </div>

            <div class="admin-card overflow-hidden border-0 bg-gradient-to-br from-gray-900 to-gray-800 p-6 text-white shadow-xl">
                <div class="mb-4 inline-flex items-center justify-center rounded-full bg-white/20 p-2">
                    <img src="https://ui-avatars.com/api/?name={{ auth()->user()->name }}&background=random&color=fff" alt="User" class="h-10 w-10 rounded-full ring-2 ring-white">
                </div>
                <div class="mb-1 text-lg font-bold">مرحبًا {{ explode(' ', auth()->user()->name)[0] }}</div>
                <p class="mb-5 text-xs text-gray-300">يمكنك إدارة المحتوى ومتابعة جودة الاستيراد من نفس الشاشة.</p>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="flex w-full items-center justify-center gap-2 rounded-xl bg-white/10 px-4 py-2.5 text-sm font-bold text-white transition hover:bg-white/20">
                        <i class="fa-solid fa-right-from-bracket"></i>
                        تسجيل الخروج
                    </button>
                </form>
            </div>
        </div>
    </div>
</x-admin-layout>
