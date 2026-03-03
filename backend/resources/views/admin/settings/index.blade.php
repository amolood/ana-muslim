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
        <form action="{{ route('admin.settings.update') }}" method="POST" enctype="multipart/form-data">
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
                                {{-- Hidden fallback preserves current URL when no new file is chosen --}}
                                <input type="hidden" name="{{ $setting->key }}" value="{{ $setting->value }}">
                                <div x-data="{ preview: '{{ $setting->value }}' }" class="flex items-center gap-4">
                                    {{-- Live preview thumbnail --}}
                                    <div class="h-16 w-16 shrink-0 rounded-xl border border-dashed border-gray-300 dark:border-white/10 overflow-hidden bg-gray-100 dark:bg-white/5 flex items-center justify-center">
                                        <template x-if="preview">
                                            <img :src="preview" class="h-full w-full object-cover">
                                        </template>
                                        <template x-if="!preview">
                                            <i class="fa-solid fa-image text-xl text-gray-400"></i>
                                        </template>
                                    </div>
                                    {{-- File picker --}}
                                    <div class="flex-1 min-w-0">
                                        <input type="file" name="image_files[{{ $setting->key }}]" accept="image/*"
                                            @change="preview = URL.createObjectURL($event.target.files[0])"
                                            class="block w-full text-sm text-gray-500 dark:text-gray-400
                                                file:ml-0 file:mr-3 file:py-2 file:px-4 file:rounded-lg file:border-0
                                                file:text-sm file:font-medium file:bg-blue-600 file:text-white
                                                hover:file:bg-blue-700 file:cursor-pointer cursor-pointer">
                                        <p x-show="preview" x-text="preview" class="mt-1 text-[11px] text-gray-400 truncate"></p>
                                    </div>
                                </div>
                            @elseif($setting->type === 'boolean')
                                {{-- Hidden input ensures "0" is sent when checkbox is unchecked --}}
                                <input type="hidden" name="{{ $setting->key }}" value="0">
                                <label class="flex items-center gap-3 cursor-pointer w-fit">
                                    <input type="checkbox" name="{{ $setting->key }}" value="1" {{ $setting->value == '1' ? 'checked' : '' }}
                                        class="w-5 h-5 rounded accent-blue-600 cursor-pointer">
                                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                                        {{ $setting->value == '1' ? 'مفعّل' : 'معطّل' }}
                                    </span>
                                </label>
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
