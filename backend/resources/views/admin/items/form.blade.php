<x-admin-layout>
    <div class="mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.items.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400 transition-colors">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                {{ isset($item) ? 'تعديل المادة: ' . $item->title : 'إضافة مادة جديدة' }}
            </h2>
        </div>
    </div>

    <div class="admin-card p-6">
        <form action="{{ isset($item) ? route('admin.items.update', $item->id) : route('admin.items.store') }}" method="POST">
            @csrf
            @if(isset($item))
                @method('PUT')
            @endif

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <!-- Title -->
                <div class="col-span-1 md:col-span-2">
                    <label for="title" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">عنوان المادة <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $item->title ?? '') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('title') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Type & Importance -->
                <div>
                    <label for="type" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">النوع</label>
                    <input type="text" name="type" id="type" value="{{ old('type', $item->type ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('type') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="importance_level" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">مستوى الأهمية</label>
                    <input type="text" name="importance_level" id="importance_level" value="{{ old('importance_level', $item->importance_level ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('importance_level') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Languages -->
                <div>
                    <label for="source_language" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">اللغة المصدر</label>
                    <input type="text" name="source_language" id="source_language" value="{{ old('source_language', $item->source_language ?? 'ar') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('source_language') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="translated_language" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">اللغة المترجمة (إن وجدت)</label>
                    <input type="text" name="translated_language" id="translated_language" value="{{ old('translated_language', $item->translated_language ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('translated_language') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Descriptions -->
                <div class="col-span-1 md:col-span-2">
                    <label for="description" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الوصف الموجز</label>
                    <textarea name="description" id="description" rows="3"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('description', $item->description ?? '') }}</textarea>
                    @error('description') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <div class="col-span-1 md:col-span-2">
                    <label for="full_description" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الوصف الكامل</label>
                    <textarea name="full_description" id="full_description" rows="5"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('full_description', $item->full_description ?? '') }}</textarea>
                    @error('full_description') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Media -->
                <div class="col-span-1 md:col-span-2">
                    <label for="image" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">رابط صورة الغلاف</label>
                    <input type="url" name="image" id="image" value="{{ old('image', $item->image ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('image') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <div class="col-span-1 md:col-span-2">
                    <label for="api_url" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">رابط مصدر API</label>
                    <input type="url" name="api_url" id="api_url" value="{{ old('api_url', $item->api_url ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('api_url') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Relations -->
                <div class="col-span-1 md:col-span-2 mt-4 pt-4 border-t border-gray-100 dark:border-white/10">
                    <h3 class="text-lg font-bold text-gray-800 dark:text-white mb-4">الارتباطات</h3>
                    <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                        
                        <!-- Categories -->
                        <div>
                            <label for="categories" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">التصنيفات المرتبطة</label>
                            <p class="text-xs text-gray-500 mb-2">اضغط على Ctrl (أو Cmd) لاختيار أكثر من تصنيف</p>
                            @php
                                $selectedCategories = isset($item) ? $item->categories->pluck('id')->toArray() : [];
                            @endphp
                            <select name="categories[]" id="categories" multiple size="8"
                                class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}" {{ in_array($category->id, old('categories', $selectedCategories)) ? 'selected' : '' }}>
                                        {{ $category->parent ? ($category->parent->parent ? $category->parent->parent->title . ' > ' : '') . $category->parent->title . ' > ' : '' }}{{ $category->title }}
                                    </option>
                                @endforeach
                            </select>
                            @error('categories') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                        </div>

                        <!-- Authors -->
                        <div>
                            <label for="authors" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">المؤلفون / القراء المرتبطون</label>
                            <p class="text-xs text-gray-500 mb-2">اضغط على Ctrl (أو Cmd) لاختيار أكثر من مؤلف</p>
                            @php
                                $selectedAuthors = isset($item) ? $item->authors->pluck('id')->toArray() : [];
                            @endphp
                            <select name="authors[]" id="authors" multiple size="8"
                                class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                                @foreach($authors as $author)
                                    <option value="{{ $author->id }}" {{ in_array($author->id, old('authors', $selectedAuthors)) ? 'selected' : '' }}>
                                        {{ $author->title }}
                                    </option>
                                @endforeach
                            </select>
                            @error('authors') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                        </div>

                    </div>
                </div>

            </div>

            <div class="mt-8 flex items-center gap-4 border-t border-gray-100 pt-6 dark:border-white/10">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    <i class="fa-solid fa-save ml-2"></i> {{ isset($item) ? 'حفظ التعديلات' : 'إضافة المادة' }}
                </button>
                <a href="{{ route('admin.items.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</x-admin-layout>
