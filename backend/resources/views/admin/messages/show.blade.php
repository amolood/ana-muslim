<x-admin-layout>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
            <a href="{{ route('admin.messages.index') }}" class="inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 mb-2">
                <i class="fa-solid fa-arrow-right"></i> العودة إلى الرسائل
            </a>
            <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">تفاصيل الرسالة</h2>
        </div>
        <div class="flex items-center gap-3">
            <a href="mailto:{{ $message->email }}?subject=رد: {{ $message->subject }}" class="admin-btn bg-gradient-to-r from-emerald-500 to-emerald-600 text-white shadow-lg shadow-emerald-500/30 hover:shadow-emerald-500/50 hover:-translate-y-0.5 transition-all">
                <i class="fa-solid fa-reply ml-2"></i> رد بالبريد
            </a>
            <form method="POST" action="{{ route('admin.messages.destroy', $message->id) }}" onsubmit="return confirm('هل أنت متأكد من حذف هذه الرسالة؟')">
                @csrf
                @method('DELETE')
                <button type="submit" class="admin-btn bg-rose-500 text-white hover:bg-rose-600 transition-colors">
                    <i class="fa-solid fa-trash ml-2"></i> حذف
                </button>
            </form>
        </div>
    </div>

    <div class="admin-card p-6 md:p-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <!-- Sender Info -->
            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">الاسم</label>
                    <p class="text-base font-bold text-gray-900 dark:text-white">{{ $message->name }}</p>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">البريد الإلكتروني</label>
                    <a href="mailto:{{ $message->email }}" class="text-base text-emerald-600 dark:text-emerald-400 hover:underline">{{ $message->email }}</a>
                </div>
                @if($message->phone)
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">الهاتف</label>
                    <a href="tel:{{ $message->phone }}" class="text-base font-medium text-gray-900 dark:text-white hover:text-emerald-500 transition-colors" dir="ltr">{{ $message->phone }}</a>
                </div>
                @endif
                @if($message->whatsapp)
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">واتساب</label>
                    <a href="https://wa.me/{{ preg_replace('/\D/', '', $message->whatsapp) }}" target="_blank" class="text-base font-medium text-gray-900 dark:text-white hover:text-emerald-500 transition-colors inline-block" dir="ltr">
                        <i class="fa-brands fa-whatsapp ml-1 text-emerald-500"></i> {{ $message->whatsapp }}
                    </a>
                </div>
                @endif
            </div>

            <!-- Meta Info -->
            <div class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">الموضوع</label>
                    @php
                        $subjectLabels = [
                            'bug' => ['label' => 'الإبلاغ عن مشكلة', 'color' => 'rose'],
                            'feature' => ['label' => 'اقتراح ميزة جديدة', 'color' => 'blue'],
                            'support' => ['label' => 'طلب دعم فني', 'color' => 'amber'],
                            'feedback' => ['label' => 'ملاحظات وتقييم', 'color' => 'purple'],
                            'other' => ['label' => 'أخرى', 'color' => 'gray'],
                        ];
                        $subj = $subjectLabels[$message->subject] ?? $subjectLabels['other'];
                    @endphp
                    <span class="inline-flex items-center gap-1.5 rounded-lg bg-{{ $subj['color'] }}-50 px-2.5 py-1 text-xs font-bold text-{{ $subj['color'] }}-600 ring-1 ring-inset ring-{{ $subj['color'] }}-600/10 dark:bg-{{ $subj['color'] }}-500/10 dark:text-{{ $subj['color'] }}-400">
                        {{ $subj['label'] }}
                    </span>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">تاريخ الإرسال</label>
                    <p class="text-sm text-gray-700 dark:text-gray-300">{{ $message->created_at->format('Y-m-d H:i:s') }}</p>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">الحالة</label>
                    @if($message->is_read)
                        <span class="inline-flex items-center gap-1.5 text-sm text-gray-500 dark:text-gray-400">
                            <i class="fa-solid fa-check-double text-emerald-500"></i> مقروءة {{ $message->read_at ? '- ' . $message->read_at->format('Y-m-d H:i') : '' }}
                        </span>
                    @else
                        <span class="inline-flex items-center gap-1.5 text-sm text-emerald-600 dark:text-emerald-400">
                            <span class="h-2 w-2 rounded-full bg-emerald-500"></span> جديدة
                        </span>
                    @endif
                </div>
                @if($message->ip_address)
                    <div>
                        <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-1">عنوان IP</label>
                        <p class="text-sm text-gray-500 dark:text-gray-400 font-mono">{{ $message->ip_address }}</p>
                    </div>
                @endif
            </div>
        </div>

        <!-- Message Body -->
        <div class="border-t border-gray-100 dark:border-white/10 pt-6">
            <label class="block text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-3">نص الرسالة</label>
            <div class="bg-gray-50 dark:bg-white/5 rounded-xl p-6 text-sm leading-relaxed text-gray-800 dark:text-gray-200 whitespace-pre-wrap">{{ $message->message }}</div>
        </div>
    </div>
</x-admin-layout>
