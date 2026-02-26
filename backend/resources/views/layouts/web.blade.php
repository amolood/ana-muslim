<!DOCTYPE html>
<html lang="ar" dir="rtl" x-data="i18n()" x-init="$nextTick(() => { document.documentElement.lang = locale; document.documentElement.dir = locale === 'ar' ? 'rtl' : 'ltr'; })" :lang="locale" :dir="locale === 'ar' ? 'rtl' : 'ltr'">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    {{-- SEO Meta Tags --}}
    <title>{{ $title ?? 'أنا المسلم - Ana Muslim' }}</title>
    <meta name="description" content="{{ $description ?? 'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأحاديث، ومواقيت الصلاة في مكان واحد' }}">
    <meta name="keywords" content="قرآن، أذكار، صلاة، حديث، إسلام، مسلم، Quran, Prayer, Islam, Muslim">
    <meta name="author" content="Ana Muslim">

    {{-- Open Graph Meta Tags --}}
    <meta property="og:title" content="{{ $title ?? 'أنا المسلم - Ana Muslim' }}">
    <meta property="og:description" content="{{ $description ?? 'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأحاديث، ومواقيت الصلاة في مكان واحد' }}">
    <meta property="og:type" content="website">
    <meta property="og:url" content="{{ url()->current() }}">
    <meta property="og:image" content="{{ asset('assets/images/og-image.png') }}">

    {{-- Twitter Card Meta Tags --}}
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="{{ $title ?? 'أنا المسلم - Ana Muslim' }}">
    <meta name="twitter:description" content="{{ $description ?? 'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأحاديث، ومواقيت الصلاة في مكان واحد' }}">

    {{-- Favicon --}}
    <link rel="icon" type="image/png" href="{{ asset('favicon.png') }}">
    <link rel="apple-touch-icon" href="{{ asset('apple-touch-icon.png') }}">

    {{-- Fonts --}}
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Readex+Pro:wght@300;400;500;600;700&family=Amiri:wght@400;700&display=swap" rel="stylesheet">

    {{-- Iconify for Icons --}}
    <script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>

    {{-- TailwindCSS + Custom Styles --}}
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        primary: '#11D4B4',
                        secondary: '#0F172A',
                    },
                    fontFamily: {
                        sans: ['Readex Pro', 'system-ui', 'sans-serif'],
                        arabic: ['Amiri', 'serif'],
                    }
                }
            }
        }
    </script>

    <style>
        * {
            -webkit-tap-highlight-color: transparent;
        }

        body {
            font-family: 'Readex Pro', system-ui, sans-serif;
        }

        [lang="ar"], [dir="rtl"] {
            font-family: 'Readex Pro', 'Amiri', serif;
        }

        [lang="en"], [dir="ltr"] {
            font-family: 'Readex Pro', system-ui, sans-serif;
        }

        /* LTR Adjustments */
        [dir="ltr"] .glass-panel,
        [dir="ltr"] nav,
        [dir="ltr"] footer {
            text-align: left;
        }

        /* Glass Morphism Effects */
        .glass-panel {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .dark .glass-panel {
            background: rgba(15, 23, 42, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .glass-button {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }

        .dark .glass-button {
            background: rgba(255, 255, 255, 0.05);
        }

        /* Smooth Scrolling */
        html {
            scroll-behavior: smooth;
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }

        ::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.05);
        }

        ::-webkit-scrollbar-thumb {
            background: rgba(17, 212, 180, 0.5);
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: rgba(17, 212, 180, 0.8);
        }

        .dark ::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.05);
        }

        /* Loading Animation */
        @keyframes pulse-soft {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .animate-pulse-soft {
            animation: pulse-soft 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }

        /* Hide Scrollbar for Mobile Menus */
        .hide-scrollbar::-webkit-scrollbar {
            display: none;
        }

        .hide-scrollbar {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }

        @yield('styles')
    </style>

    {{-- Additional Head Content --}}
    @stack('head')
</head>
<body class="bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-950 dark:to-slate-900 text-slate-900 dark:text-white transition-colors duration-300 min-h-screen">

    {{-- Navigation --}}
    @include('partials.web-navbar')

    {{-- Main Content --}}
    <main class="relative">
        @yield('content')
    </main>

    {{-- Footer (Optional) --}}
    @if(!isset($hideFooter) || !$hideFooter)
        @include('partials.web-footer')
    @endif

    {{-- Alpine.js (MUST load before the script below) --}}
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>

    {{-- i18n & Theme Management --}}
    <script>
        // i18n System
        function i18n() {
            return {
                locale: localStorage.getItem('locale') || 'ar',
                translations: {
                    ar: {
                        brand: {
                            name: 'أنا المسلم'
                        },
                        nav: {
                            home: 'الرئيسية',
                            quranText: 'القرآن الكريم',
                            quranPremium: 'القرآن الكريم - صوتي',
                            hisnmuslim: 'حصن المسلم',
                            privacy: 'الخصوصية',
                            menu: 'القائمة'
                        },
                        footer: {
                            description: 'تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأحاديث، ومواقيت الصلاة في مكان واحد. استمتع بتجربة روحانية فريدة مع تصميم عصري وأنيق.',
                            quickLinks: 'روابط سريعة',
                            legalSupport: 'الدعم والقانونية',
                            privacy: 'سياسة الخصوصية',
                            terms: 'شروط الاستخدام',
                            contact: 'تواصل معنا',
                            faq: 'الأسئلة الشائعة',
                            downloadApp: 'حمّل التطبيق الآن',
                            availableOn: 'متاح على جميع المنصات',
                            availableOnStore: 'متوفر على',
                            rights: 'جميع الحقوق محفوظة',
                            madeWithLove: 'صُنع بحب من أجل الأمة الإسلامية'
                        },
                        hisnmuslim: {
                            title: 'حصن المسلم',
                            subtitle: 'أذكار وأدعية من الكتاب والسنة مع الأحاديث الصوتية مرتبة لسهولة الوصول والحفظ',
                            search: 'ابحث في الأذكار والأدعية...',
                            filters: {
                                all: 'الكل',
                                morning: 'الصباح والمساء',
                                sleep: 'النوم',
                                wudu: 'الوضوء',
                                home: 'المنزل'
                            }
                        },
                        common: {
                            loading: 'جاري التحميل...',
                            error: 'حدث خطأ',
                            retry: 'إعادة المحاولة',
                            close: 'إغلاق',
                            back: 'رجوع',
                            copied: 'تم النسخ!'
                        }
                    },
                    en: {
                        brand: {
                            name: "I'm Muslim"
                        },
                        nav: {
                            home: 'Home',
                            quranText: 'Holy Quran',
                            quranPremium: 'Holy Quran - Audio',
                            hisnmuslim: 'Fortress of the Muslim',
                            privacy: 'Privacy',
                            menu: 'Menu'
                        },
                        footer: {
                            description: 'A comprehensive Islamic app combining the Holy Quran, supplications, hadiths, and prayer times in one place. Enjoy a unique spiritual experience with modern and elegant design.',
                            quickLinks: 'Quick Links',
                            legalSupport: 'Legal & Support',
                            privacy: 'Privacy Policy',
                            terms: 'Terms of Use',
                            contact: 'Contact Us',
                            faq: 'FAQ',
                            downloadApp: 'Download the App Now',
                            availableOn: 'Available on all platforms',
                            availableOnStore: 'Available on',
                            rights: 'All rights reserved',
                            madeWithLove: 'Made with love for the Muslim Ummah'
                        },
                        hisnmuslim: {
                            title: 'Fortress of the Muslim',
                            subtitle: 'Supplications and remembrances from the Quran and Sunnah with audio hadiths organized for easy access and memorization',
                            search: 'Search in supplications...',
                            filters: {
                                all: 'All',
                                morning: 'Morning & Evening',
                                sleep: 'Sleep',
                                wudu: 'Ablution',
                                home: 'Home'
                            }
                        },
                        common: {
                            loading: 'Loading...',
                            error: 'An error occurred',
                            retry: 'Retry',
                            close: 'Close',
                            back: 'Back',
                            copied: 'Copied!'
                        }
                    }
                },
                t(key) {
                    return key.split('.').reduce((o, i) => o[i], this.translations[this.locale]);
                },
                toggleLocale() {
                    this.locale = this.locale === 'ar' ? 'en' : 'ar';
                    localStorage.setItem('locale', this.locale);
                    document.documentElement.lang = this.locale;
                    document.documentElement.dir = this.locale === 'ar' ? 'rtl' : 'ltr';

                    // Reload page to apply language change
                    window.location.reload();
                }
            }
        }

        // Initialize theme on page load
        document.addEventListener('DOMContentLoaded', function() {
            const theme = localStorage.getItem('theme') || 'system';
            applyTheme(theme);
        });

        function applyTheme(theme) {
            if (theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
        }

        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (localStorage.getItem('theme') === 'system') {
                applyTheme('system');
            }
        });
    </script>

    {{-- Page-specific Scripts --}}
    @stack('scripts')

    {{-- Additional Body Content --}}
    @yield('scripts')
</body>
</html>
