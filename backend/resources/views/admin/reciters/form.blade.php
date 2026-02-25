<x-admin-layout>
    <div class="mb-6">
        <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">{{ isset($reciter) ? 'تعديل قارئ' : 'إضافة قارئ جديد' }}</h2>
        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">أدخل تفاصيل القارئ ومسارات السيرفر الصوتية</p>
    </div>

    <div class="max-w-4xl admin-card p-6">
        <form action="{{ isset($reciter) ? route('admin.reciters.update', $reciter->id) : route('admin.reciters.store') }}" method="POST">
            @csrf
            @if(isset($reciter))
                @method('PUT')
            @endif

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">اسم القارئ</label>
                    <input type="text" name="name" value="{{ old('name', $reciter->name ?? '') }}" required
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">ترتيب العرض</label>
                    <input type="number" name="display_order" value="{{ old('display_order', $reciter->display_order ?? 0) }}"
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">المسار (Path)</label>
                    <input type="text" name="path" value="{{ old('path', $reciter->path ?? '') }}" required placeholder="e.g. maher/"
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 dark:text-gray-200 mb-2">رابط السيرفر (Base URL)</label>
                    <input type="url" name="base_url" value="{{ old('base_url', $reciter->base_url ?? '') }}" required placeholder="https://server12.mp3quran.net/"
                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                </div>

                <div class="md:col-span-2">
                    <label class="flex items-center gap-3 cursor-pointer">
                        <input type="hidden" name="is_active" value="0">
                        <input type="checkbox" name="is_active" value="1" {{ old('is_active', $reciter->is_active ?? true) ? 'checked' : '' }}
                            class="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500">
                        <span class="text-sm font-bold text-gray-700 dark:text-gray-200">تفعيل القارئ في التطبيق</span>
                    </label>
                </div>
            </div>

            <div class="mt-8 pt-6 border-t border-gray-100 dark:border-white/10 flex gap-3">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    {{ isset($reciter) ? 'حفظ التغييرات' : 'إضافة القارئ' }}
                </button>
                <a href="{{ route('admin.reciters.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300">إلغاء</a>
            </div>
        </form>
    </div>
</x-admin-layout>
