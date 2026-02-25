<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إرسال التنبيهات (Notifications)</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">إرسال رسائل فورية لجميع مستخدمي التطبيق والموقع</p>
        </div>
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.notifications.create') }}" class="admin-btn bg-gradient-to-r from-rose-500 to-pink-500 text-white shadow-lg shadow-rose-500/30 hover:shadow-rose-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-paper-plane ml-2"></i> إنشاء تنبيه جديد
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

    @if(session('error'))
        <div class="mb-6 bg-gradient-to-l from-rose-500/10 to-transparent border-r-4 border-rose-500 p-4 rounded-xl flex items-center gap-3 backdrop-blur-sm">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-rose-500/20 text-rose-600 dark:text-rose-400">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <p class="text-sm font-bold text-rose-700 dark:text-rose-400">{{ session('error') }}</p>
        </div>
    @endif

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">العنوان</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الرسالة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">النوع</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">تاريخ الإرسال</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($notifications as $notification)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors">
                            <td class="px-6 py-4">
                                <span class="font-bold text-gray-900 dark:text-white">{{ $notification->title }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <p class="text-xs text-gray-500 dark:text-gray-400 line-clamp-1 max-w-xs">{{ $notification->message }}</p>
                            </td>
                            <td class="px-6 py-4">
                                <span class="inline-flex items-center gap-1.5 rounded-lg bg-blue-50 px-2.5 py-1 text-xs font-bold text-blue-600 ring-1 ring-inset ring-blue-600/10 dark:bg-blue-500/10 dark:text-blue-400">
                                    {{ $notification->type }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-xs text-gray-500 dark:text-gray-400">
                                {{ $notification->sent_at ? $notification->sent_at->format('Y-m-d H:i') : 'لم يتم الإرسال' }}
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-6 py-10 text-center text-gray-500 dark:text-gray-400">لا يوجد سجل تنبيهات حالياً.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($notifications->hasPages())
            <div class="p-4 border-t border-gray-100 dark:border-white/10">
                {{ $notifications->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
