<x-admin-layout>
    @php
        $isEditing = isset($item);
        $selectedCategories = old('categories', $isEditing ? $item->categories->pluck('id')->toArray() : []);
        $selectedAuthors = old('authors', $isEditing ? $item->authors->pluck('id')->toArray() : []);
    @endphp

    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.items.index') }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white text-gray-500 shadow-sm transition-colors hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <div>
                <h2 class="text-xl font-black text-gray-800 dark:text-white">
                    {{ $isEditing ? 'تعديل المادة: ' . $item->title : 'إضافة مادة جديدة' }}
                </h2>
                <p class="text-xs font-medium text-gray-500 dark:text-gray-400">بيانات مرتبة تساعد على إدارة المواد وربطها بسرعة</p>
            </div>
        </div>
    </div>

    <form action="{{ $isEditing ? route('admin.items.update', $item->id) : route('admin.items.store') }}" method="POST" class="space-y-6">
        @csrf
        @if($isEditing)
            @method('PUT')
        @endif

        <div class="admin-card p-6">
            <h3 class="mb-4 text-base font-black text-gray-800 dark:text-white">البيانات الأساسية</h3>
            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="col-span-1 md:col-span-2">
                    <label for="title" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">عنوان المادة <span class="text-red-500">*</span></label>
                    <input type="text" name="title" id="title" value="{{ old('title', $item->title ?? '') }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('title') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="type" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">النوع</label>
                    <input type="text" name="type" id="type" value="{{ old('type', $item->type ?? '') }}" placeholder="مثال: audio, video, books"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('type') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="importance_level" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">مستوى الأهمية</label>
                    <input type="text" name="importance_level" id="importance_level" value="{{ old('importance_level', $item->importance_level ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('importance_level') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="source_language" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">لغة المصدر</label>
                    <input type="text" name="source_language" id="source_language" value="{{ old('source_language', $item->source_language ?? 'ar') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('source_language') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="translated_language" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">اللغة المترجمة</label>
                    <input type="text" name="translated_language" id="translated_language" value="{{ old('translated_language', $item->translated_language ?? '') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('translated_language') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>
            </div>
        </div>

        <div class="admin-card p-6">
            <h3 class="mb-4 text-base font-black text-gray-800 dark:text-white">الوصف والروابط</h3>
            <div class="grid grid-cols-1 gap-6">
                <div>
                    <label for="description" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">الوصف الموجز</label>
                    <textarea name="description" id="description" rows="3"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('description', $item->description ?? '') }}</textarea>
                    @error('description') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="full_description" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">الوصف الكامل</label>
                    <textarea name="full_description" id="full_description" rows="6"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('full_description', $item->full_description ?? '') }}</textarea>
                    @error('full_description') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="image" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">رابط صورة الغلاف</label>
                    <input type="url" name="image" id="image" value="{{ old('image', $item->image ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-left text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('image') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="api_url" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">رابط المصدر (API URL)</label>
                    <input type="url" name="api_url" id="api_url" value="{{ old('api_url', $item->api_url ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-left text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('api_url') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>
            </div>
        </div>

        <div class="admin-card p-6">
            <h3 class="mb-4 text-base font-black text-gray-800 dark:text-white">الارتباطات</h3>
            <p class="mb-4 text-xs text-gray-500 dark:text-gray-400">لاختيار متعدد: استخدم Ctrl على ويندوز أو Cmd على ماك.</p>

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div>
                    <label for="categories" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">التصنيفات المرتبطة</label>
                    <select name="categories[]" id="categories" multiple size="10"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}" {{ in_array($category->id, $selectedCategories) ? 'selected' : '' }}>
                                {{ $category->parent ? ($category->parent->parent ? $category->parent->parent->title . ' > ' : '') . $category->parent->title . ' > ' : '' }}{{ $category->title }}
                            </option>
                        @endforeach
                    </select>
                    @error('categories') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>

                <div>
                    <label for="authors" class="mb-2 block text-sm font-bold text-gray-700 dark:text-gray-300">المؤلفون / القراء</label>
                    <select name="authors[]" id="authors" multiple size="10"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/60 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                        @foreach($authors as $author)
                            <option value="{{ $author->id }}" {{ in_array($author->id, $selectedAuthors) ? 'selected' : '' }}>
                                {{ $author->title }}
                            </option>
                        @endforeach
                    </select>
                    @error('authors') <span class="mt-1 block text-xs text-red-500">{{ $message }}</span> @enderror
                </div>
            </div>
        </div>

        <div class="flex flex-wrap items-center gap-3 border-t border-gray-100 pt-2 dark:border-white/10">
            <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                <i class="fa-solid fa-save ml-2"></i> {{ $isEditing ? 'حفظ التعديلات' : 'إضافة المادة' }}
            </button>
            <a href="{{ route('admin.items.index') }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">إلغاء</a>
        </div>
    </form>
</x-admin-layout>
