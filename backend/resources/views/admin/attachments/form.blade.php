<x-admin-layout>
    <div class="mb-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <a href="{{ route('admin.attachments.index', ['item_id' => $item ? $item->id : '']) }}" class="flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm text-gray-500 hover:text-blue-600 dark:bg-white/5 dark:text-gray-400 dark:hover:text-blue-400 transition-colors">
                <i class="fa-solid fa-arrow-right"></i>
            </a>
            <h2 class="text-xl font-bold text-gray-800 dark:text-white">
                {{ isset($attachment) ? 'تعديل المرفق' : 'إضافة مرفق جديد' }}
            </h2>
        </div>
    </div>

    <div class="admin-card p-6">
        <form action="{{ isset($attachment) ? route('admin.attachments.update', $attachment->id) : route('admin.attachments.store') }}" method="POST">
            @csrf
            @if(isset($attachment))
                @method('PUT')
            @endif

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <!-- Item ID -->
                <div class="col-span-1 md:col-span-2">
                    <label for="item_id" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">رقم المادة المرتبطة (ID) <span class="text-red-500">*</span></label>
                    <input type="number" name="item_id" id="item_id" value="{{ old('item_id', $attachment->item_id ?? ($item ? $item->id : '')) }}" required
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        @if($item)
                            <span>المادة الحالية: <strong>{{ $item->title }}</strong></span>
                        @else
                            <span>يجب إدخال الـ ID الخاص بالمادة (Item ID) الموجودة في قاعدة البيانات.</span>
                        @endif
                    </p>
                    @error('item_id') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- URL -->
                <div class="col-span-1 md:col-span-2">
                    <label for="url" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">رابط الملف (URL) <span class="text-red-500">*</span></label>
                    <input type="url" name="url" id="url" value="{{ old('url', $attachment->url ?? '') }}" required dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('url') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Extension Type -->
                <div>
                    <label for="extension_type" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">نوع الملف (مثال: PDF, MP3)</label>
                    <input type="text" name="extension_type" id="extension_type" value="{{ old('extension_type', $attachment->extension_type ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm uppercase text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('extension_type') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Size -->
                <div>
                    <label for="size" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">حجم الملف (مثال: 5.2 MB)</label>
                    <input type="text" name="size" id="size" value="{{ old('size', $attachment->size ?? '') }}" dir="ltr"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm text-left focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('size') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Order -->
                <div>
                    <label for="order" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">الترتيب</label>
                    <input type="number" name="order" id="order" value="{{ old('order', $attachment->order ?? '0') }}"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">
                    @error('order') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>

                <!-- Description -->
                <div class="col-span-1 md:col-span-2">
                    <label for="description" class="mb-2 block text-sm font-medium text-gray-700 dark:text-gray-300">وصف المرفق</label>
                    <textarea name="description" id="description" rows="3"
                        class="w-full rounded-xl border-gray-200 bg-gray-50/50 px-4 py-2.5 text-sm focus:border-blue-500 focus:ring-blue-500 dark:border-white/10 dark:bg-white/5 dark:text-white">{{ old('description', $attachment->description ?? '') }}</textarea>
                    @error('description') <span class="text-xs text-red-500 mt-1">{{ $message }}</span> @enderror
                </div>
            </div>

            <div class="mt-8 flex items-center gap-4 border-t border-gray-100 pt-6 dark:border-white/10">
                <button type="submit" class="admin-btn bg-blue-600 text-white hover:bg-blue-700">
                    <i class="fa-solid fa-save ml-2"></i> {{ isset($attachment) ? 'حفظ التعديلات' : 'إضافة المرفق' }}
                </button>
                <a href="{{ route('admin.attachments.index', ['item_id' => $item ? $item->id : '']) }}" class="admin-btn bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-white/5 dark:text-gray-300 dark:hover:bg-white/10">
                    إلغاء
                </a>
            </div>
        </form>
    </div>
</x-admin-layout>
