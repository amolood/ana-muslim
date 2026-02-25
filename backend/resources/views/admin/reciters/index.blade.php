<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إدارة قراء القرآن الكريم</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">التحكم في قائمة القراء وسيرفرات الصوت المتاحة في التطبيق</p>
        </div>
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.reciters.create') }}" class="admin-btn bg-gradient-to-r from-blue-500 to-indigo-500 text-white shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-microphone-lines ml-2"></i> إضافة قارئ جديد
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

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider w-20"># ID</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">اسم القارئ</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">المسار (Path)</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">رابط السيرفر (Base URL)</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الحالة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider text-left w-32">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($reciters as $reciter)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center justify-center rounded-lg bg-gray-100 px-2.5 py-1 text-[11px] font-mono font-bold text-gray-600 dark:bg-white/5 dark:text-gray-400">
                                    {{ $reciter->id }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="font-bold text-gray-900 dark:text-white">{{ $reciter->name }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <code class="text-xs text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20 px-1.5 py-0.5 rounded">{{ $reciter->path }}</code>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-xs text-gray-500 dark:text-gray-400">{{ $reciter->base_url }}</span>
                            </td>
                            <td class="px-6 py-4">
                                @if($reciter->is_active)
                                    <span class="inline-flex items-center gap-1.5 rounded-lg bg-emerald-50 px-2.5 py-1 text-xs font-bold text-emerald-600 ring-1 ring-inset ring-emerald-600/10 dark:bg-emerald-500/10 dark:text-emerald-400">
                                        نشط
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1.5 rounded-lg bg-gray-50 px-2.5 py-1 text-xs font-bold text-gray-500 ring-1 ring-inset ring-gray-600/10 dark:bg-white/5 dark:text-gray-400">
                                        معطل
                                    </span>
                                @endif
                            </td>
                            <td class="px-6 py-4 text-left">
                                <div class="flex items-center justify-end gap-1.5">
                                    <a href="{{ route('admin.reciters.edit', $reciter->id) }}" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:ring-blue-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-blue-500/20 dark:hover:text-blue-400 transition-all">
                                        <i class="fa-solid fa-pen"></i>
                                    </a>
                                    <form action="{{ route('admin.reciters.destroy', $reciter->id) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذا القارئ؟');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="flex h-9 w-9 items-center justify-center rounded-xl bg-white text-gray-400 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-red-50 hover:text-red-600 hover:ring-red-200 dark:bg-white/5 dark:ring-transparent dark:hover:bg-red-500/20 dark:hover:text-red-400 transition-all">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-6 py-10 text-center text-gray-500 dark:text-gray-400">لا يوجد قراء مسجلين حالياً.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($reciters->hasPages())
            <div class="p-4 border-t border-gray-100 dark:border-white/10">
                {{ $reciters->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
