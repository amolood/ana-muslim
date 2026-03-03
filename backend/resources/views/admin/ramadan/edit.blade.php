<x-admin-layout>
    <div class="mb-6 flex items-center gap-3">
        <a href="{{ route('admin.ramadan.show', $day->city_key) }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-emerald-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-emerald-400 transition-colors">
            <i class="fa-solid fa-arrow-right"></i>
        </a>
        <div>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                تعديل يوم: {{ $day->date->format('d M Y') }}
            </h2>
            <p class="text-xs text-gray-400">{{ $day->city_key }} &mdash; {{ $day->hijri_readable_ar ?? $day->hijri_date }}</p>
        </div>
    </div>

    <form action="{{ route('admin.ramadan.update', $day->id) }}" method="POST">
        @csrf @method('PUT')

        {{-- Timing Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">أوقات الإمساك والإفطار</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-3">
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">وقت السحور <span class="text-red-500">*</span></label>
                    <input type="text" name="sahur_time" value="{{ old('sahur_time', $day->sahur_time) }}" required placeholder="04:15"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('sahur_time') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">وقت الإفطار <span class="text-red-500">*</span></label>
                    <input type="text" name="iftar_time" value="{{ old('iftar_time', $day->iftar_time) }}" required placeholder="18:42"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('iftar_time') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">مدة الصوم</label>
                    <div class="grid grid-cols-2 gap-2">
                        <input type="text" name="fasting_duration" value="{{ old('fasting_duration', $day->fasting_duration) }}" placeholder="14h 27m"
                            class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <input type="text" name="fasting_duration_ar" value="{{ old('fasting_duration_ar', $day->fasting_duration_ar) }}" placeholder="١٤س ٢٧د"
                            class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    </div>
                </div>
                <div class="flex items-center gap-3 md:col-span-3">
                    <input type="hidden" name="is_white_day" value="0">
                    <input type="checkbox" name="is_white_day" id="is_white_day" value="1" {{ old('is_white_day', $day->is_white_day) ? 'checked' : '' }}
                        class="h-5 w-5 rounded accent-amber-500 cursor-pointer">
                    <label for="is_white_day" class="text-sm font-medium text-gray-700 dark:text-gray-300 cursor-pointer">
                        يوم من الأيام البيض (13 - 14 - 15 من الشهر)
                    </label>
                </div>
            </div>
        </div>

        {{-- Dua Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">الدعاء اليومي</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان الدعاء (EN)</label>
                    <input type="text" name="dua_title" value="{{ old('dua_title', $day->dua_title) }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان الدعاء (AR)</label>
                    <input type="text" name="dua_title_ar" value="{{ old('dua_title_ar', $day->dua_title_ar) }}" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">نص الدعاء (عربي)</label>
                    <textarea name="dua_arabic" rows="3" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white leading-relaxed">{{ old('dua_arabic', $day->dua_arabic) }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الترجمة (EN)</label>
                    <textarea name="dua_translation" rows="2"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('dua_translation', $day->dua_translation) }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">المرجع</label>
                    <input type="text" name="dua_reference" value="{{ old('dua_reference', $day->dua_reference) }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
            </div>
        </div>

        {{-- Hadith Section --}}
        <div class="admin-card p-6 mb-6">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">الحديث الشريف</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">نص الحديث (عربي)</label>
                    <textarea name="hadith_arabic" rows="3" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white leading-relaxed">{{ old('hadith_arabic', $day->hadith_arabic) }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الترجمة (EN)</label>
                    <textarea name="hadith_english" rows="2"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('hadith_english', $day->hadith_english) }}</textarea>
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">المصدر</label>
                    <input type="text" name="hadith_source" value="{{ old('hadith_source', $day->hadith_source) }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الدرجة</label>
                    <input type="text" name="hadith_grade" value="{{ old('hadith_grade', $day->hadith_grade) }}" placeholder="صحيح"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
            </div>
        </div>

        <div class="flex items-center gap-4">
            <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                <i class="fa-solid fa-save ml-2"></i> حفظ التعديلات
            </button>
            <a href="{{ route('admin.ramadan.show', $day->city_key) }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                إلغاء
            </a>
        </div>
    </form>
</x-admin-layout>
