<aside
    class="fixed right-0 top-0 z-50 flex h-screen flex-col border-l border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 transition-all duration-300 lg:static lg:z-auto lg:translate-x-0"
    :class="[
        sidebar.open ? 'translate-x-0' : 'translate-x-full lg:translate-x-0',
        sidebar.collapsed ? 'w-20' : 'w-72'
    ]" id="admin-sidebar">

    <!-- Logo -->
    <div class="border-b border-gray-100 dark:border-gray-800 p-6 flex justify-between items-center h-20">
        <div class="flex items-center">
            <div
                class="flex-shrink-0 flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-600 shadow-lg shadow-emerald-600/20">
                <i class="fa-solid fa-moon text-white"></i>
            </div>
            <h2 class="mr-3 text-lg font-bold text-gray-900 dark:text-white truncate"
                x-show="!sidebar.collapsed">
                أنا مسلم
            </h2>
        </div>
        <button @click="sidebar.open = false" class="lg:hidden text-gray-400 hover:text-gray-600">
            <i class="fas fa-times text-xl"></i>
        </button>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 overflow-y-auto px-4 py-6 custom-scrollbar">
        <div class="space-y-1">
            <!-- Group: Admin -->
            @php
                $adminActive = request()->routeIs('admin.dashboard');
            @endphp
            <button type="button"
                class="w-full flex items-center px-4 py-3 rounded-xl font-black transition-colors text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 {{ $adminActive ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-300' : '' }}"
                :aria-expanded="nav.isOpen('admin', sidebar.collapsed) ? 'true' : 'false'"
                @click="nav.toggle('admin')">
                <i class="fas fa-sliders w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                <span class="flex-1 text-right truncate" x-show="!sidebar.collapsed">الإدارة</span>
                <i class="fas fa-chevron-down text-xs transition-transform"
                    :class="nav.isOpen('admin', sidebar.collapsed) ? 'rotate-180' : ''" x-show="!sidebar.collapsed"></i>
            </button>
            <div class="mt-1 space-y-1 overflow-hidden"
                x-show="nav.isOpen('admin', sidebar.collapsed)" x-transition.opacity.duration.150ms>
                <a href="{{ route('admin.dashboard') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.dashboard') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-tachometer-alt w-6 text-lg"
                        :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">لوحة التحكم</span>
                </a>
            </div>

            <!-- Group: Content -->
            @php
                $contentActive = request()->routeIs('admin.categories.*')
                    || request()->routeIs('admin.authors.*')
                    || request()->routeIs('admin.items.*')
                    || request()->routeIs('admin.hadith.*');
            @endphp
            <button type="button"
                class="mt-4 w-full flex items-center px-4 py-3 rounded-xl font-black transition-colors text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 {{ $contentActive ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-300' : '' }}"
                :aria-expanded="nav.isOpen('content', sidebar.collapsed) ? 'true' : 'false'"
                @click="nav.toggle('content')">
                <i class="fa-solid fa-book-open w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                <span class="flex-1 text-right truncate" x-show="!sidebar.collapsed">المحتوى</span>
                <i class="fas fa-chevron-down text-xs transition-transform"
                    :class="nav.isOpen('content', sidebar.collapsed) ? 'rotate-180' : ''"
                    x-show="!sidebar.collapsed"></i>
            </button>
            <div class="mt-1 space-y-1 overflow-hidden"
                x-show="nav.isOpen('content', sidebar.collapsed)" x-transition.opacity.duration.150ms>
                <a href="{{ route('admin.categories.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.categories.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-tags w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">التصنيفات</span>
                </a>
                <a href="{{ route('admin.authors.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.authors.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-users w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">المؤلفون</span>
                </a>
                <a href="{{ route('admin.items.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.items.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fa-solid fa-layer-group w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">المواد</span>
                </a>
                <a href="{{ route('admin.hadith.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.hadith.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fa-solid fa-book-quran w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">الحديث الشريف</span>
                </a>
                <a href="{{ route('admin.reciters.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.reciters.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-microphone-lines w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">القراء</span>
                </a>
            </div>

            <!-- Group: System -->
            @php
                $systemActive = request()->routeIs('admin.notifications.*') || request()->routeIs('admin.settings.*');
            @endphp
            <button type="button"
                class="mt-4 w-full flex items-center px-4 py-3 rounded-xl font-black transition-colors text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 {{ $systemActive ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-300' : '' }}"
                :aria-expanded="nav.isOpen('system', sidebar.collapsed) ? 'true' : 'false'"
                @click="nav.toggle('system')">
                <i class="fa-solid fa-gears w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                <span class="flex-1 text-right truncate" x-show="!sidebar.collapsed">النظام</span>
                <i class="fas fa-chevron-down text-xs transition-transform"
                    :class="nav.isOpen('system', sidebar.collapsed) ? 'rotate-180' : ''"
                    x-show="!sidebar.collapsed"></i>
            </button>
            <div class="mt-1 space-y-1 overflow-hidden"
                x-show="nav.isOpen('system', sidebar.collapsed)" x-transition.opacity.duration.150ms>
                <a href="{{ route('admin.notifications.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.notifications.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-bell w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">التنبيهات</span>
                </a>
                <a href="{{ route('admin.settings.index') }}"
                    class="flex items-center px-4 py-3 {{ request()->routeIs('admin.settings.*') ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800' }} rounded-xl font-medium transition-colors">
                    <i class="fas fa-cog w-6 text-lg" :class="sidebar.collapsed ? 'ml-0' : 'ml-3'"></i>
                    <span x-show="!sidebar.collapsed">الإعدادات</span>
                </a>
            </div>
        </div>
    </nav>

    <!-- User -->
    <div class="border-t border-gray-100 dark:border-gray-800 p-4 space-y-2">
        <div class="flex items-center p-2 rounded-xl bg-gray-50 dark:bg-gray-800/50">
            <div class="h-10 w-10 rounded-full bg-emerald-600 flex items-center justify-center text-white">
                <i class="fas fa-user"></i>
            </div>
            <div class="mr-3 flex-1 overflow-hidden" x-show="!sidebar.collapsed">
                <p class="text-sm font-bold text-gray-900 dark:text-white truncate">
                    {{ Auth::user()->name ?? 'المدير' }}</p>
                <p class="text-xs text-gray-500 truncate">مدير النظام</p>
            </div>
        </div>

        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit"
                class="w-full flex items-center p-2 rounded-xl text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors group">
                <div class="h-10 w-10 flex items-center justify-center">
                    <i
                        class="fas fa-sign-out-alt text-xl group-hover:rotate-180 transition-transform duration-300"></i>
                </div>
                <div class="mr-3 font-bold" x-show="!sidebar.collapsed">تسجيل الخروج</div>
            </button>
        </form>
    </div>
</aside>
