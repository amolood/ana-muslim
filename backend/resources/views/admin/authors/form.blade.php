<x-admin-layout>
    <div class="mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.authors.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400 transition-colors">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                {{ isset($author) ? 'تعديل المؤلف: ' . $author->title : 'إضافة مؤلف جديد' }}
            </h2>
        </div>
    </div>

    <div class="admin-card p-6">
        <form action="{{ isset($author) ? route('admin.authors.update', $author->id) : route('admin.authors.store') }}" method="POST">
            @csrf
            @if(isset($author))
                @method('PUT')
            @endif

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <!-- Title -->
                <div class="col-span-1 md:col-span-2">
                    <label for="title" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الاسم <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $author->title ?? '') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('title') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Type -->
                <div>
                    <label for="type" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">النوع</label>
                    <input type="text" name="type" id="type" value="{{ old('type', $author->type ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('type') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Kind -->
                <div>
                    <label for="kind" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">التصنيف (الفرز)</label>
                    <input type="text" name="kind" id="kind" value="{{ old('kind', $author->kind ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('kind') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Description -->
                <div class="col-span-1 md:col-span-2">
                    <label for="description" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الوصف</label>
                    <textarea name="description" id="description" rows="4"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('description', $author->description ?? '') }}</textarea>
                    @error('description') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- API URL -->
                <div class="col-span-1 md:col-span-2">
                    <label for="api_url" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">رابط المصدر (API URL)</label>
                    <input type="url" name="api_url" id="api_url" value="{{ old('api_url', $author->api_url ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('api_url') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>
            </div>

            <div class="mt-8 flex items-center gap-4 border-t border-gray-100 pt-6 dark:border-white/10">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    <i class="fa-solid fa-save ml-2"></i> {{ isset($author) ? 'حفظ التعديلات' : 'إضافة المؤلف' }}
                </button>
                <a href="{{ route('admin.authors.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</x-admin-layout>
