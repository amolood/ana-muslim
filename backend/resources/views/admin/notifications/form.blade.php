<x-admin-layout>
    <div class="mb-6">
        <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إنشاء تنبيه جديد</h2>
        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">سيصل هذا التنبيه لجميع المستخدمين بشكل فوري</p>
    </div>

    <div class="max-w-3xl admin-card p-6">
        <form action="{{ route('admin.notifications.send') }}" method="POST">
            @csrf
            
            <div class="space-y-6">
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">عنوان التنبيه</label>
                    <input type="text" name="title" required placeholder="e.g. موعد صلاة المغرب"
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">نص الرسالة</label>
                    <textarea name="message" rows="4" required placeholder="اكتب نص التنبيه هنا..."
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all"></textarea>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">نوع التنبيه</label>
                        <select name="type" class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                            <option value="general">عام</option>
                            <option value="prayer">صلاة</option>
                            <option value="announcement">إعلان</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">رابط خارجي (اختياري)</label>
                        <input type="url" name="target_url" placeholder="https://example.com"
                            class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                    </div>
                </div>
            </div>

            <div class="mt-8 pt-6 border-t border-gray-100 dark:border-white/10 flex gap-3">
                <button type="submit" class="admin-btn bg-gradient-to-r from-rose-500 to-pink-500 text-white hover:shadow-lg hover:-translate-y-0.5 transition-all">
                    <i class="fa-solid fa-paper-plane ml-2"></i> إرسال الآن
                </button>
                <a href="{{ route('admin.notifications.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300">إلغاء</a>
            </div>
        </form>
    </div>
</x-admin-layout>
