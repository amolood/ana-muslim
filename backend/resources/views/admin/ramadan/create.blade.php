<x-admin-layout>
    <div class="mb-6 flex items-center gap-3">
        <a href="{{ $cityKey ? route('admin.ramadan.show', $cityKey) : route('admin.ramadan.index') }}"
            class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-emerald-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-emerald-400 transition-colors">
            <i class="fa-solid fa-arrow-right"></i>
        </a>
        <div>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                {{ $cityKey ? 'إضافة يوم إلى مدينة: ' . $cityKey : 'إضافة مدينة جديدة' }}
            </h2>
            <p class="text-xs text-gray-400">سيتم إنشاء المدينة تلقائياً عند إضافة أول يوم</p>
        </div>
    </div>

    @if($errors->any())
        <div class="mb-6 bg-gradient-to-l from-red-500/10 to-transparent border-r-4 border-red-500 p-4 rounded-xl">
            <p class="text-sm font-bold text-red-700 dark:text-red-400 mb-2">يرجى تصحيح الأخطاء التالية:</p>
            <ul class="list-disc list-inside space-y-1">
                @foreach($errors->all() as $error)
                    <li class="text-xs text-red-600 dark:text-red-400">{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('admin.ramadan.store') }}" method="POST">
        @csrf

        {{-- City Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">بيانات المدينة</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-3"
                 x-data="{
                     selected: '{{ old('city_key', $cityKey) }}',
                     cities: {{ $existingCities->toJson() }},
                     isNew: {{ ($cityKey === '' && !old('city_key')) ? 'true' : 'false' }},
                     fillCity(key) {
                         const city = this.cities.find(c => c.city_key === key);
                         if (city) {
                             document.getElementById('lat').value = city.lat;
                             document.getElementById('lon').value = city.lon;
                         }
                     }
                 }">

                <div class="md:col-span-1">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">
                        المدينة <span class="text-red-500">*</span>
                    </label>
                    {{-- Existing city picker --}}
                    @if($existingCities->isNotEmpty())
                        <select x-show="!isNew"
                            @change="selected = $event.target.value; fillCity($event.target.value)"
                            class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white mb-2">
                            <option value="">— اختر مدينة موجودة —</option>
                            @foreach($existingCities as $city)
                                <option value="{{ $city->city_key }}" {{ old('city_key', $cityKey) === $city->city_key ? 'selected' : '' }}>
                                    {{ $city->city_key }}
                                </option>
                            @endforeach
                        </select>
                    @endif
                    {{-- Manual city key input (always visible if no existing or when adding new) --}}
                    <input type="text" name="city_key" id="city_key"
                        :value="isNew ? '' : selected"
                        value="{{ old('city_key', $cityKey) }}"
                        required placeholder="mecca / riyadh / cairo …"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @if($existingCities->isNotEmpty())
                        <button type="button" @click="isNew = !isNew; selected = ''"
                            class="mt-2 text-xs text-blue-500 hover:underline" x-text="isNew ? '← اختر من الموجودة' : '+ إضافة مدينة جديدة'"></button>
                    @endif
                    @error('city_key') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="lat" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">خط العرض (Lat) <span class="text-red-500">*</span></label>
                    <input type="number" step="any" name="lat" id="lat" value="{{ old('lat') }}" required placeholder="21.3891"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('lat') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="lon" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">خط الطول (Lon) <span class="text-red-500">*</span></label>
                    <input type="number" step="any" name="lon" id="lon" value="{{ old('lon') }}" required placeholder="39.8579"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('lon') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        {{-- Date & Day Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">التاريخ</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">التاريخ الميلادي <span class="text-red-500">*</span></label>
                    <input type="date" name="date" value="{{ old('date') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('date') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">اسم اليوم (EN)</label>
                    <input type="text" name="day_name" value="{{ old('day_name') }}" placeholder="Monday"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">اسم اليوم (AR)</label>
                    <input type="text" name="day_name_ar" value="{{ old('day_name_ar') }}" placeholder="الاثنين" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">التاريخ الهجري</label>
                    <input type="text" name="hijri_date" value="{{ old('hijri_date') }}" placeholder="1446-09-01"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الهجري مقروء (EN)</label>
                    <input type="text" name="hijri_readable" value="{{ old('hijri_readable') }}" placeholder="1 Ramadan 1446"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الهجري مقروء (AR)</label>
                    <input type="text" name="hijri_readable_ar" value="{{ old('hijri_readable_ar') }}" placeholder="١ رمضان ١٤٤٦" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
            </div>
        </div>

        {{-- Timing Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">أوقات الإمساك والإفطار</h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-3">
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">وقت السحور <span class="text-red-500">*</span></label>
                    <input type="text" name="sahur_time" value="{{ old('sahur_time') }}" required placeholder="04:15"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('sahur_time') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">وقت الإفطار <span class="text-red-500">*</span></label>
                    <input type="text" name="iftar_time" value="{{ old('iftar_time') }}" required placeholder="18:42"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('iftar_time') <p class="mt-1 text-xs text-red-500">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">مدة الصوم</label>
                    <div class="grid grid-cols-2 gap-2">
                        <input type="text" name="fasting_duration" value="{{ old('fasting_duration') }}" placeholder="14h 27m"
                            class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <input type="text" name="fasting_duration_ar" value="{{ old('fasting_duration_ar') }}" placeholder="١٤س ٢٧د"
                            class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    </div>
                </div>
                <div class="flex items-center gap-3 md:col-span-3">
                    <input type="hidden" name="is_white_day" value="0">
                    <input type="checkbox" name="is_white_day" id="is_white_day" value="1" {{ old('is_white_day') ? 'checked' : '' }}
                        class="h-5 w-5 rounded accent-amber-500 cursor-pointer">
                    <label for="is_white_day" class="text-sm font-medium text-gray-700 dark:text-gray-300 cursor-pointer">
                        يوم من الأيام البيض (13 - 14 - 15 من الشهر)
                    </label>
                </div>
            </div>
        </div>

        {{-- Dua Section --}}
        <div class="admin-card p-6 mb-4">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">الدعاء اليومي <span class="text-gray-300 font-normal normal-case text-xs">(اختياري)</span></h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان الدعاء (EN)</label>
                    <input type="text" name="dua_title" value="{{ old('dua_title') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان الدعاء (AR)</label>
                    <input type="text" name="dua_title_ar" value="{{ old('dua_title_ar') }}" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">نص الدعاء (عربي)</label>
                    <textarea name="dua_arabic" rows="3" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white leading-relaxed">{{ old('dua_arabic') }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الترجمة (EN)</label>
                    <textarea name="dua_translation" rows="2"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('dua_translation') }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">المرجع</label>
                    <input type="text" name="dua_reference" value="{{ old('dua_reference') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
            </div>
        </div>

        {{-- Hadith Section --}}
        <div class="admin-card p-6 mb-6">
            <h3 class="mb-5 text-sm font-bold uppercase tracking-widest text-gray-400">الحديث الشريف <span class="text-gray-300 font-normal normal-case text-xs">(اختياري)</span></h3>
            <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">نص الحديث (عربي)</label>
                    <textarea name="hadith_arabic" rows="3" dir="rtl"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white leading-relaxed">{{ old('hadith_arabic') }}</textarea>
                </div>
                <div class="md:col-span-2">
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الترجمة (EN)</label>
                    <textarea name="hadith_english" rows="2"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('hadith_english') }}</textarea>
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">المصدر</label>
                    <input type="text" name="hadith_source" value="{{ old('hadith_source') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
                <div>
                    <label class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الدرجة</label>
                    <input type="text" name="hadith_grade" value="{{ old('hadith_grade') }}" placeholder="صحيح"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                </div>
            </div>
        </div>

        <div class="flex items-center gap-4">
            <button type="submit" class="admin-btn bg-emerald-600 text-white hover:bg-emerald-700">
                <i class="fa-solid fa-plus ml-2"></i> إضافة اليوم
            </button>
            <a href="{{ $cityKey ? route('admin.ramadan.show', $cityKey) : route('admin.ramadan.index') }}"
                class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                إلغاء
            </a>
        </div>
    </form>
</x-admin-layout>
