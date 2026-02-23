<x-admin-layout>
    <div class="mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.categories.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400 transition-colors">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                {{ isset($category) ? 'تعديل التصنيف: ' . $category->title : 'إضافة تصنيف جديد' }}
            </h2>
        </div>
    </div>

    <div class="admin-card p-6">
        <form action="{{ isset($category) ? route('admin.categories.update', $category->id) : route('admin.categories.store') }}" method="POST">
            @csrf
            @if(isset($category))
                @method('PUT')
            @endif

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <!-- Title -->
                <div class="col-span-1 md:col-span-2">
                    <label for="title" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان التصنيف <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $category->title ?? '') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('title') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Block Name -->
                <div>
                    <label for="block_name" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الاسم البرمجي (Block Name)</label>
                    <input type="text" name="block_name" id="block_name" value="{{ old('block_name', $category->block_name ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('block_name') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Language -->
                <div>
                    <label for="language" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">اللغة <span class="text-red-500">*</span></label>
                    <select name="language" id="language" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <option value="ar" {{ old('language', $category->language ?? 'ar') == 'ar' ? 'selected' : '' }}>العربية (ar)</option>
                        <option value="en" {{ old('language', $category->language ?? '') == 'en' ? 'selected' : '' }}>الإنجليزية (en)</option>
                    </select>
                    @error('language') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Parent ID -->
                <div class="col-span-1 md:col-span-2">
                    <label for="parent_id" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">التصنيف الأب</label>
                    <select name="parent_id" id="parent_id"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <option value="">-- بدون تصنيف أب (أساسي) --</option>
                        @foreach($parentCategories as $parent)
                            <option value="{{ $parent->id }}" {{ old('parent_id', $category->parent_id ?? '') == $parent->id ? 'selected' : '' }}>
                                {{ $parent->title }}
                            </option>
                        @endforeach
                    </select>
                    <p class="mt-1 flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400">
                        <i class="fa-solid fa-circle-info"></i> إذا تم تحديد تصنيف أب، سيصبح هذا التصنيف فرعيًا.
                    </p>
                    @error('parent_id') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>
            </div>

            <div class="mt-8 flex items-center gap-4 border-t border-gray-100 pt-6 dark:border-white/10">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    <i class="fa-solid fa-save ml-2"></i> {{ isset($category) ? 'حفظ التعديلات' : 'إضافة التصنيف' }}
                </button>
                <a href="{{ route('admin.categories.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</x-admin-layout>
