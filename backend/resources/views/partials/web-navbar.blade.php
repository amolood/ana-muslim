{{-- Floating Navbar --}}
<nav class="fixed top-4 left-4 right-4 max-w-7xl mx-auto z-50 glass-panel rounded-full px-4 sm:px-6 h-16 flex items-center justify-between transition-all duration-300 shadow-lg">
    {{-- Logo & Main Menu --}}
    <div class="flex items-center gap-8">
        <a href="{{ url('/') }}" class="flex items-center gap-2.5">
            <img src="{{ asset('assets/logo.svg') }}" alt="I'm Muslim Logo" class="h-10 w-auto">
            <span class="text-lg font-semibold tracking-tight text-slate-900 dark:text-white hidden sm:inline" x-text="t('brand.name')"></span>
        </a>

        {{-- Desktop Navigation --}}
        <div class="hidden md:flex items-center gap-6 text-sm font-bold">
            <a href="{{ url('/') }}"
               class="{{ request()->is('/') ? 'text-primary' : 'text-slate-600 dark:text-slate-400 hover:text-primary' }} transition-colors"
               x-text="t('nav.home')"></a>
            <a href="{{ url('/quran-text') }}"
               class="{{ request()->is('quran-text') ? 'text-primary' : 'text-slate-600 dark:text-slate-400 hover:text-primary' }} transition-colors"
               x-text="t('nav.quranText')"></a>
            <a href="{{ url('/quran-premium') }}"
               class="{{ request()->is('quran-premium') ? 'text-primary' : 'text-slate-600 dark:text-slate-400 hover:text-primary' }} transition-colors"
               x-text="t('nav.quranPremium')"></a>
            <a href="{{ url('/hisnmuslim') }}"
               class="{{ request()->is('hisnmuslim') ? 'text-primary' : 'text-slate-600 dark:text-slate-400 hover:text-primary' }} transition-colors"
               x-text="t('nav.hisnmuslim')"></a>
            <a href="{{ url('/privacy') }}"
               class="{{ request()->is('privacy') ? 'text-primary' : 'text-slate-600 dark:text-slate-400 hover:text-primary' }} transition-colors"
               x-text="t('nav.privacy')"></a>
        </div>
    </div>

    {{-- Right Side Actions --}}
    <div class="flex items-center gap-3">
        {{-- Language Switcher --}}
        <button @click="toggleLocale()"
                class="w-10 h-10 rounded-full glass-button flex items-center justify-center text-xs font-bold hover:text-primary transition-colors">
            <span x-text="locale === 'ar' ? 'EN' : 'AR'"></span>
        </button>

        {{-- Theme Switcher --}}
        @include('partials.theme-switcher')

        {{-- Mobile Menu Toggle --}}
        <button @click="mobileMenuOpen = !mobileMenuOpen"
                class="md:hidden w-10 h-10 rounded-full glass-button flex items-center justify-center hover:text-primary transition-colors">
            <iconify-icon icon="solar:hamburger-menu-bold" class="text-xl"></iconify-icon>
        </button>
    </div>
</nav>

{{-- Mobile Menu --}}
<div x-data="{ mobileMenuOpen: false }"
     x-show="mobileMenuOpen"
     x-transition:enter="transition ease-out duration-300"
     x-transition:enter-start="opacity-0"
     x-transition:enter-end="opacity-100"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100"
     x-transition:leave-end="opacity-0"
     @click="mobileMenuOpen = false"
     class="md:hidden fixed inset-0 bg-black/50 backdrop-blur-sm z-40"
     style="display: none;">

    <div @click.stop
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="translate-y-full"
         x-transition:enter-end="translate-y-0"
         x-transition:leave="transition ease-in duration-200"
         x-transition:leave-start="translate-y-0"
         x-transition:leave-end="translate-y-full"
         class="absolute bottom-0 left-0 right-0 bg-white dark:bg-slate-900 rounded-t-3xl p-6 shadow-2xl">

        {{-- Mobile Menu Header --}}
        <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg font-bold text-slate-900 dark:text-white" x-text="t('nav.menu')"></h3>
            <button @click="mobileMenuOpen = false"
                    class="w-10 h-10 rounded-full glass-button flex items-center justify-center">
                <iconify-icon icon="solar:close-circle-bold" class="text-xl"></iconify-icon>
            </button>
        </div>

        {{-- Mobile Menu Links --}}
        <div class="flex flex-col gap-3">
            <a href="{{ url('/') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl {{ request()->is('/') ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300' }} hover:bg-slate-100 dark:hover:bg-white/5 transition-all">
                <iconify-icon icon="solar:home-2-bold" class="text-xl"></iconify-icon>
                <span class="font-bold" x-text="t('nav.home')"></span>
            </a>
            <a href="{{ url('/quran-text') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl {{ request()->is('quran-text') ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300' }} hover:bg-slate-100 dark:hover:bg-white/5 transition-all">
                <iconify-icon icon="solar:book-2-bold" class="text-xl"></iconify-icon>
                <span class="font-bold" x-text="t('nav.quranText')"></span>
            </a>
            <a href="{{ url('/quran-premium') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl {{ request()->is('quran-premium') ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300' }} hover:bg-slate-100 dark:hover:bg-white/5 transition-all">
                <iconify-icon icon="solar:music-library-2-bold" class="text-xl"></iconify-icon>
                <span class="font-bold" x-text="t('nav.quranPremium')"></span>
            </a>
            <a href="{{ url('/hisnmuslim') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl {{ request()->is('hisnmuslim') ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300' }} hover:bg-slate-100 dark:hover:bg-white/5 transition-all">
                <iconify-icon icon="solar:shield-star-bold" class="text-xl"></iconify-icon>
                <span class="font-bold" x-text="t('nav.hisnmuslim')"></span>
            </a>
            <a href="{{ url('/privacy') }}"
               class="flex items-center gap-3 px-4 py-3 rounded-xl {{ request()->is('privacy') ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300' }} hover:bg-slate-100 dark:hover:bg-white/5 transition-all">
                <iconify-icon icon="solar:shield-check-bold" class="text-xl"></iconify-icon>
                <span class="font-bold" x-text="t('nav.privacy')"></span>
            </a>
        </div>
    </div>
</div>
