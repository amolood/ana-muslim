<x-admin-layout>
    <!-- Header Section -->
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">
                {{ $item ? 'مرفقات المادة: ' . $item->title : 'إدارة المرفقات' }}
            </h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">
                إدارة الملفات الصوتية، المرئية، والكتب المربوطة بالمواد العلمية
            </p>
        </div>
        <div class="flex items-center gap-3">
            @if($item)
                <a href="{{ route('admin.items.index') }}" class="admin-btn bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10 dark:ring-transparent transition-all">
                    <i class="fa-solid fa-arrow-right ml-2 text-gray-400"></i> العودة للمواد
                </a>
            @endif
            <a href="{{ route('admin.attachments.create', ['item_id' => $item ? $item->id : '']) }}" class="admin-btn bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg shadow-purple-500/30 hover:shadow-purple-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-cloud-arrow-up ml-2"></i> رفع مرفق جديد
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
    <div class="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Stat Card 1: Total Attachments -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-gray-500 to-slate-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">إجمالي المرفقات</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['total'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-gray-100 text-xl text-gray-600 group-hover:scale-110 transition-transform dark:bg-white/10 dark:text-gray-400">
                    <i class="fa-solid fa-copy"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400">
                جميع الملفات المرفروعة
            </div>
        </div>

        <!-- Stat Card 2: Audio Files -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-purple-500 to-pink-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">ملفات صوتية</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['audio'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-purple-50 text-xl text-purple-600 group-hover:scale-110 transition-transform dark:bg-purple-900/20 dark:text-purple-400">
                    <i class="fa-solid fa-music"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400 flex justify-between items-center">
                <span>(MP3, وغيرها)</span>
            </div>
        </div>

        <!-- Stat Card 3: Video Files -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-blue-500 to-cyan-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">مقاطع مرئية</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['video'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-xl text-blue-600 group-hover:scale-110 transition-transform dark:bg-blue-900/20 dark:text-blue-400">
                    <i class="fa-solid fa-video"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400 flex justify-between items-center">
                <span>(MP4, YouTube)</span>
            </div>
        </div>

        <!-- Stat Card 4: Documents -->
        <div class="admin-card overflow-hidden relative group">
            <div class="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-rose-500 to-red-500"></div>
            <div class="p-5 flex items-start justify-between">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1">كتب وملفات PDF</p>
                    <h3 class="text-3xl font-black text-gray-800 dark:text-white">{{ number_format($stats['docs'] ?? 0) }}</h3>
                </div>
                <div class="flex h-12 w-12 items-center justify-center rounded-2xl bg-rose-50 text-xl text-rose-600 group-hover:scale-110 transition-transform dark:bg-rose-900/20 dark:text-rose-400">
                    <i class="fa-solid fa-book-bookmark"></i>
                </div>
            </div>
            <div class="bg-gray-50 dark:bg-white/5 py-2 px-5 text-xs font-medium text-gray-500 dark:text-gray-400 flex justify-between items-center">
                <span>(PDF, DOCX)</span>
            </div>
        </div>
    </div>

    <!-- Main Table -->
    <div class="admin-card overflow-hidden">
        @if($attachments->count() > 0)
            <div class="overflow-x-auto">
                <table class="w-full text-right text-sm border-collapse">
                    <thead>
                        <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider w-24 text-center">الترتيب</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">النوع / التفاصيل</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">المادة المرتبطة</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-center">الرابط</th>
                            <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left w-32">الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                        @foreach($attachments as $attachment)
                            <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                                <!-- Order Column -->
                                <td class="px-6 py-4 text-center">
                                    <span class="inline-flex items-center justify-center rounded-lg bg-gray-100 px-2.5 py-1 text-[11px] font-mono font-bold text-gray-600 dark:bg-white/5 dark:text-gray-400">
                                        {{ $attachment->order ?? '-' }}
                                    </span>
                                </td>
                                
                                <!-- Extension & Details -->
                                <td class="px-6 py-4">
                                    @php
                                        $ext = strtolower($attachment->extension_type ?? '');
                                        $icon = 'fa-file';
                                        $color = 'text-gray-500 bg-gray-100 ring-gray-200 dark:bg-white/10 dark:ring-white/10 dark:text-gray-400';
                                        
                                        if (in_array($ext, ['mp3', 'مقطع صوتي', 'audio'])) {
                                            $icon = 'fa-music';
                                            $color = 'text-purple-600 bg-purple-50 ring-purple-100 dark:text-purple-400 dark:bg-purple-500/10 dark:ring-purple-500/20';
                                        } elseif (in_array($ext, ['mp4', 'مقطع مرئي', 'video', 'youtube'])) {
                                            $icon = 'fa-video';
                                            $color = 'text-blue-600 bg-blue-50 ring-blue-100 dark:text-blue-400 dark:bg-blue-500/10 dark:ring-blue-500/20';
                                        } elseif (in_array($ext, ['pdf', 'doc', 'docx', 'book', 'كتاب'])) {
                                            $icon = 'fa-file-pdf';
                                            $color = 'text-rose-600 bg-rose-50 ring-rose-100 dark:text-rose-400 dark:bg-rose-500/10 dark:ring-rose-500/20';
                                        }
                                    @endphp
                                    <div class="flex items-start gap-4">
                                        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl {{ $color }} ring-1 ring-inset shadow-sm">
                                            <i class="fa-solid {{ $icon }}"></i>
                                        </div>
                                        <div>
                                            <div class="flex items-center gap-2 mb-1">
                                                <span class="font-bold text-gray-900 dark:text-white uppercase tracking-wider text-xs">{{ $attachment->extension_type ?? 'غير محدد' }}</span>
                                                <span class="text-gray-300 dark:text-gray-600">•</span>
                                                <span class="text-[11px] font-mono text-gray-500 dark:text-gray-400" dir="ltr">{{ $attachment->size ?? '--' }}</span>
                                            </div>
                                            @if($attachment->description)
                                                <p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-1 max-w-[200px]" title="{{ $attachment->description }}">
                                                    {{ $attachment->description }}
                                                </p>
                                            @endif
                                        </div>
                                    </div>
                                </td>

                                <!-- Parent Item -->
                                <td class="px-6 py-4">
                                    @if($attachment->item)
                                        <a href="{{ route('admin.items.edit', $attachment->item->id) }}" class="group/item flex items-center gap-2">
                                            <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-gray-50 text-gray-400 group-hover/item:bg-blue-50 group-hover/item:text-blue-600 dark:bg-white/5 dark:group-hover/item:bg-blue-500/20 transition-colors">
                                                <i class="fa-solid fa-link text-xs"></i>
                                            </div>
                                            <span class="font-bold text-gray-700 dark:text-gray-300 group-hover/item:text-blue-600 dark:group-hover/item:text-blue-400 line-clamp-1 max-w-[250px] transition-colors" title="{{ $attachment->item->title }}">
                                                {{ $attachment->item->title }}
                                            </span>
                                        </a>
                                    @else
                                        <span class="inline-flex items-center gap-1.5 rounded bg-gray-50 px-2 py-1 text-xs font-medium text-gray-400 dark:bg-white/5">
                                            <i class="fa-solid fa-unlink"></i> غير مرتبط
                                        </span>
                                    @endif
                                </td>
                                
                                <!-- File Link -->
                                <td class="px-6 py-4 text-center">
                                    <a href="{{ $attachment->url }}" target="_blank" class="inline-flex items-center justify-center h-8 w-8 rounded-lg bg-emerald-50 text-emerald-600 hover:bg-emerald-500 hover:text-white dark:bg-emerald-500/10 dark:text-emerald-400 dark:hover:bg-emerald-500 dark:hover:text-white transition-all tooltip" title="استعراض المرفق في المتصفح">
                                        <i class="fa-solid fa-arrow-up-right-from-square text-xs"></i>
                                    </a>
                                </td>
                                
                                <!-- Actions -->
                                <td class="px-6 py-4 text-left">
                                    <div class="flex items-center justify-end gap-1.5 opacity-100 lg:opacity-60 xl:opacity-100 group-hover:opacity-100 transition-opacity">
                                        <a href="{{ route('admin.attachments.edit', $attachment->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:ring-blue-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400 dark:hover:ring-transparent transition-all" title="تعديل المرفق">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <form action="{{ route('admin.attachments.destroy', $attachment->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذا المرفق بشكل نهائي؟');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-red-50 hover:text-red-600 hover:ring-red-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400 dark:hover:ring-transparent transition-all" title="حذف المرفق">
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
            
            @if($attachments->hasPages())
                <div class="border-t border-gray-100 p-4 dark:border-white/10 bg-gray-50/50 dark:bg-white/[0.02]">
                    {{ $attachments->withQueryString()->links() }}
                </div>
            @endif

        @else
            <!-- Handled Empty State Without Rebuilding DOM/Colspans -->
            <div class="px-6 py-16 text-center">
                <div class="flex flex-col items-center justify-center">
                    <div class="mb-4 flex h-20 w-20 items-center justify-center rounded-full bg-purple-50 dark:bg-purple-900/20">
                        <i class="fa-solid fa-photo-film text-3xl text-purple-500 dark:text-purple-400"></i>
                    </div>
                    <h3 class="mt-2 text-sm font-bold text-gray-900 dark:text-white">لا توجد مرفقات مرتبطة</h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">لم يتم العثور على أية ملفات مرفقة، يمكنك البدء بإضافة ملفات فيديو أو صوتيات الآن.</p>
                    <div class="mt-6">
                        <a href="{{ route('admin.attachments.create', ['item_id' => $item ? $item->id : '']) }}" class="admin-btn bg-purple-600 text-white hover:bg-purple-700">
                            <i class="fa-solid fa-cloud-arrow-up ml-2"></i> رفع أول مرفق
                        </a>
                    </div>
                </div>
            </div>
        @endif
    </div>
</x-admin-layout>
