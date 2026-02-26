<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" dir="rtl">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>@yield('title', 'لوحة التحكم') - أنا مسلم</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap"
        rel="stylesheet">

    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <script>
        function adminApp() {
            return {
                sidebar: {
                    open: false,
                    collapsed: localStorage.getItem('sidebar_collapsed') === 'true',
                },
                nav: {
                    groups: (() => {
                        try {
                            const raw = localStorage.getItem('admin_nav_groups');
                            const parsed = raw ? JSON.parse(raw) : null;
                            if (parsed && typeof parsed === 'object') return parsed;
                        } catch (_) {}
                        return {
                            admin: true,
                            content: true,
                        };
                    })(),
                    persist() {
                        try {
                            localStorage.setItem('admin_nav_groups', JSON.stringify(this.groups));
                        } catch (_) {}
                    },
                    toggle(key) {
                        this.groups[key] = !this.groups[key];
                        this.persist();
                    },
                    isOpen(key, isSidebarCollapsed) {
                        return Boolean(isSidebarCollapsed || this.groups[key]);
                    },
                },
                toggleSidebar() {
                    this.sidebar.open = !this.sidebar.open;
                },
                toggleCollapse() {
                    this.sidebar.collapsed = !this.sidebar.collapsed;
                    localStorage.setItem('sidebar_collapsed', this.sidebar.collapsed);
                },
                theme: localStorage.getItem('theme') || 'system',
                themeDropdownOpen: false,
                toggleTheme(value) {
                    this.theme = value;
                    localStorage.setItem('theme', value);
                    this.updateTheme();
                    this.themeDropdownOpen = false;
                },
                updateTheme() {
                    if (this.theme === 'dark' || (this.theme === 'system' && window.matchMedia(
                            '(prefers-color-scheme: dark)').matches)) {
                        document.documentElement.classList.add('dark');
                    } else {
                        document.documentElement.classList.remove('dark');
                    }
                },
                init() {
                    this.updateTheme();
                },
            };
        }
    </script>

    @stack('styles')
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="bg-gray-50/80 dark:bg-[#0f1117] transition-colors duration-300" dir="rtl"
    style="font-family: 'IBM Plex Sans Arabic', system-ui, sans-serif;" x-data="adminApp()">

    <div class="flex h-screen overflow-hidden">

        <!-- Mobile Backdrop -->
        <div x-show="sidebar.open" x-transition:enter="transition-opacity ease-linear duration-300"
            x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100"
            x-transition:leave="transition-opacity ease-linear duration-300" x-transition:leave-start="opacity-100"
            x-transition:leave-end="opacity-0" @click="sidebar.open = false"
            class="fixed inset-0 z-40 bg-gray-900/60 backdrop-blur-sm lg:hidden" x-cloak></div>

        <!-- Sidebar -->
        @include('partials.admin-sidebar')

        <!-- Content -->
        <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
            <!-- Header -->
            @include('partials.admin-header')

            <!-- Main Body -->
            <main class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
                @yield('content')
            </main>
        </div>
    </div>

    @stack('scripts')
</body>

</html>
