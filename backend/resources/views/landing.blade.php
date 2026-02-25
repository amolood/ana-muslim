<!DOCTYPE html>
<html lang="ar" dir="rtl" x-data="i18n()" x-init="$nextTick(() => { document.documentElement.lang = locale; document.documentElement.dir = locale === 'ar' ? 'rtl' : 'ltr'; applyTheme(); })" :lang="locale" :dir="locale === 'ar' ? 'rtl' : 'ltr'" :class="{ 'dark': theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches) }">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title x-text="t('meta.title')">I'm Muslim - Modern Islamic Experience</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['IBM Plex Sans Arabic', 'sans-serif'],
                    },
                    colors: {
                        primary: '#11D4B4',
                    }
                }
            }
        }
    </script>
    <script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>
    @include('partials.theme-init')
    
    <style>
        html { scroll-behavior: smooth; }
        body { 
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Glassmorphism Utilities */
        .glass-panel {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(0, 0, 0, 0.04);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.05);
        }
        
        .dark .glass-panel {
            background: rgba(15, 23, 42, 0.85);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.5);
        }

        .glass-button {
            background: linear-gradient(135deg, rgba(255,255,255,1) 0%, rgba(255,255,255,0.6) 100%);
            border: 1px solid rgba(0,0,0,0.08);
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }

        .dark .glass-button {
            background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.02) 100%);
            border: 1px solid rgba(255,255,255,0.1);
        }

        /* Hide Scrollbar */
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* Sticky Player Animations */
        @keyframes slideUp {
            from { transform: translateY(100%); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .animate-slide-up { animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1); }

        /* Custom Range Input */
        input[type="range"] {
            -webkit-appearance: none;
            background: transparent;
            cursor: pointer;
            direction: ltr !important;
        }
        input[type="range"]::-webkit-slider-runnable-track {
            background: rgba(17, 212, 180, 0.1);
            height: 4px;
            border-radius: 2px;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            height: 12px;
            width: 12px;
            background: #11D4B4;
            border-radius: 50%;
            margin-top: -4px;
            box-shadow: 0 0 10px rgba(17, 212, 180, 0.5);
        }
        .dark input[type="range"]::-webkit-slider-runnable-track {
            background: rgba(255, 255, 255, 0.1);
        }

        /* Loading Bar Animation */
        .loading-bar {
            height: 2px;
            background: #11D4B4;
            position: absolute;
            top: 0;
            left: 0;
            width: 0;
            transition: width 0.3s ease;
            z-index: 50;
        }

        /* Modal Backdrop */
        .modal-backdrop {
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }
        /* Loading Spinner */
        .loading-spinner {
            border: 3px solid rgba(17, 212, 180, 0.1);
            border-top-color: #11D4B4;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Azkar Specific */
        .zikr-card {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .zikr-card:active {
            transform: scale(0.98);
        }
        .count-badge {
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .count-badge.bump {
            transform: scale(1.3);
            background: #11D4B4;
            color: white;
        }
    </style>
</head>
<body 
    x-data="i18n()"
    :dir="locale === 'ar' ? 'rtl' : 'ltr'"
    class="bg-[#F1F5F9] dark:bg-[#0B1121] text-slate-800 dark:text-slate-100 transition-colors duration-500 min-h-screen relative overflow-x-hidden selection:bg-primary/30">

    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <!-- Premium Location Permission Modal -->
    <div id="location-modal" class="fixed inset-0 z-[100] flex items-center justify-center p-4 hidden">
        <div class="absolute inset-0 modal-backdrop"></div>
        <div class="glass-panel w-full max-w-lg rounded-[2.5rem] p-8 md:p-12 relative z-10 animate-slide-up shadow-2xl">
            <div class="w-20 h-20 rounded-3xl bg-primary/20 text-primary flex items-center justify-center mx-auto mb-8">
                <iconify-icon icon="solar:map-point-wave-bold" class="text-4xl"></iconify-icon>
            </div>
            <h2 class="text-3xl font-bold text-center mb-4">مواقيت صلاة دقيقة</h2>
            <p class="text-slate-500 dark:text-slate-400 text-center leading-relaxed mb-10">
                نحتاج للوصول إلى موقعك الجغرافي لنتمكن من تزويدك بمواقيت صلاة دقيقة بناءً على منطقتك الحالية، والتاريخ الهجري المناسب.
            </p>
            <div class="flex flex-col gap-4">
                <button onclick="requestGeoLocation()" class="w-full bg-primary text-white py-4 rounded-2xl font-bold text-lg hover:scale-105 transition-transform shadow-lg shadow-primary/20">السماح بالوصول للموقع</button>
                <button onclick="showCityPicker()" class="w-full glass-button py-4 rounded-2xl font-bold text-slate-700 dark:text-white hover:bg-white/10 transition-colors">اختيار المدينة يدوياً</button>
            </div>
            <p class="text-center text-xs text-slate-500 mt-6">بيانات موقعك تستخدم لهذا الغرض فقط ولا يتم تخزينها.</p>
        </div>
    </div>

    <!-- City Picker Modal -->
    <div id="city-modal" class="fixed inset-0 z-[110] flex items-center justify-center p-4 hidden">
        <div class="absolute inset-0 modal-backdrop"></div>
        <div class="glass-panel w-full max-w-md rounded-[2.5rem] p-8 relative z-10 animate-slide-up shadow-2xl">
            <h3 class="text-xl font-bold text-center mb-6">اختر المدينة</h3>
            <div class="space-y-3 max-h-[400px] overflow-y-auto pr-2 no-scrollbar">
                @php
                    $cities = [
                        ['id' => 'riyadh', 'ar' => 'الرياض', 'en' => 'Riyadh', 'country' => 'SA'],
                        ['id' => 'makkah', 'ar' => 'مكة المكرمة', 'en' => 'Makkah', 'country' => 'SA'],
                        ['id' => 'cairo', 'ar' => 'القاهرة', 'en' => 'Cairo', 'country' => 'EG'],
                        ['id' => 'dubai', 'ar' => 'دبي', 'en' => 'Dubai', 'country' => 'AE'],
                        ['id' => 'casablanca', 'ar' => 'الدار البيضاء', 'en' => 'Casablanca', 'country' => 'MA'],
                        ['id' => 'khartoum', 'ar' => 'الخرطوم', 'en' => 'Khartoum', 'country' => 'SD'],
                        ['id' => 'kuwait', 'ar' => 'الكويت', 'en' => 'Kuwait', 'country' => 'KW'],
                        ['id' => 'doha', 'ar' => 'الدوحة', 'en' => 'Doha', 'country' => 'QA'],
                    ];
                @endphp
                @foreach($cities as $city)
                    <button onclick="selectCity('{{ $city['en'] }}', '{{ $city['country'] }}', '{{ $city['ar'] }}')" class="w-full text-right p-4 rounded-2xl glass-button hover:bg-primary/10 hover:border-primary/40 transition-all flex justify-between items-center">
                        <span class="font-medium">{{ $city['ar'] }}</span>
                        <iconify-icon icon="solar:alt-arrow-left-linear" class="text-slate-400"></iconify-icon>
                    </button>
                @endforeach
            </div>
            <button onclick="hideCityPicker()" class="w-full mt-6 py-3 text-slate-400 text-sm font-medium">رجوع</button>
        </div>
    </div>

    <!-- Navbar -->
    @include('partials.web-navbar')

    <!-- Main Content wrapper to stay above ambient bg -->
    <main class="relative z-10 pt-32 pb-20 px-4 sm:px-6">
        
        <!-- Hero Section -->
        <section class="max-w-7xl mx-auto min-h-[85vh] flex items-center justify-center mb-24">
            <div class="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
                
                <!-- Text Content -->
                <div class="flex flex-col items-start text-right">
                    <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-panel text-xs font-medium text-slate-700 dark:text-slate-300 mb-8 border border-white/40 dark:border-white/10">
                        <span class="relative flex h-2 w-2">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                        </span>
                        تحديث جديد: تجربة إسلامية متكاملة
                    </div>
                    
                    <h1 class="text-4xl sm:text-5xl lg:text-7xl font-bold tracking-tight leading-[1.1] mb-6 text-slate-950 dark:text-white" x-text="t('hero.title')"></h1>
                    <p class="text-base sm:text-lg text-slate-600 dark:text-slate-400 mb-10 leading-relaxed font-medium max-w-xl" x-text="t('hero.subtitle')"></p>
                    
                    <div class="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
                        <a href="{{ url('/quran') }}" class="flex items-center justify-center gap-3 bg-slate-900 dark:bg-white text-white dark:text-slate-900 px-8 py-4 rounded-full font-medium text-sm transition-transform hover:scale-105 shadow-xl shadow-slate-900/20 dark:shadow-white/10">
                            <iconify-icon icon="solar:book-bookmark-linear" class="text-2xl"></iconify-icon>
                            تصفح المصحف
                        </a>
                        <a href="{{ url('/hisnmuslim') }}" class="flex items-center justify-center gap-3 glass-button text-slate-900 dark:text-white px-8 py-4 rounded-full font-medium text-sm transition-transform hover:scale-105">
                            <iconify-icon icon="solar:shield-star-bold" class="text-2xl"></iconify-icon>
                            حصن المسلم
                        </a>
                    </div>

                    <!-- Google Play Download Badge -->
                    <div class="mt-4">
                        <a href="https://play.google.com/store/apps/details?id=com.anaalmuslim.app" target="_blank" rel="noopener" class="inline-flex items-center gap-3 bg-[#0a0a0a] text-white px-6 py-3 rounded-full font-medium text-sm transition-all hover:scale-105 hover:bg-[#1a1a1a] shadow-lg border border-white/10">
                            <iconify-icon icon="logos:google-play-icon" class="text-2xl shrink-0"></iconify-icon>
                            <div class="text-right">
                                <div class="text-[10px] text-slate-400 leading-none mb-0.5">متاح الآن على</div>
                                <div class="text-sm font-semibold leading-none">Google Play</div>
                            </div>
                        </a>
                    </div>
                </div>

                <!-- Glass UI Mockup -->
                <div class="relative w-full max-w-md mx-auto lg:ml-0 lg:mr-auto perspective-[1000px]">
                    <div class="glass-panel rounded-[2.5rem] p-6 transform lg:rotate-y-[-12deg] lg:rotate-x-[5deg] hover:rotate-0 transition-transform duration-700 ease-out shadow-2xl">
                        
                        <!-- Mockup Header -->
                        <div class="flex justify-between items-center mb-8">
                            <div class="flex-1">
                                <h3 class="text-sm font-medium text-slate-400 dark:text-slate-500 mb-1">الصلاة القادمة</h3>
                                <div class="flex items-baseline gap-2">
                                    <span id="next-prayer-name" class="text-3xl font-semibold tracking-tight">--</span>
                                    <span id="next-prayer-time" class="text-lg text-slate-500 dark:text-slate-400 font-medium">--:--</span>
                                </div>
                                <div class="mt-3">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span id="next-prayer-countdown" class="text-sm text-primary font-bold">--:--:--</span>
                                        <span class="text-xs text-slate-500">متبقي</span>
                                    </div>
                                    <div class="w-full h-1.5 bg-slate-200 dark:bg-slate-700 rounded-full overflow-hidden">
                                        <div id="prayer-progress-bar" class="h-full bg-gradient-to-r from-primary to-emerald-400 transition-all duration-1000" style="width: 0%"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="w-12 h-12 rounded-full glass-button flex items-center justify-center">
                                <iconify-icon icon="solar:clock-circle-linear" class="text-xl text-slate-700 dark:text-white"></iconify-icon>
                            </div>
                        </div>

                        <!-- Main Widget (Prayer Quick View) -->
                        <div id="prayer-widget" class="relative overflow-hidden rounded-2xl glass-button p-5 mb-4 group cursor-pointer">
                            <div class="absolute -left-6 -bottom-6 opacity-10 transform group-hover:scale-110 transition-transform duration-500">
                                <iconify-icon icon="solar:clock-circle-linear" class="text-9xl text-slate-900 dark:text-white"></iconify-icon>
                            </div>
                            <div class="relative z-10">
                                <div class="flex justify-between items-start mb-4">
                                    <div id="location-badge" class="text-[10px] font-medium px-3 py-1.5 glass-panel rounded-full">جاري تحديد الموقع...</div>
                                    <button onclick="showCityPicker()" class="text-[9px] text-primary hover:underline">تغيير</button>
                                </div>
                                <div class="grid grid-cols-5 gap-1 text-center mb-4">
                                    @foreach(['Fajr' => 'فجر', 'Dhuhr' => 'ظهر', 'Asr' => 'عصر', 'Maghrib' => 'مغرب', 'Isha' => 'عشاء'] as $id => $name)
                                        <div class="flex flex-col gap-1">
                                            <span class="text-[8px] text-slate-500">{{ $name }}</span>
                                            <span data-prayer="{{ $id }}" class="text-[10px] font-bold">--:--</span>
                                        </div>
                                    @endforeach
                                </div>
                                <div class="p-2 rounded-xl bg-primary/5 border border-primary/10 text-center">
                                    <span id="hijri-date" class="text-[10px] font-bold text-primary">-- --- ---- هـ</span>
                                </div>
                            </div>
                        </div>

                        <!-- Grid Tools -->
                        <div class="grid grid-cols-4 gap-3">
                            <a href="{{ url('/hisnmuslim') }}" class="aspect-square rounded-2xl glass-button flex flex-col items-center justify-center gap-2 hover:bg-primary/5 transition-colors cursor-pointer">
                                <iconify-icon icon="solar:shield-star-bold" class="text-lg text-emerald-500"></iconify-icon>
                                <span class="text-[9px] font-medium">حصن المسلم</span>
                            </a>
                            <a href="{{ url('/quran') }}" class="aspect-square rounded-2xl glass-button flex flex-col items-center justify-center gap-2 hover:bg-primary/5 transition-colors cursor-pointer">
                                <iconify-icon icon="solar:book-bookmark-linear" class="text-lg text-indigo-500"></iconify-icon>
                                <span class="text-[9px] font-medium">قرآن</span>
                            </a>
                            <div class="aspect-square rounded-2xl glass-button flex flex-col items-center justify-center gap-2 hover:bg-primary/5 transition-colors cursor-pointer">
                                <iconify-icon icon="solar:compass-square-linear" class="text-lg text-rose-500"></iconify-icon>
                                <span class="text-[9px] font-medium">قبلة</span>
                            </div>
                            <div class="aspect-square rounded-2xl glass-button flex flex-col items-center justify-center gap-2 hover:bg-primary/5 transition-colors cursor-pointer">
                                <iconify-icon icon="solar:calendar-linear" class="text-lg text-amber-500"></iconify-icon>
                                <span class="text-[9px] font-medium">تقويم</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Random Ayah Section -->
        <section class="max-w-4xl mx-auto mb-24">
            <div id="randomAyah" class="glass-panel rounded-[2.5rem] p-8 sm:p-12 text-center border-2 border-primary/20 shadow-2xl">
                <!-- Loading State -->
                <div id="ayahLoading" class="flex items-center justify-center py-12">
                    <div class="loading-spinner"></div>
                </div>

                <!-- Ayah Content (will be loaded by JavaScript) -->
                <div id="ayahContent" class="hidden">
                    <!-- Content will be injected here -->
                </div>
            </div>
        </section>

        <!-- Bento Grid Features Icons -->
        <section id="features" class="max-w-7xl mx-auto py-24">
            <div class="text-center mb-16 max-w-2xl mx-auto">
                <h2 class="text-3xl sm:text-4xl font-semibold tracking-tight mb-4 text-slate-900 dark:text-white">بنية متكاملة لتجربة سلسة</h2>
                <p class="text-sm text-slate-600 dark:text-slate-400">استكشف أدواتنا المصممة بعناية فائقة لتندمج مع روتينك اليومي بكل بساطة وجمال.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Quran Card -->
                <a href="{{ url('/quran') }}" class="glass-panel rounded-3xl p-8 flex flex-col justify-between group hover:shadow-2xl hover:shadow-primary/10 transition-all duration-500 border border-transparent hover:border-primary/20">
                    <div class="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform">
                        <iconify-icon icon="solar:book-bookmark-linear" class="text-2xl"></iconify-icon>
                    </div>
                    <div>
                        <h3 class="text-xl font-bold mb-2">المصحف الشريف</h3>
                        <p class="text-[13px] text-slate-500 dark:text-slate-400 leading-relaxed">استمع لتلاوات خاشعة من كبار القراء في العالم الإسلامي مع واجهة استماع متطورة.</p>
                    </div>
                </a>

                <!-- Prayer Times Card -->
                <div class="glass-panel rounded-3xl p-8 flex flex-col justify-between group hover:shadow-2xl hover:shadow-blue-500/10 transition-all duration-500 border border-transparent hover:border-blue-500/20">
                    <div class="w-12 h-12 rounded-2xl bg-blue-500/10 flex items-center justify-center text-blue-500 mb-6 group-hover:scale-110 transition-transform">
                        <iconify-icon icon="solar:clock-circle-linear" class="text-2xl"></iconify-icon>
                    </div>
                    <div>
                        <h3 class="text-xl font-bold mb-2">مواقيت الصلاة</h3>
                        <p class="text-[13px] text-slate-600 dark:text-slate-400 leading-relaxed">تنبيهات دقيقة لكل صلاة بناءً على موقعك الجغرافي مع عرض للتاريخ الهجري.</p>
                    </div>
                </div>

                <!-- Qibla Card -->
                <div class="glass-panel rounded-3xl p-8 flex flex-col justify-between group hover:shadow-2xl hover:shadow-rose-500/10 transition-all duration-500 border border-transparent hover:border-rose-500/20">
                    <div class="w-12 h-12 rounded-2xl bg-rose-500/10 flex items-center justify-center text-rose-500 mb-6 group-hover:scale-110 transition-transform">
                        <iconify-icon icon="solar:compass-square-linear" class="text-2xl"></iconify-icon>
                    </div>
                    <div>
                        <h3 class="text-xl font-bold mb-2">محدد القبلة</h3>
                        <p class="text-[13px] text-slate-600 dark:text-slate-400 leading-relaxed">بوصلة زجاجية عالية الدقة لتحديد اتجاه القبلة من أي مكان في العالم.</p>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Enhanced Sticky Bottom Player -->
    <div id="sticky-player" class="fixed bottom-0 left-0 right-0 z-[100] transform translate-y-full transition-transform duration-500 ease-out pb-safe">
        <div id="loading-bar" class="loading-bar"></div>
        <div class="max-w-7xl mx-auto px-4 pb-6">
            <div class="glass-panel rounded-2xl md:rounded-full p-4 md:px-8 border-primary/20 shadow-2xl flex flex-col md:flex-row items-center gap-4 md:gap-8">
                
                <!-- Current Info -->
                <div class="flex items-center gap-4 w-full md:w-1/4">
                    <div class="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-primary flex-shrink-0 relative">
                        <div id="player-spinner" class="absolute inset-0 rounded-full border-2 border-primary border-t-transparent animate-spin hidden"></div>
                        <iconify-icon icon="solar:music-note-2-linear" class="text-xl"></iconify-icon>
                    </div>
                    <div class="overflow-hidden">
                        <h4 id="player-surah-name" class="font-bold text-sm truncate">اختر سورة...</h4>
                        <p id="player-reciter-name" class="text-[10px] text-slate-500 truncate">اسم القارئ</p>
                    </div>
                </div>

                <!-- Main Controls -->
                <div class="flex flex-col items-center gap-2 w-full md:w-2/4">
                    <div class="flex items-center gap-6">
                        <button onclick="prevSurah()" class="text-slate-400 hover:text-primary transition-colors">
                            <iconify-icon icon="solar:skip-back-bold" class="text-xl"></iconify-icon>
                        </button>
                        <button id="main-play-pause" class="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center hover:scale-110 transition-transform shadow-lg shadow-primary/20">
                            <iconify-icon icon="solar:play-bold" class="text-2xl"></iconify-icon>
                        </button>
                        <button onclick="nextSurah()" class="text-slate-400 hover:text-primary transition-colors">
                            <iconify-icon icon="solar:skip-forward-bold" class="text-xl"></iconify-icon>
                        </button>
                    </div>
                    
                    <!-- Progress Bar -->
                    <div class="flex items-center gap-3 w-full" dir="ltr">
                        <span id="current-time" class="text-[10px] text-slate-400 font-medium tabular-nums">0:00</span>
                        <div class="relative w-full group py-2">
                            <input type="range" id="player-seek" value="0" step="0.1" class="w-full absolute inset-0 opacity-0 z-20 cursor-pointer">
                            <div class="w-full h-1 bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden relative z-10">
                                <div id="seek-progress" class="bg-primary h-full w-0 transition-all duration-100"></div>
                            </div>
                        </div>
                        <span id="duration" class="text-[10px] text-slate-400 font-medium tabular-nums">0:00</span>
                    </div>
                </div>

                <!-- Extra Controls -->
                <div class="hidden md:flex items-center justify-end gap-4 w-1/4">
                    <div class="flex items-center gap-2" dir="ltr">
                        <button id="mute-btn" class="text-slate-400 hover:text-primary">
                            <iconify-icon icon="solar:volume-loud-linear" class="text-xl"></iconify-icon>
                        </button>
                        <input type="range" id="volume-slider" min="0" max="1" step="0.05" value="1" class="w-20">
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Footer -->
    @include('partials.web-footer')

    <!-- ✅ تعريف i18n() قبل تحميل Alpine.js -->
    <script>
        function i18n() {
            return {
                locale: localStorage.getItem('locale') || 'ar',
                theme: localStorage.getItem('theme') || 'system',
                translations: {
                    ar: {
                        meta: {
                            title: 'أنا المسلم - تجربة إسلامية حديثة'
                        },
                        brand: {
                            name: 'أنا المسلم'
                        },
                        nav: {
                            home: 'الرئيسية',
                            quranPremium: 'القرآن الكريم',
                            quranText: 'القرآن النصي',
                            hisnmuslim: 'حصن المسلم',
                            privacy: 'الخصوصية',
                            features: 'المميزات',
                            experience: 'التجربة',
                            download: 'التحميل',
                            menu: 'القائمة'
                        },
                        hero: {
                            title: 'روحانية الإيمان بتصميم عصري',
                            subtitle: 'تطبيق يجمع بين أناقة التصميم وقوة الأداء. استمتع بتجربة خالية من المشتتات مع أدوات متكاملة.'
                        },
                        ayah: {
                            verseOfDay: 'آية اليوم',
                            surah: 'سورة',
                            verse: 'الآية',
                            meccan: 'مكية',
                            medinan: 'مدنية',
                            another: 'آية أخرى'
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
                        }
                    },
                    en: {
                        meta: {
                            title: "I'm Muslim - Modern Islamic Experience"
                        },
                        brand: {
                            name: "I'm Muslim"
                        },
                        nav: {
                            home: 'Home',
                            quranPremium: 'Holy Quran',
                            quranText: 'Quran Text',
                            hisnmuslim: 'Fortress of the Muslim',
                            privacy: 'Privacy',
                            features: 'Features',
                            experience: 'Experience',
                            download: 'Download',
                            menu: 'Menu'
                        },
                        hero: {
                            title: 'Spiritual Faith, Modern Design',
                            subtitle: 'An app that combines elegance with performance. Enjoy a distraction-free experience with integrated tools.'
                        },
                        ayah: {
                            verseOfDay: 'Verse of the Day',
                            surah: 'Surah',
                            verse: 'Verse',
                            meccan: 'Meccan',
                            medinan: 'Medinan',
                            another: 'Another Verse'
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
                    window.location.reload();
                },
                applyTheme() {
                    if (this.theme === 'dark' || (this.theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                        document.documentElement.classList.add('dark');
                    } else {
                        document.documentElement.classList.remove('dark');
                    }
                }
            }
        }

        // Apply theme on page load
        window.addEventListener('DOMContentLoaded', () => {
            const theme = localStorage.getItem('theme') || 'system';
            if (theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
        });
    </script>

    <!-- ✅ تحميل Alpine.js بعد تعريف جميع الدوال -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!-- Random Ayah Script -->
    <script>
        async function loadRandomAyah() {
            const ayahLoading = document.getElementById('ayahLoading');
            const ayahContent = document.getElementById('ayahContent');
            const locale = localStorage.getItem('locale') || 'ar';

            try {
                // Get random ayah (1-6236)
                const randomAyahNumber = Math.floor(Math.random() * 6236) + 1;
                const response = await fetch(`https://api.alquran.cloud/v1/ayah/${randomAyahNumber}/ar.alafasy`);
                const data = await response.json();

                if (data.code === 200) {
                    const ayah = data.data;

                    ayahLoading.classList.add('hidden');
                    ayahContent.classList.remove('hidden');
                    ayahContent.innerHTML = `
                        <div class="mb-4">
                            <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary/10 border border-primary/20 mb-6">
                                <iconify-icon icon="solar:book-bookmark-bold-duotone" width="16" height="16" class="text-primary"></iconify-icon>
                                <span class="text-sm font-bold text-primary">${locale === 'ar' ? 'آية اليوم' : 'Verse of the Day'}</span>
                            </div>
                        </div>

                        <p class="text-2xl sm:text-3xl md:text-4xl font-arabic leading-loose text-slate-800 dark:text-slate-200 mb-8" style="font-family: 'Amiri', serif;">
                            ${ayah.text}
                        </p>

                        <div class="flex flex-col sm:flex-row items-center justify-center gap-4 text-sm text-slate-600 dark:text-slate-400">
                            <div class="flex items-center gap-2">
                                <iconify-icon icon="solar:book-2-bold-duotone" width="20" height="20" class="text-primary"></iconify-icon>
                                <span class="font-bold">${locale === 'ar' ? 'سورة' : 'Surah'} ${ayah.surah.name}</span>
                            </div>
                            <span class="hidden sm:inline text-slate-300 dark:text-slate-700">•</span>
                            <div class="flex items-center gap-2">
                                <iconify-icon icon="solar:hashtag-bold-duotone" width="20" height="20" class="text-primary"></iconify-icon>
                                <span>${locale === 'ar' ? 'الآية' : 'Verse'} ${ayah.numberInSurah}</span>
                            </div>
                            <span class="hidden sm:inline text-slate-300 dark:text-slate-700">•</span>
                            <div class="flex items-center gap-2">
                                <iconify-icon icon="solar:square-academic-cap-bold-duotone" width="20" height="20" class="text-primary"></iconify-icon>
                                <span>${ayah.surah.revelationType === 'Meccan' ? (locale === 'ar' ? 'مكية' : 'Meccan') : (locale === 'ar' ? 'مدنية' : 'Medinan')}</span>
                            </div>
                        </div>

                        <div class="mt-8">
                            <button onclick="loadRandomAyah()" class="inline-flex items-center gap-2 px-6 py-3 bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-2xl hover:bg-slate-200 dark:hover:bg-slate-700 transition-all font-medium">
                                <iconify-icon icon="solar:refresh-bold-duotone" width="20" height="20"></iconify-icon>
                                ${locale === 'ar' ? 'آية أخرى' : 'Another Verse'}
                            </button>
                        </div>
                    `;
                }
            } catch (error) {
                console.error('Error loading random ayah:', error);
                ayahLoading.innerHTML = `
                    <div class="text-center py-8">
                        <iconify-icon icon="solar:danger-circle-bold" width="48" height="48" class="text-red-500 mb-4"></iconify-icon>
                        <p class="text-slate-600 dark:text-slate-400">حدث خطأ في تحميل الآية</p>
                    </div>
                `;
            }
        }

        // Load random ayah when page loads
        window.addEventListener('DOMContentLoaded', loadRandomAyah);
    </script>

    <script>
        const locationModal = document.getElementById('location-modal');
        const cityModal = document.getElementById('city-modal');

        // Premium Location Flow
        function showLocationModal() {
            locationModal.classList.remove('hidden');
        }

        function hideLocationModal() {
            locationModal.classList.add('hidden');
        }

        function showCityPicker() {
            hideLocationModal();
            cityModal.classList.remove('hidden');
        }

        function hideCityPicker() {
            cityModal.classList.add('hidden');
            showLocationModal();
        }

        function requestGeoLocation() {
            hideLocationModal();
            if ("geolocation" in navigator) {
                navigator.geolocation.getCurrentPosition(async (position) => {
                    const { latitude, longitude } = position.coords;
                    localStorage.setItem('user_lat', latitude);
                    localStorage.setItem('user_lng', longitude);
                    localStorage.removeItem('user_city');
                    fetchPrayerTimes();
                }, (error) => {
                    console.error('Geo error:', error);
                    showCityPicker(); // Fallback to city picker on error or denial
                });
            } else {
                showCityPicker();
            }
        }

        async function selectCity(cityEn, country, cityAr) {
            cityModal.classList.add('hidden');
            localStorage.setItem('user_city', JSON.stringify({ en: cityEn, country: country, ar: cityAr }));
            localStorage.removeItem('user_lat');
            localStorage.removeItem('user_lng');
            fetchPrayerTimes();
        }

        // Prayer Times Logic
        async function fetchPrayerTimes() {
            const savedLat = localStorage.getItem('user_lat');
            const savedCity = localStorage.getItem('user_city');

            if (savedLat) {
                const savedLng = localStorage.getItem('user_lng');
                try {
                    const resp = await fetch(`https://api.aladhan.com/v1/timings?latitude=${savedLat}&longitude=${savedLng}&method=4`);
                    const data = await resp.json();
                    updatePrayerUI(data.data);
                } catch (e) { fallbackPrayerTimes(); }
            } else if (savedCity) {
                const city = JSON.parse(savedCity);
                try {
                    const resp = await fetch(`https://api.aladhan.com/v1/timingsByCity?city=${city.en}&country=${city.country}&method=4`);
                    const data = await resp.json();
                    updatePrayerUI(data.data, city.ar);
                } catch (e) { fallbackPrayerTimes(); }
            } else {
                showLocationModal();
            }
        }

        let countdownInterval = null;
        let prayerTimings = {};
        let previousPrayerTime = null;

        function updatePrayerUI(data, cityLabel = null) {
            const timings = data.timings;
            const date = data.date;

            document.getElementById('location-badge').textContent = cityLabel || data.meta.timezone;
            document.getElementById('hijri-date').textContent = `${date.hijri.day} ${date.hijri.month.ar} ${date.hijri.year} هـ`;

            // Update prayer times display
            const elements = document.querySelectorAll('[data-prayer]');
            elements.forEach(el => {
                const prayer = el.getAttribute('data-prayer');
                if (timings[prayer]) {
                    el.textContent = timings[prayer];
                }
            });

            // Store timings for countdown
            prayerTimings = {
                'Fajr': timings.Fajr,
                'Dhuhr': timings.Dhuhr,
                'Asr': timings.Asr,
                'Maghrib': timings.Maghrib,
                'Isha': timings.Isha
            };

            // Start countdown
            updateNextPrayer();
            if (countdownInterval) clearInterval(countdownInterval);
            countdownInterval = setInterval(updateNextPrayer, 1000);
        }

        function updateNextPrayer() {
            const now = new Date();
            const prayerNames = {
                'Fajr': 'الفجر',
                'Dhuhr': 'الظهر',
                'Asr': 'العصر',
                'Maghrib': 'المغرب',
                'Isha': 'العشاء'
            };

            const prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
            let nextPrayer = null;
            let prevPrayer = null;
            let minDiff = Infinity;

            for (let i = 0; i < prayerOrder.length; i++) {
                const key = prayerOrder[i];
                const time = prayerTimings[key];
                const [hours, minutes] = time.split(':').map(Number);
                const prayerTime = new Date();
                prayerTime.setHours(hours, minutes, 0, 0);

                const diff = prayerTime - now;

                if (diff > 0 && diff < minDiff) {
                    minDiff = diff;
                    nextPrayer = { key, time, name: prayerNames[key] };
                    // Get previous prayer
                    if (i > 0) {
                        const prevKey = prayerOrder[i - 1];
                        prevPrayer = prayerTimings[prevKey];
                    }
                }
            }

            if (!nextPrayer) {
                // All prayers passed, next is Fajr tomorrow
                nextPrayer = {
                    key: 'Fajr',
                    time: prayerTimings.Fajr,
                    name: prayerNames.Fajr
                };
                const [hours, minutes] = nextPrayer.time.split(':').map(Number);
                const tomorrow = new Date(now);
                tomorrow.setDate(tomorrow.getDate() + 1);
                tomorrow.setHours(hours, minutes, 0, 0);
                minDiff = tomorrow - now;
                prevPrayer = prayerTimings.Isha;
            }

            // Update UI
            document.getElementById('next-prayer-name').textContent = nextPrayer.name;
            document.getElementById('next-prayer-time').textContent = nextPrayer.time;

            // Format countdown
            const hours = Math.floor(minDiff / (1000 * 60 * 60));
            const minutes = Math.floor((minDiff % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((minDiff % (1000 * 60)) / 1000);

            document.getElementById('next-prayer-countdown').textContent =
                `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

            // Calculate progress bar
            if (prevPrayer) {
                const [prevHours, prevMinutes] = prevPrayer.split(':').map(Number);
                const prevTime = new Date();
                prevTime.setHours(prevHours, prevMinutes, 0, 0);

                const [nextHours, nextMinutes] = nextPrayer.time.split(':').map(Number);
                const nextTime = new Date();
                nextTime.setHours(nextHours, nextMinutes, 0, 0);
                if (nextTime < prevTime) nextTime.setDate(nextTime.getDate() + 1);

                const totalDuration = nextTime - prevTime;
                const elapsed = now - prevTime;
                const progress = Math.min(100, Math.max(0, (elapsed / totalDuration) * 100));

                document.getElementById('prayer-progress-bar').style.width = progress + '%';
            }
        }

        function fallbackPrayerTimes() {
            document.getElementById('location-badge').textContent = "الرياض، السعودية";
        }

        fetchPrayerTimes();
    </script>
</body>
</html>