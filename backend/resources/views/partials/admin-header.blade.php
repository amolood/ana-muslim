<header
    class="h-20 border-b border-gray-100 dark:border-gray-800 bg-white dark:bg-gray-900 px-6 flex items-center justify-between transition-colors duration-300">
    <div class="flex items-center gap-4">
        <button class="lg:hidden text-gray-500" @click="toggleSidebar()">
            <i class="fas fa-bars text-xl"></i>
        </button>
        <button class="hidden lg:block text-gray-400 hover:text-gray-600 transition-transform duration-300"
            @click="toggleCollapse()" :class="sidebar.collapsed ? 'rotate-180' : ''">
            <i class="fas fa-indent text-xl"></i>
        </button>
        <h1 class="text-xl font-bold text-gray-900 dark:text-white">@yield('page-title', 'لوحة التحكم')</h1>
    </div>

    <div class="flex items-center gap-4">
        <!-- Theme Toggle -->
        <div class="relative" x-data="{ open: false }">
            <button @click="open = !open"
                class="h-10 w-10 flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-xl transition-colors">
                <i class="fas text-lg"
                    :class="theme === 'dark' ? 'fa-moon' : (theme === 'light' ? 'fa-sun' : 'fa-desktop')"></i>
            </button>
            <div x-show="open" @click.away="open = false"
                class="absolute left-0 mt-2 w-40 bg-white dark:bg-gray-800 shadow-xl border border-gray-100 dark:border-gray-700 rounded-xl py-1 z-50 transition-all"
                x-cloak>
                <button @click="toggleTheme('light'); open = false"
                    class="w-full flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-emerald-50 dark:hover:bg-emerald-900/20">
                    <i class="fas fa-sun ml-3 text-orange-400"></i> نهاراً
                </button>
                <button @click="toggleTheme('dark'); open = false"
                    class="w-full flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-emerald-50 dark:hover:bg-emerald-900/20">
                    <i class="fas fa-moon ml-3 text-indigo-400"></i> ليلاً
                </button>
                <button @click="toggleTheme('system'); open = false"
                    class="w-full flex items-center px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-emerald-50 dark:hover:bg-emerald-900/20">
                    <i class="fas fa-desktop ml-3 text-gray-400"></i> النظام
                </button>
            </div>
        </div>

        <button
            class="h-10 w-10 flex items-center justify-center text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-xl transition-colors">
            <i class="fas fa-bell text-lg"></i>
        </button>
    </div>
</header>
