<header
    class="h-16 border-b border-gray-100/80 dark:border-gray-800/80 bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl px-4 sm:px-6 flex items-center justify-between transition-colors duration-300 sticky top-0 z-30">
    <div class="flex items-center gap-3">
        <button class="lg:hidden flex h-9 w-9 items-center justify-center rounded-xl text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" @click="toggleSidebar()">
            <i class="fas fa-bars"></i>
        </button>
        <button class="hidden lg:flex h-9 w-9 items-center justify-center rounded-xl text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-all duration-300"
            @click="toggleCollapse()" :class="sidebar.collapsed ? 'rotate-180' : ''">
            <i class="fas fa-indent"></i>
        </button>
        <div class="hidden sm:block">
            <h1 class="text-base font-bold text-gray-900 dark:text-white">@yield('page-title', 'لوحة التحكم')</h1>
        </div>
    </div>

    <div class="flex items-center gap-2">
        <!-- Search (placeholder) -->
        <div class="hidden md:flex items-center gap-2 rounded-xl bg-gray-50 dark:bg-gray-800/50 px-3 py-2 text-sm text-gray-400 ring-1 ring-gray-200/50 dark:ring-gray-700/50 w-56">
            <i class="fas fa-search text-xs"></i>
            <span class="text-xs">بحث سريع...</span>
        </div>

        <!-- Theme Toggle -->
        <div class="relative" x-data="{ open: false }">
            <button @click="open = !open"
                class="h-9 w-9 flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-xl transition-colors">
                <i class="fas text-sm"
                    :class="theme === 'dark' ? 'fa-moon' : (theme === 'light' ? 'fa-sun' : 'fa-desktop')"></i>
            </button>
            <div x-show="open" @click.away="open = false"
                class="absolute left-0 mt-2 w-40 bg-white dark:bg-gray-800 shadow-xl shadow-gray-200/50 dark:shadow-gray-900/50 border border-gray-100 dark:border-gray-700 rounded-xl py-1.5 z-50"
                x-cloak>
                <button @click="toggleTheme('light'); open = false"
                    class="w-full flex items-center px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <i class="fas fa-sun ml-3 text-orange-400"></i> فاتح
                </button>
                <button @click="toggleTheme('dark'); open = false"
                    class="w-full flex items-center px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <i class="fas fa-moon ml-3 text-indigo-400"></i> داكن
                </button>
                <button @click="toggleTheme('system'); open = false"
                    class="w-full flex items-center px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <i class="fas fa-desktop ml-3 text-gray-400"></i> النظام
                </button>
            </div>
        </div>

        <!-- Notifications -->
        <a href="{{ route('admin.notifications.index') }}"
            class="h-9 w-9 flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-xl transition-colors relative">
            <i class="fas fa-bell text-sm"></i>
        </a>

        <!-- User avatar -->
        <div class="hidden sm:flex h-9 w-9 items-center justify-center rounded-xl bg-emerald-500 text-white text-xs font-bold">
            {{ mb_substr(Auth::user()->name ?? 'م', 0, 1) }}
        </div>
    </div>
</header>
