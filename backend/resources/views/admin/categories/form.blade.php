<x-admin-layout>
    @php
        $isEditing = isset($category);
    @endphp

    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.categories.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-gray-500 shadow-sm transition-colors hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <div>
                <h2 class="text-xl font-black text-gray-800 dark:text-white">
                    {{ $isEditing ? 'تعديل التصنيف: ' . $category->title : 'إضافة تصنيف جديد' }}
                </h2>
                <p class="text-xs font-medium text-gray-500 dark:text-gray-400">
                    تنظيم هيكل التصنيفات بشكل واضح يسهل إدارة المواد وربطها
                </p>
            </div>
        </div>
    </div>

    <div class="admin-card p-6">
        <form action="{{ $isEditing ? route('admin.categories.update', $category->id) : route('admin.categories.store') }}" method="POST" class="space-y-6">
            @csrf
            @if($isEditing)
                @method('PUT')
            @endif

            <div class="rounded-2xl border border-blue-100 bg-blue-50/70 p-4 text-sm text-blue-900 dark:border-blue-500/20 dark:bg-blue-500/10 dark:text-blue-200">
                <div class="flex items-start gap-2">
                    <i class="fa-solid fa-circle-info mt-0.5"></i>
                    <p>
                        استخدم التصنيف الأب لبناء شجرة تصنيفية مرتبة. إن تركت التصنيف الأب فارغًا، سيتم إنشاء تصنيف رئيسي.
                    </p>
                </div>
            </div>

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="col-span-1 md:col-span-2">
                    <label for="title" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">
                        عنوان التصنيف <span class="text-red-500">*</span>
                    </label>
                    <input type="text" name="title" id="title" value="{{ old('title', $category->title ?? '') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('title')
                        <span class="mt-1 block text-xs text-red-500">{{ $message }}</span>
                    @enderror
                </div>

                <div>
                    <label for="block_name" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">الاسم البرمجي (Block Name)</label>
                    <input type="text" name="block_name" id="block_name" value="{{ old('block_name', $category->block_name ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white"
                        placeholder="مثال: quran">
                    @error('block_name')
                        <span class="mt-1 block text-xs text-red-500">{{ $message }}</span>
                    @enderror
                </div>

                <div>
                    <label for="language" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">
                        اللغة <span class="text-red-500">*</span>
                    </label>
                    <select name="language" id="language" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <option value="ar" {{ old('language', $category->language ?? 'ar') === 'ar' ? 'selected' : '' }}>العربية (ar)</option>
                        <option value="en" {{ old('language', $category->language ?? '') === 'en' ? 'selected' : '' }}>الإنجليزية (en)</option>
                    </select>
                    @error('language')
                        <span class="mt-1 block text-xs text-red-500">{{ $message }}</span>
                    @enderror
                </div>

                <div class="col-span-1 md:col-span-2">
                    <label for="parent_id" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">التصنيف الأب</label>
                    <select name="parent_id" id="parent_id"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        <option value="">-- بدون تصنيف أب (تصنيف رئيسي) --</option>
                        @foreach($parentCategories as $parent)
                            <option value="{{ $parent->id }}" {{ (string) old('parent_id', $category->parent_id ?? '') === (string) $parent->id ? 'selected' : '' }}>
                                {{ $parent->title }}
                            </option>
                        @endforeach
                    </select>
                    @error('parent_id')
                        <span class="mt-1 block text-xs text-red-500">{{ $message }}</span>
                    @enderror
                </div>

                <div class="col-span-1 md:col-span-2">
                    <label for="items_count" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">عدد المواد (اختياري)</label>
                    <input type="number" name="items_count" id="items_count" min="0" value="{{ old('items_count', $category->items_count ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white"
                        placeholder="مثال: 12">
                    <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">يمكن تركه فارغًا وسيتم التعامل معه حسب بيانات النظام.</p>
                    @error('items_count')
                        <span class="mt-1 block text-xs text-red-500">{{ $message }}</span>
                    @enderror
                </div>
            </div>

            <div class="flex flex-wrap items-center gap-3 border-t border-gray-100 pt-6 dark:border-white/10">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    <i class="fa-solid fa-save ml-2"></i> {{ $isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف' }}
                </button>
                <a href="{{ route('admin.categories.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</x-admin-layout>
