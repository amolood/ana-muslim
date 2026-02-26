<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">الرسائل الواردة</h2>
            <p class="text-sm font-medium text-gray-500 dark:text-gray-400">رسائل التواصل من زوار الموقع والتطبيق
                @if($unreadCount > 0)
                    <span class="inline-flex items-center gap-1 mr-2 rounded-lg bg-rose-50 px-2.5 py-1 text-xs font-bold text-rose-600 ring-1 ring-inset ring-rose-600/10 dark:bg-rose-500/10 dark:text-rose-400">
                        {{ $unreadCount }} غير مقروءة
                    </span>
                @endif
            </p>
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

    <!-- Filters -->
    <div class="mb-6 admin-card p-4">
        <form method="GET" action="{{ route('admin.messages.index') }}" class="flex flex-wrap items-end gap-4">
            <div class="flex-1 min-w-[200px]">
                <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 mb-1">بحث</label>
                <input type="text" name="search" value="{{ request('search') }}" placeholder="بحث بالاسم أو البريد أو الرسالة..."
                    class="block w-full rounded-xl border-gray-200 bg-gray-50 py-2.5 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
            </div>
            <div class="w-40">
                <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 mb-1">الموضوع</label>
                <select name="subject" class="block w-full rounded-xl border-gray-200 bg-gray-50 py-2.5 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                    <option value="">الكل</option>
                    <option value="bug" {{ request('subject') === 'bug' ? 'selected' : '' }}>مشكلة</option>
                    <option value="feature" {{ request('subject') === 'feature' ? 'selected' : '' }}>ميزة جديدة</option>
                    <option value="support" {{ request('subject') === 'support' ? 'selected' : '' }}>دعم فني</option>
                    <option value="feedback" {{ request('subject') === 'feedback' ? 'selected' : '' }}>ملاحظات</option>
                    <option value="other" {{ request('subject') === 'other' ? 'selected' : '' }}>أخرى</option>
                </select>
            </div>
            <div class="w-40">
                <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 mb-1">الحالة</label>
                <select name="status" class="block w-full rounded-xl border-gray-200 bg-gray-50 py-2.5 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-emerald-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                    <option value="">الكل</option>
                    <option value="unread" {{ request('status') === 'unread' ? 'selected' : '' }}>غير مقروءة</option>
                    <option value="read" {{ request('status') === 'read' ? 'selected' : '' }}>مقروءة</option>
                </select>
            </div>
            <button type="submit" class="admin-btn bg-emerald-500 text-white hover:bg-emerald-600 transition-colors">
                <i class="fa-solid fa-search ml-1"></i> بحث
            </button>
            @if(request()->hasAny(['search', 'subject', 'status']))
                <a href="{{ route('admin.messages.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300">مسح</a>
            @endif
        </form>
    </div>

    <div class="admin-card overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-right text-sm border-collapse">
                <thead>
                    <tr class="bg-gray-50/80 text-gray-500 dark:bg-white/5 dark:text-gray-400 border-b border-gray-100 dark:border-white/10">
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الحالة</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الاسم</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">البريد</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الموضوع</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">التاريخ</th>
                        <th class="px-6 py-4 font-bold text-xs uppercase tracking-wider">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100 dark:divide-white/10">
                    @forelse($messages as $message)
                        <tr class="group hover:bg-gray-50/80 dark:hover:bg-white/[0.02] transition-colors {{ !$message->is_read ? 'bg-emerald-50/30 dark:bg-emerald-500/5' : '' }}">
                            <td class="px-6 py-4">
                                @if(!$message->is_read)
                                    <span class="inline-flex h-2.5 w-2.5 rounded-full bg-emerald-500" title="غير مقروءة"></span>
                                @else
                                    <span class="inline-flex h-2.5 w-2.5 rounded-full bg-gray-300 dark:bg-gray-600" title="مقروءة"></span>
                                @endif
                            </td>
                            <td class="px-6 py-4">
                                <span class="font-bold text-gray-900 dark:text-white {{ !$message->is_read ? 'text-emerald-700 dark:text-emerald-400' : '' }}">{{ $message->name }}</span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-xs text-gray-500 dark:text-gray-400">{{ $message->email }}</span>
                            </td>
                            <td class="px-6 py-4">
                                @php
                                    $subjectLabels = [
                                        'bug' => ['label' => 'مشكلة', 'color' => 'rose'],
                                        'feature' => ['label' => 'ميزة جديدة', 'color' => 'blue'],
                                        'support' => ['label' => 'دعم فني', 'color' => 'amber'],
                                        'feedback' => ['label' => 'ملاحظات', 'color' => 'purple'],
                                        'other' => ['label' => 'أخرى', 'color' => 'gray'],
                                    ];
                                    $subj = $subjectLabels[$message->subject] ?? $subjectLabels['other'];
                                @endphp
                                <span class="inline-flex items-center gap-1.5 rounded-lg bg-{{ $subj['color'] }}-50 px-2.5 py-1 text-xs font-bold text-{{ $subj['color'] }}-600 ring-1 ring-inset ring-{{ $subj['color'] }}-600/10 dark:bg-{{ $subj['color'] }}-500/10 dark:text-{{ $subj['color'] }}-400">
                                    {{ $subj['label'] }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-xs text-gray-500 dark:text-gray-400">
                                {{ $message->created_at->format('Y-m-d H:i') }}
                            </td>
                            <td class="px-6 py-4">
                                <a href="{{ route('admin.messages.show', $message->id) }}" class="inline-flex items-center gap-1 text-xs font-bold text-emerald-600 hover:text-emerald-700 dark:text-emerald-400">
                                    <i class="fa-solid fa-eye"></i> عرض
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-6 py-10 text-center text-gray-500 dark:text-gray-400">لا توجد رسائل حالياً.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($messages->hasPages())
            <div class="p-4 border-t border-gray-100 dark:border-white/10">
                {{ $messages->links() }}
            </div>
        @endif
    </div>
</x-admin-layout>
