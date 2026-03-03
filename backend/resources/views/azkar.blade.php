<!DOCTYPE html>
<html lang="ar" dir="rtl" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>الأذكار - أنا المسلم</title>
    
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
        .glass-panel {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(0, 0, 0, 0.04);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.05);
        }
        .dark .glass-panel {
            background: rgba(15, 23, 42, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(40px);
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
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</head>
<body 
    x-data="azkarApp()"
    :dir="locale === 'ar' ? 'rtl' : 'ltr'"
    class="bg-[#F1F5F9] dark:bg-[#0B1121] text-slate-800 dark:text-slate-100 transition-colors duration-500 min-h-screen relative overflow-x-hidden selection:bg-primary/30">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <!-- Floating Navbar -->
    <nav class="fixed top-4 left-4 right-4 max-w-7xl mx-auto z-50 glass-panel rounded-full px-6 h-16 flex items-center justify-between">
        <div class="flex items-center gap-8">
            <a href="{{ url('/') }}" class="flex items-center gap-2.5">
                <svg width="36" height="36" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg" class="shrink-0">
                    <path d="M256 42 C270 28 284 26 295 30 C282 40 276 54 278 68 C280 82 290 93 304 97 C310 99 316 99 320 98 C312 114 294 122 274 118 C251 113 238 91 242 68 C245 55 250 47 256 42Z" fill="#2d7a22"/>
                    <circle cx="256" cy="108" r="5" fill="#2d7a22"/>
                    <circle cx="256" cy="122" r="3.5" fill="#2d7a22"/>
                    <path d="M256 148 C210 148 148 192 148 268 C148 334 196 390 256 405 C316 390 364 334 364 268 C364 192 302 148 256 148Z" fill="#6abf45"/>
                    <path d="M256 148 L304 220 L256 248 L208 220 Z" fill="#2d7a22" opacity="0.85"/>
                    <path d="M256 250 C240 250 224 264 224 285 L224 370 C234 378 245 382 256 383 C267 382 278 378 288 370 L288 285 C288 264 272 250 256 250Z" fill="#020617"/>
                </svg>
                <span class="text-lg font-bold tracking-tight text-slate-900 dark:text-white">أنا المسلم</span>
            </a>
            <div class="hidden md:flex items-center gap-6 text-sm font-bold">
                <a href="{{ url('/') }}" class="text-slate-600 dark:text-slate-400 hover:text-primary transition-colors" x-text="t('nav.home')"></a>
                <a href="{{ url('/quran-text') }}" class="text-slate-600 dark:text-slate-400 hover:text-primary transition-colors" x-text="t('nav.quranText')"></a>
                <a href="{{ url('/hisnmuslim') }}" class="text-slate-600 dark:text-slate-400 hover:text-primary transition-colors" x-text="t('nav.hisnmuslim')"></a>
                <a href="{{ url('/azkar') }}" class="text-primary" x-text="t('nav.azkar')"></a>
                <a href="{{ url('/privacy') }}" class="text-slate-600 dark:text-slate-400 hover:text-primary transition-colors" x-text="t('nav.privacy')"></a>
            </div>
        </div>
        <div class="flex items-center gap-3">
            <button @click="toggleLocale()" class="w-10 h-10 rounded-full glass-button flex items-center justify-center text-xs font-bold hover:text-primary transition-colors">
                <span x-text="locale === 'ar' ? 'EN' : 'AR'"></span>
            </button>
            @include('partials.theme-switcher')
        </div>
    </nav>

    <main class="max-w-4xl mx-auto px-4 pt-32 pb-20 relative z-10">
        <div class="glass-panel rounded-[2.5rem] p-8 md:p-12 border-primary/10 shadow-xl overflow-hidden relative">
            <div class="flex flex-col sm:flex-row justify-between items-center mb-8 gap-4">
                <div id="category-container" class="flex gap-2 overflow-x-auto no-scrollbar py-2 border-b border-primary/5 w-full">
                    <!-- Categories injected here -->
                </div>
            </div>

            <div x-show="loading" class="flex flex-col items-center justify-center py-20">
                <iconify-icon icon="solar:spinner-bold" class="text-4xl text-primary animate-spin mb-4"></iconify-icon>
                <p class="text-slate-500 dark:text-slate-400" x-text="t('loading')"></p>
            </div>

            <div x-show="!loading && loadError" class="flex flex-col items-center justify-center py-16 text-center">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center mb-4" style="background:rgba(239,68,68,.1);">
                    <iconify-icon icon="solar:wifi-router-minimalistic-bold" class="text-3xl" style="color:#ef4444;"></iconify-icon>
                </div>
                <p class="font-bold text-slate-700 dark:text-slate-200 mb-1" x-text="errorMsg"></p>
                <button @click="loadError = false; errorMsg = ''; init()"
                        class="mt-4 flex items-center gap-2 px-6 py-2.5 rounded-2xl font-bold text-sm text-white transition-all hover:opacity-90"
                        style="background:linear-gradient(135deg,#11D4B4,#0d9e87);">
                    <iconify-icon icon="solar:refresh-bold"></iconify-icon>
                    <span x-text="locale === 'ar' ? 'إعادة المحاولة' : 'Retry'"></span>
                </button>
            </div>

            <div x-show="!loading && !loadError" id="azkar-list" class="grid gap-4">
                <template x-for="item in items" :key="item.id">
                    <div class="zikr-card glass-button rounded-3xl p-6 cursor-pointer hover:bg-primary/5 transition-all text-right group" @click="updateCount($event.currentTarget, item.count)">
                        <p class="text-lg leading-relaxed mb-6 text-slate-800 dark:text-slate-200 font-bold" x-text="item.zekr"></p>
                        <p x-show="item.description" class="text-sm text-slate-600 dark:text-slate-400 mb-4 font-medium" x-text="item.description"></p>
                        <div class="flex justify-between items-center">
                            <span class="text-xs text-slate-500 dark:text-slate-400 font-bold" x-text="item.reference ? (locale === 'ar' ? 'المصدر: ' : 'Ref: ') + item.reference : ''"></span>
                            <div class="count-badge w-12 h-12 rounded-full bg-slate-200 dark:bg-slate-800 flex items-center justify-center text-sm font-bold text-slate-600 dark:text-slate-500" x-text="item.count"></div>
                        </div>
                    </div>
                </template>
            </div>
        </div>
    </main>

    <!-- ✅ تعريف azkarApp() قبل تحميل Alpine.js -->
    <script>
        function azkarApp() {
            return {
                locale: localStorage.getItem('locale') || 'ar',
                loading: false,
                loadError: false,
                errorMsg: '',
                items: [],
                categories: [],
                currentCategoryId: null,
                translations: {
                    ar: { nav: { home: 'الرئيسية', quranText: 'القرآن النصي', hisnmuslim: 'حصن المسلم', azkar: 'الأذكار', privacy: 'الخصوصية' }, loading: 'جاري تحميل المحتوى...' },
                    en: { nav: { home: 'Home', quranText: 'Quran Text', hisnmuslim: 'Hisn Al-Muslim', azkar: 'Azkar', privacy: 'Privacy' }, loading: 'Loading content...' }
                },
                t(key) { return key.split('.').reduce((o, i) => o[i], this.translations[this.locale]); },
                toggleLocale() {
                    this.locale = this.locale === 'ar' ? 'en' : 'ar';
                    localStorage.setItem('locale', this.locale);
                    document.documentElement.lang = this.locale;
                    document.documentElement.dir = this.locale === 'ar' ? 'rtl' : 'ltr';
                    this.init(); // Re-fetch for new locale
                },
                async init() {
                    this.loading = true;
                    try {
                        // Use local API for hisnmuslim data
                        const resp = await fetch('/api/hisnmuslim/chapters');
                        const chapters = await resp.json();

                        this.categories = chapters.map(chapter => ({
                            ID: chapter.chapter_id,
                            TITLE: this.locale === 'ar' ? chapter.title_ar : (chapter.title_en || chapter.title_ar)
                        }));

                        // Default to first category
                        if (this.categories.length > 0) {
                            await this.fetchItems(this.categories[0].ID);
                        }
                    } catch (e) {
                        console.error('Error fetching categories:', e);
                        this.loadError = true;
                        this.errorMsg = this.locale === 'ar' ? 'تعذّر تحميل الأبواب. تحقق من اتصالك بالإنترنت.' : 'Error loading chapters. Check your connection.';
                    }
                    this.renderCategories();
                    this.loading = false;
                },
                async fetchItems(id) {
                    this.loading = true;
                    this.currentCategoryId = id;
                    try {
                        // Use local API for duas
                        const resp = await fetch(`/api/hisnmuslim/duas/${id}`);
                        const data = await resp.json();

                        if (data.duas && Array.isArray(data.duas)) {
                            this.items = data.duas.map(dua => ({
                                zekr: dua.text_ar,
                                description: this.locale === 'ar' ? (dua.translation_ar || '') : (dua.translation_en || dua.translation_ar || ''),
                                reference: dua.reference || '',
                                count: dua.count || 1
                            }));
                        } else {
                            this.items = [];
                        }
                    } catch (e) {
                        console.error('Error fetching duas:', e);
                        this.loadError = true;
                        this.errorMsg = this.locale === 'ar' ? 'تعذّر تحميل الأذكار. تحقق من اتصالك بالإنترنت.' : 'Error loading duas. Check your connection.';
                        this.items = [];
                    }
                    this.loading = false;
                },
                renderCategories() {
                    const container = document.getElementById('category-container');
                    container.innerHTML = '';
                    this.categories.forEach(cat => {
                        const btn = document.createElement('button');
                        const isActive = this.currentCategoryId === cat.ID;
                        btn.className = isActive 
                            ? 'whitespace-nowrap px-6 py-2.5 rounded-2xl text-sm font-bold transition-all bg-primary text-white shadow-lg shadow-primary/20'
                            : 'whitespace-nowrap px-6 py-2.5 rounded-2xl text-sm font-bold transition-all border border-primary/10 hover:bg-primary/5';
                        btn.textContent = cat.TITLE;
                        btn.onclick = () => this.fetchItems(cat.ID).then(() => this.renderCategories());
                        container.appendChild(btn);
                    });
                },
                updateCount(card, target) {
                    const badge = card.querySelector('.count-badge');
                    let current = parseInt(badge.textContent);
                    if (current > 0) {
                        current--;
                        badge.textContent = current;
                        badge.classList.add('bump');
                        setTimeout(() => badge.classList.remove('bump'), 300);
                        if (current === 0) card.classList.add('opacity-40');
                    }
                }
            }
        }
    </script>

    <!-- ✅ تحميل Alpine.js بعد تعريف جميع الدوال -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</body>
</html>
