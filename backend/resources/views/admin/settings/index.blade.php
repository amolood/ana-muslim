<x-admin-layout>
    <div class="mb-6">
        <h2 class="text-2xl font-black text-gray-800 dark:text-white mb-1">إعدادات النظام العامة</h2>
        <p class="text-sm font-medium text-gray-500 dark:text-gray-400">التحكم في هوية التطبيق والخيارات البرمجية الأساسية</p>
    </div>

    @if(session('success'))
        <div class="mb-6 bg-gradient-to-l from-emerald-500/10 to-transparent border-r-4 border-emerald-500 p-4 rounded-xl flex items-center gap-3 backdrop-blur-sm">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                <i class="fa-solid fa-check"></i>
            </div>
            <p class="text-sm font-bold text-emerald-700 dark:text-emerald-400">{{ session('success') }}</p>
        </div>
    @endif

    <div class="max-w-4xl admin-card p-6">
        <form action="{{ route('admin.settings.update') }}" method="POST">
            @csrf
            
            <div class="space-y-8">
                @foreach($settings as $setting)
                    <div class="flex flex-col md:flex-row md:items-center gap-4">
                        <div class="w-full md:w-1/3">
                            <label class="block text-sm font-bold text-gray-900 dark:text-white">{{ $setting->label ?? $setting->key }}</label>
                            <p class="text-[11px] text-gray-500 dark:text-gray-400">الرمز البرمجي: <code class="bg-gray-100 dark:bg-white/5 px-1 rounded">{{ $setting->key }}</code></p>
                        </div>
                        <div class="w-full md:w-2/3">
                            @if($setting->type === 'image')
                                <div class="flex items-center gap-4">
                                    <div class="h-16 w-16 bg-gray-100 dark:bg-white/5 rounded-xl border border-dashed border-gray-300 dark:border-white/10 flex items-center justify-center text-gray-400">
                                        <i class="fa-solid fa-image text-xl"></i>
                                    </div>
                                    <input type="text" name="{{ $setting->key }}" value="{{ $setting->value }}" placeholder="رابط الصورة الحالية"
                                        class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                                </div>
                            @else
                                <input type="text" name="{{ $setting->key }}" value="{{ $setting->value }}"
                                    class="block w-full rounded-xl border-gray-200 bg-gray-50 py-3 px-4 text-sm focus:bg-white focus:ring-2 focus:ring-blue-600 dark:bg-white/5 dark:border-transparent dark:text-white transition-all">
                            @endif
                        </div>
                    </div>
                @endforeach
            </div>

            <div class="mt-10 pt-6 border-t border-gray-100 dark:border-white/10">
                <button type="submit" class="admin-btn bg-gray-900 text-white dark:bg-white dark:text-gray-900 hover:scale-105 transition-transform">
                    <i class="fa-solid fa-floppy-disk ml-2"></i> حفظ كافة الإعدادات
                </button>
            </div>
        </form>
    </div>
</x-admin-layout>
