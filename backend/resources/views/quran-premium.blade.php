<!DOCTYPE html>
<html lang="ar" dir="rtl" x-data="quranApp()" :class="{ 'dark': darkMode }">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>القرآن الكريم | أنا المسلم</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])

    <!-- خطوط جوجل: أميري للقرآن، وتجوال للواجهة العصرية -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Tajawal:wght@400;500;700;800&family=IBM+Plex+Sans+Arabic:wght@300;400;500;600&display=swap" rel="stylesheet">

    <!-- مكتبة الأيقونات Iconify (مجموعة Solar الفاخرة) -->
    <script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>

    <style>
    :root {
        --bg: #f8fafc;
        --surface: #ffffff;
        --surface-2: #fdfbf7;
        --border: #e2e8f0;
        --border-strong: #cbd5e1;
        --text: #0f172a;
        --text-muted: #475569;
        --text-soft: #64748b;
        --primary: #11d4b4;
        --primary-soft: rgba(17, 212, 180, 0.16);
        --gold: #d4af37;
        --danger: #dc2626;
        --shadow: 0 18px 38px -18px rgba(15, 23, 42, 0.22);
    }

    .dark {
        --bg: #020617;
        --surface: #0f172a;
        --surface-2: #1e293b;
        --border: #334155;
        --border-strong: #475569;
        --text: #e2e8f0;
        --text-muted: #cbd5e1;
        --text-soft: #94a3b8;
        --primary: #2dd4bf;
        --primary-soft: rgba(45, 212, 191, 0.22);
        --gold: #fbbf24;
        --danger: #f87171;
        --shadow: 0 24px 48px -28px rgba(2, 6, 23, 0.9);
    }

    /* Navbar Glass Effects */
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
        -webkit-backdrop-filter: blur(40px);
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

    /* Focus Mode Scrollbar */
    .focus-scroll-area::-webkit-scrollbar { width: 5px; }
    .focus-scroll-area::-webkit-scrollbar-track { background: transparent; }
    .focus-scroll-area::-webkit-scrollbar-thumb { background: rgba(180,140,60,.25); border-radius: 10px; }
    .focus-scroll-area::-webkit-scrollbar-thumb:hover { background: rgba(180,140,60,.45); }

    /* Ayah hover in focus mode */
    .ayah-focus-segment {
        transition: background 0.2s;
        padding: 2px 3px;
        border-radius: 4px;
    }
    .ayah-focus-segment:hover {
        background: rgba(251,191,36,.12);
    }
    .ayah-number-container {
        transition: transform 0.2s;
    }
    .ayah-focus-segment:hover .ayah-number-container {
        transform: scale(1.12);
    }

    .mushaf-frame {
        border-color: color-mix(in srgb, var(--gold) 24%, transparent);
    }

    .ayah-selected {
        background: var(--primary-soft);
        border-bottom: 2px solid var(--primary);
        border-radius: 0.5rem 0.5rem 0 0;
        box-shadow: 0 10px 24px -18px rgba(15, 23, 42, 0.65);
    }

    .dark .ayah-selected {
        box-shadow: 0 14px 26px -18px rgba(2, 6, 23, 0.9);
    }

    /* Ayah marker circle in main view */
    .ayah-marker {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: var(--surface);
        color: var(--text-soft);
        font-size: 0.66rem;
        font-weight: 800;
        font-family: 'Readex Pro', sans-serif;
        vertical-align: middle;
        margin: 0 8px;
        flex-shrink: 0;
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.14), 0 2px 10px rgba(2, 6, 23, 0.16);
        border: 1.5px solid var(--border-strong);
        transition: transform 0.2s, background 0.2s, color 0.2s, box-shadow 0.2s, border-color 0.2s;
        letter-spacing: 0;
    }
    .verse-hover:hover .ayah-marker,
    .verse-hover:focus-visible .ayah-marker {
        background: var(--primary);
        color: #fff;
        transform: scale(1.08);
        box-shadow: 0 6px 14px -6px rgba(17, 212, 180, 0.55);
        border-color: var(--primary);
    }
    .ayah-marker--active {
        background: var(--primary) !important;
        color: #fff !important;
        box-shadow: 0 8px 16px -7px rgba(17, 212, 180, 0.6) !important;
        border-color: var(--primary) !important;
    }
    </style>
</head>
<body class="bg-[var(--bg)] text-[var(--text)] antialiased selection:bg-[var(--primary-soft)] selection:text-[var(--text)] flex flex-col min-h-screen transition-colors duration-300">

    <!-- خلفية الموقع مع تأثير ضبابي خفيف -->
    <div class="fixed inset-0 z-[-1] bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCI+PGNpcmNsZSBjeD0iMiIgY3k9IjIiIHI9IjIiIGZpbGw9InJnYmEoMjEsIDEyOCwgNjEsIDAuMDUpIi8+PC9zdmc+')] pointer-events-none opacity-60"></div>
    <div class="fixed top-0 left-0 w-full h-96 bg-gradient-to-b from-[color-mix(in_srgb,var(--primary)_10%,transparent)] to-transparent z-[-1] pointer-events-none"></div>

    <!-- Navbar -->
    <div x-show="!focusMode" style="font-family: 'IBM Plex Sans Arabic', ui-sans-serif, system-ui, sans-serif;">
        @include('partials.web-navbar')
    </div>

    <main x-show="!focusMode" class="flex-grow mx-auto w-full max-w-[1400px] px-4 sm:px-6 pt-24 sm:pt-28 pb-32 lg:pb-20">

        <!-- الترويسة و شريط الأدوات العائم -->
        <div class="flex flex-col xl:flex-row items-center justify-between gap-6 mb-10">

            <div class="text-right w-full xl:w-auto">
                <h1 class="text-3xl md:text-4xl font-bold text-[var(--text)] flex items-center gap-3">
                    القرآن الكريم
                    <iconify-icon icon="solar:star-fall-bold-duotone" class="text-[var(--gold)] text-2xl"></iconify-icon>
                </h1>
                <p class="mt-2 text-[var(--text-muted)] font-medium">﴿ كِتَابٌ أَنزَلْنَاهُ إِلَيْكَ مُبَارَكٌ لِّيَدَّبَّرُوا آيَاتِهِ ﴾</p>
            </div>

            <!-- شريط أدوات البحث والإعدادات -->
            <div class="flex w-full xl:w-auto items-center p-1.5 bg-[var(--surface)] rounded-2xl border border-[var(--border)] shadow-[var(--shadow)]">
                <div class="relative w-full md:w-64">
                    <iconify-icon icon="solar:magnifer-linear" class="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--text-soft)] text-lg"></iconify-icon>
                    <input type="text"
                           x-model="searchQuery"
                           @input="searchQuran()"
                           placeholder="ابحث في القرآن..."
                           class="w-full bg-[var(--surface-2)] hover:bg-[var(--surface)] text-sm rounded-xl py-2.5 pr-11 pl-4 border border-[var(--border)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)] transition-colors duration-200 text-[var(--text)]">
                </div>
                <div class="h-6 w-px bg-[var(--border)] mx-2 hidden md:block"></div>
                <div class="flex items-center gap-1 overflow-x-auto hide-scrollbar">
                    <button @click="showReciterModal = true"
                            class="flex items-center gap-2 whitespace-nowrap px-4 py-2.5 rounded-xl hover:bg-[var(--primary-soft)] active:scale-[0.98] text-sm font-medium text-[var(--text-muted)] transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)]">
                        <iconify-icon icon="solar:user-circle-bold-duotone" class="text-[var(--primary)] text-lg"></iconify-icon>
                        <span x-text="selectedReciterName"></span>
                    </button>
                    <button @click="showBookmarks = !showBookmarks"
                            class="flex items-center gap-2 whitespace-nowrap px-4 py-2.5 rounded-xl hover:bg-[var(--primary-soft)] active:scale-[0.98] text-sm font-medium text-[var(--text-muted)] transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)]">
                        <iconify-icon icon="solar:bookmark-bold-duotone" class="text-[var(--primary)] text-lg"></iconify-icon>
                        علاماتي
                    </button>
                    <button @click="toggleFocusMode()"
                            class="flex items-center gap-2 whitespace-nowrap px-4 py-2.5 rounded-xl hover:bg-[var(--primary-soft)] active:scale-[0.98] text-sm font-medium text-[var(--text-muted)] transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)]"
                            title="وضع القراءة المركزة">
                        <iconify-icon icon="solar:eye-bold-duotone" class="text-[var(--primary)] text-lg"></iconify-icon>
                        <span class="hidden md:inline">وضع التركيز</span>
                    </button>
                    <!-- Font Picker Button -->
                    <div class="relative">
                        <button @click="showFontMenu = !showFontMenu"
                                @click.away="showFontMenu = false"
                                class="flex items-center gap-1.5 h-9 px-3 rounded-xl hover:bg-[var(--primary-soft)] active:scale-[0.98] text-sm font-medium text-[var(--text-muted)] transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)]">
                            <template x-if="fontLoading">
                                <span class="w-3.5 h-3.5 border-2 border-[var(--primary)] border-t-transparent rounded-full animate-spin block"></span>
                            </template>
                            <template x-if="!fontLoading">
                                <iconify-icon icon="solar:text-field-focus-bold" class="text-[var(--primary)] text-lg"></iconify-icon>
                            </template>
                            <span class="hidden md:inline max-w-[90px] truncate" x-text="selectedFont.name"></span>
                            <iconify-icon icon="solar:alt-arrow-down-bold" class="text-[var(--text-soft)] text-xs"></iconify-icon>
                        </button>
                        <!-- Font Dropdown -->
                        <div x-show="showFontMenu"
                             x-transition:enter="transition ease-out duration-150"
                             x-transition:enter-start="opacity-0 translate-y-1"
                             x-transition:enter-end="opacity-100 translate-y-0"
                             x-transition:leave="transition ease-in duration-100"
                             x-transition:leave-start="opacity-100 translate-y-0"
                             x-transition:leave-end="opacity-0 translate-y-1"
                             class="absolute left-0 top-11 z-50 w-56 bg-[var(--surface)] border border-[var(--border)] rounded-2xl shadow-xl p-1.5 max-h-72 overflow-y-auto"
                             style="min-width:14rem;">
                            <p class="text-[10px] font-bold text-[var(--text-soft)] px-2 py-1 uppercase tracking-wider">اختر خط القرآن</p>
                            <template x-for="font in availableFonts" :key="font.key">
                                <button @click="applyFont(font); showFontMenu = false"
                                        class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-right transition-all duration-150 hover:bg-[var(--surface-2)] active:scale-[0.98]"
                                        :class="selectedFont.key === font.key ? 'bg-[color-mix(in_srgb,var(--primary)_12%,transparent)] text-[var(--primary)]' : 'text-[var(--text)]'">
                                    <span class="flex-1 text-sm font-bold text-right" x-text="font.name"></span>
                                    <iconify-icon x-show="selectedFont.key === font.key" icon="solar:check-circle-bold" class="text-[var(--primary)] shrink-0"></iconify-icon>
                                </button>
                            </template>
                        </div>
                    </div>
                    <div class="flex items-center gap-1 bg-[var(--surface-2)] rounded-xl p-1 border border-[var(--border)]">
                        <button @click="decreaseFontSize()"
                                class="w-8 h-8 rounded-lg hover:bg-[var(--surface)] active:scale-95 flex items-center justify-center transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
                                title="تصغير الخط">
                            <iconify-icon icon="solar:minus-circle-bold" class="text-lg text-[var(--text-muted)]"></iconify-icon>
                        </button>
                        <span class="text-xs font-bold px-2 text-[var(--text-muted)]" x-text="fontSize + 'px'"></span>
                        <button @click="increaseFontSize()"
                                class="w-8 h-8 rounded-lg hover:bg-[var(--surface)] active:scale-95 flex items-center justify-center transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
                                title="تكبير الخط">
                            <iconify-icon icon="solar:add-circle-bold" class="text-lg text-[var(--text-muted)]"></iconify-icon>
                        </button>
                    </div>
                </div>
            </div>

        </div>

        <!-- Bookmarks Panel -->
        <div x-show="showBookmarks" x-cloak class="mb-8 bg-[var(--surface)] rounded-2xl shadow-[var(--shadow)] border border-[var(--border)] p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-bold text-[var(--text)] flex items-center gap-2">
                    <iconify-icon icon="solar:bookmark-bold-duotone" class="text-[var(--primary)]"></iconify-icon>
                    العلامات المرجعية
                </h3>
                <button @click="showBookmarks = false" class="text-[var(--text-soft)] hover:text-[var(--text)] transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] rounded-lg">
                    <iconify-icon icon="solar:close-circle-bold" class="text-2xl"></iconify-icon>
                </button>
            </div>
            <div x-show="bookmarks.length === 0" class="text-center py-8 text-[var(--text-muted)]">
                <iconify-icon icon="solar:bookmark-bold-duotone" class="text-6xl mb-4 opacity-20"></iconify-icon>
                <p>لا توجد علامات مرجعية بعد</p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <template x-for="bookmark in bookmarks" :key="bookmark.id">
                    <div class="bg-[var(--surface-2)] rounded-xl p-4 border border-[var(--border)] hover:border-[var(--primary)] transition-all duration-200 cursor-pointer group" @click="goToBookmark(bookmark)">
                        <div class="flex items-start justify-between mb-2">
                            <div class="flex-1">
                                <h4 class="font-bold text-[var(--text)]" x-text="bookmark.surahName"></h4>
                                <p class="text-sm text-[var(--text-muted)]" x-text="'آية ' + bookmark.ayahNumber"></p>
                            </div>
                            <button @click.stop="removeBookmark(bookmark.id)" class="text-[var(--text-soft)] hover:text-[var(--danger)] transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--danger)] rounded-lg">
                                <iconify-icon icon="solar:trash-bin-minimalistic-bold" class="text-lg"></iconify-icon>
                            </button>
                        </div>
                        <p class="text-sm text-[var(--text-muted)] font-quran line-clamp-2" x-text="bookmark.ayahText"></p>
                        <p class="text-xs text-[var(--text-soft)] mt-2" x-text="new Date(bookmark.timestamp).toLocaleDateString('ar-SA')"></p>
                    </div>
                </template>
            </div>
        </div>

        <!-- Search Results -->
        <div x-show="searchResults.length > 0" x-cloak class="mb-8 bg-[var(--surface)] rounded-2xl shadow-[var(--shadow)] border border-[var(--border)] p-6">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-lg font-bold text-[var(--text)] flex items-center gap-2">
                    <iconify-icon icon="solar:magnifer-bold-duotone" class="text-[var(--primary)]"></iconify-icon>
                    نتائج البحث (<span x-text="searchResults.length"></span>)
                </h3>
                <button @click="searchResults = []; searchQuery = ''" class="text-[var(--text-soft)] hover:text-[var(--text)] transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] rounded-lg">
                    <iconify-icon icon="solar:close-circle-bold" class="text-2xl"></iconify-icon>
                </button>
            </div>
            <div class="space-y-3 max-h-96 overflow-y-auto">
                <template x-for="result in searchResults" :key="result.surahNum + '-' + result.ayahNum">
                    <div class="bg-[var(--surface-2)] rounded-xl p-4 border border-[var(--border)] hover:border-[var(--primary)] transition-all duration-200 cursor-pointer" @click="goToSearchResult(result)">
                        <div class="flex items-center gap-2 mb-2">
                            <span class="text-sm font-bold text-[var(--primary)]" x-text="result.surahName"></span>
                            <span class="text-sm text-[var(--text-muted)]" x-text="'آية ' + result.ayahNum"></span>
                        </div>
                        <p class="text-[var(--text-muted)] font-quran leading-loose" x-html="highlightSearchTerm(result.text, searchQuery)"></p>
                    </div>
                </template>
            </div>
        </div>

        <!-- الشبكة الرئيسية: المصحف (اليمين) والمشغل (اليسار) -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">

            <!-- منطقة المصحف (قراءة القرآن) -->
            <div class="lg:col-span-8 xl:col-span-9 order-2 lg:order-1">

                <!-- Surahs Grid View -->
                <div x-show="!selectedSurah" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 mb-8">
                    <template x-for="surah in surahs" :key="surah.number">
                        <button @click="selectSurah(surah.number)"
                                class="bg-[var(--surface)] p-6 rounded-2xl border border-[var(--border)] text-right group shadow-[var(--shadow)] hover:border-[var(--primary)] hover:shadow-lg active:scale-[0.99] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)] transition-all duration-200">
                            <div class="flex items-center justify-between mb-3">
                                <span class="w-12 h-12 rounded-full bg-[var(--primary-soft)] border border-[var(--border)] flex items-center justify-center text-[var(--primary)] font-bold text-lg" x-text="surah.number"></span>
                                <span class="text-xs font-medium text-[var(--text-soft)]" x-text="surah.englishName"></span>
                            </div>
                            <h3 class="text-2xl font-bold text-[var(--text)] mb-2 font-quran" x-text="surah.name"></h3>
                            <p class="text-sm text-[var(--text-muted)]" x-text="surah.revelationType === 'Meccan' ? 'مكية' : 'مدنية'"></p>
                            <p class="text-sm text-[var(--text-soft)]" x-text="surah.numberOfAyahs + ' آية'"></p>
                        </button>
                    </template>
                </div>

                <!-- ورقة المصحف -->
                <div x-show="selectedSurah"
                     x-cloak
                     class="rounded-[2rem] shadow-[var(--shadow)] border border-[var(--border)] bg-[var(--surface-2)] relative overflow-hidden mushaf-page transition-colors duration-300">

                    <!-- إطار المصحف الزخرفي -->
                    <div class="absolute inset-2 border rounded-[1.5rem] pointer-events-none mushaf-frame"></div>

                    <div class="p-6 sm:p-10 md:p-14">

                        <!-- معلومات السورة (هيدر الآيات) -->
                        <div class="flex flex-col items-center justify-center mb-12">
                            <!-- Back Button -->
                            <button @click="selectedSurah = null; currentAyahs = []; stopAudio()"
                                    class="mb-6 flex items-center gap-2 text-[var(--primary)] hover:gap-3 font-bold self-start transition-all duration-200 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface-2)]">
                                <iconify-icon icon="solar:alt-arrow-right-linear" class="text-2xl"></iconify-icon>
                                <span>العودة للسور</span>
                            </button>

                            <!-- التاج / البادج -->
                            <div x-show="currentSurahData"
                                 class="flex items-center gap-4 px-6 py-2 rounded-full border border-[var(--border)] bg-[var(--surface)] shadow-[var(--shadow)] mb-8 transition-colors duration-300">
                                <span class="text-sm font-bold text-[var(--primary)] flex items-center gap-1.5">
                                    <iconify-icon icon="solar:moon-stars-bold-duotone" class="text-[var(--gold)] text-lg"></iconify-icon>
                                    <span x-text="currentSurahData?.revelationType === 'Meccan' ? 'مكية' : 'مدنية'"></span>
                                </span>
                                <span class="w-1.5 h-1.5 rounded-full bg-[var(--border-strong)]"></span>
                                <span class="text-sm font-medium text-[var(--text-muted)]" x-text="'آياتها ' + convertToArabicNumbers(currentSurahData?.numberOfAyahs)"></span>
                            </div>

                            <!-- اسم السورة -->
                            <h2 class="font-quran text-4xl md:text-5xl text-[var(--primary)] mb-8" x-text="currentSurahData?.name"></h2>

                            <!-- البسملة -->
                            <div x-show="selectedSurah !== 1 && selectedSurah !== 9"
                                 class="font-quran text-3xl md:text-4xl tracking-wide text-[var(--text)]">
                                بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
                            </div>

                            <!-- فاصل أنيق -->
                            <div class="mt-8 flex items-center justify-center w-full max-w-xs opacity-80">
                                <div class="h-[1px] w-full bg-gradient-to-r from-transparent via-[var(--gold)] to-transparent"></div>
                                <iconify-icon icon="solar:star-fall-bold" class="text-[var(--gold)] text-lg mx-3"></iconify-icon>
                                <div class="h-[1px] w-full bg-gradient-to-r from-transparent via-[var(--gold)] to-transparent"></div>
                            </div>
                        </div>

                        <!-- الآيات -->
                        <div class="font-quran quran-text text-[var(--text)] text-center"
                             dir="rtl"
                             :style="'font-family:\'' + selectedFont.cssFamily + '\',\'Amiri\',serif;font-size:' + fontSize + 'px;line-height:2.35;'">
                            <template x-for="(ayah, index) in currentAyahs" :key="ayah.number">
                                <button type="button"
                                        class="relative group inline verse-hover px-1 py-0.5 rounded-lg transition-all duration-200 hover:bg-[var(--primary-soft)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface-2)]"
                                        :class="{ 'ayah-selected': selectedAyah === ayah.numberInSurah }"
                                        @click="selectAyah(ayah)">
                                    <span x-text="ayah.text"></span>
                                    <span class="ayah-marker"
                                          :class="{ 'ayah-marker--active': selectedAyah === ayah.numberInSurah }"
                                          x-text="ayah.numberInSurah"></span>

                                    <!-- القائمة العائمة (Floating Action Bar) -->
                                    <div x-show="selectedAyah === ayah.numberInSurah"
                                         x-cloak
                                         class="absolute -top-14 left-1/2 -translate-x-1/2 flex items-center gap-1 bg-[var(--surface)] rounded-xl p-1.5 shadow-[var(--shadow)] border border-[var(--border-strong)] animate-fade-in-up z-50">
                                        <button @click.stop="showTafsir(ayah)"
                                                class="flex items-center justify-center w-9 h-9 rounded-lg text-[var(--primary)] hover:bg-[var(--primary-soft)] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] transition-all duration-200"
                                                title="التفسير">
                                            <iconify-icon icon="solar:book-bookmark-bold" class="text-lg"></iconify-icon>
                                        </button>
                                        <button @click.stop="toggleBookmark(ayah)"
                                                class="flex items-center justify-center w-9 h-9 rounded-lg text-[var(--text-soft)] hover:bg-[var(--primary-soft)] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] transition-all duration-200"
                                                :class="{ 'text-[var(--gold)]': isBookmarked(ayah) }"
                                                title="علامة مرجعية">
                                            <iconify-icon :icon="isBookmarked(ayah) ? 'solar:bookmark-bold' : 'solar:bookmark-linear'" class="text-lg"></iconify-icon>
                                        </button>
                                        <button @click.stop="copyAyah(ayah)"
                                                class="flex items-center justify-center w-9 h-9 rounded-lg text-[var(--text-soft)] hover:bg-[var(--primary-soft)] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] transition-all duration-200"
                                                title="نسخ">
                                            <iconify-icon icon="solar:copy-bold" class="text-lg"></iconify-icon>
                                        </button>
                                        <!-- السهم السفلي للقائمة -->
                                        <div class="absolute -bottom-1.5 left-1/2 -translate-x-1/2 w-3 h-3 bg-[var(--surface)] border-b border-r border-[var(--border-strong)] rotate-45"></div>
                                    </div>
                                </button>
                            </template>
                        </div>
                    </div>
                </div>

                <!-- أزرار التنقل السفلية بين السور -->
                <div x-show="selectedSurah" x-cloak class="mt-8 flex items-center justify-between gap-4">
                    <button @click="navigateSurah('prev')"
                            :disabled="selectedSurah === 1"
                            class="group flex items-center gap-4 bg-[var(--surface)] p-4 rounded-2xl shadow-[var(--shadow)] border border-[var(--border)] hover:border-[var(--primary)] hover:shadow-lg active:scale-[0.99] transition-all duration-200 w-full sm:w-auto disabled:opacity-50 disabled:cursor-not-allowed focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)]">
                        <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[var(--surface-2)] text-[var(--text-soft)] border border-[var(--border)] group-hover:bg-[var(--primary-soft)] group-hover:text-[var(--primary)] transition-colors duration-200">
                            <iconify-icon icon="solar:round-alt-arrow-right-bold-duotone" class="text-3xl"></iconify-icon>
                        </div>
                        <div class="text-right">
                            <span class="block text-xs font-bold text-[var(--text-soft)]">السورة السابقة</span>
                            <span class="block text-base font-bold text-[var(--text)]" x-text="getPrevSurahName()"></span>
                        </div>
                    </button>

                    <button @click="navigateSurah('next')"
                            :disabled="selectedSurah === 114"
                            class="group flex items-center justify-end gap-4 bg-[var(--surface)] p-4 rounded-2xl shadow-[var(--shadow)] border border-[var(--border)] hover:border-[var(--primary)] hover:shadow-lg active:scale-[0.99] transition-all duration-200 w-full sm:w-auto text-left disabled:opacity-50 disabled:cursor-not-allowed focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)]">
                        <div class="text-left hidden sm:block">
                            <span class="block text-xs font-bold text-[var(--text-soft)]">السورة التالية</span>
                            <span class="block text-base font-bold text-[var(--text)]" x-text="getNextSurahName()"></span>
                        </div>
                        <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[var(--surface-2)] text-[var(--text-soft)] border border-[var(--border)] group-hover:bg-[var(--primary-soft)] group-hover:text-[var(--primary)] transition-colors duration-200">
                            <iconify-icon icon="solar:round-alt-arrow-left-bold-duotone" class="text-3xl"></iconify-icon>
                        </div>
                    </button>
                </div>
            </div>

            <!-- مشغل الصوتيات -->
            <div class="lg:col-span-4 xl:col-span-3 order-1 lg:order-2">
                <!-- Desktop Player -->
                <div class="hidden lg:block sticky top-28 bg-[color-mix(in_srgb,var(--surface)_88%,transparent)] backdrop-blur-xl rounded-[2rem] shadow-[var(--shadow)] border border-[var(--border)] p-6 sm:p-8">

                    <!-- صورة / أيقونة القارئ -->
                    <div class="flex justify-center mb-6">
                        <div class="relative w-28 h-28 rounded-full p-1 bg-gradient-to-tr from-[var(--primary)] to-[var(--gold)] shadow-lg shadow-[color-mix(in_srgb,var(--primary)_35%,transparent)]">
                            <div class="w-full h-full bg-[var(--surface)] rounded-full flex items-center justify-center border-4 border-[var(--border)] overflow-hidden relative">
                                <!-- اسطوانة تدور -->
                                <iconify-icon icon="solar:vinyl-bold" class="text-[var(--text)] text-5xl opacity-90" :class="isPlaying ? 'animate-spin-playing' : 'animate-spin-slow'"></iconify-icon>
                                <!-- ثقب الاسطوانة -->
                                <div class="absolute w-3 h-3 bg-[var(--surface-2)] rounded-full border border-[var(--border)]"></div>
                            </div>
                        </div>
                    </div>

                    <!-- معلومات المقطع -->
                    <div class="text-center mb-8">
                        <h3 class="text-2xl font-bold text-[var(--text)] font-quran mb-1" x-text="currentSurahData?.name || 'القرآن الكريم'"></h3>
                        <p class="text-sm font-medium text-[var(--text-muted)]" x-text="selectedReciterName"></p>
                    </div>

                    <!-- شريط التقدم -->
                    <div class="mb-8">
                        <div class="flex justify-between text-xs font-bold text-[var(--text-soft)] mb-3 px-1">
                            <span x-text="currentTime"></span>
                            <span x-text="duration"></span>
                        </div>
                        <div @click="seekAudio($event)" class="h-1.5 bg-[var(--surface-2)] rounded-full overflow-hidden cursor-pointer relative group border border-[var(--border)]">
                            <div class="absolute top-0 left-0 h-full bg-[var(--primary)] rounded-full relative" :style="'width: ' + progress + '%'">
                                <div class="absolute left-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-[var(--surface)] border border-[var(--border)] rounded-full shadow-sm scale-0 group-hover:scale-100 transition-transform duration-200 origin-center"></div>
                            </div>
                        </div>
                    </div>

                    <!-- أزرار التحكم الرئيسية -->
                    <div class="flex items-center justify-center gap-6 mb-8">
                        <button @click="skipBackward()" class="text-[var(--text-soft)] hover:text-[var(--primary)] transition-colors duration-200 p-2 rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]" title="الآية السابقة">
                            <iconify-icon icon="solar:skip-next-bold" class="text-2xl"></iconify-icon>
                        </button>

                        <!-- زر التشغيل الفاخر -->
                        <button @click="toggleAudio()" class="w-16 h-16 rounded-full bg-[var(--primary)] text-white flex items-center justify-center shadow-lg shadow-[color-mix(in_srgb,var(--primary)_35%,transparent)] hover:brightness-110 hover:scale-105 active:scale-95 transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)]">
                            <iconify-icon :icon="isPlaying ? 'solar:pause-bold' : 'solar:play-bold'" class="text-3xl"></iconify-icon>
                        </button>

                        <button @click="skipForward()" class="text-[var(--text-soft)] hover:text-[var(--primary)] transition-colors duration-200 p-2 rounded-xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]" title="الآية التالية">
                            <iconify-icon icon="solar:skip-previous-bold" class="text-2xl"></iconify-icon>
                        </button>
                    </div>

                    <!-- أدوات إضافية -->
                    <div class="bg-[var(--surface-2)] rounded-2xl p-4 border border-[var(--border)] space-y-3">
                        <!-- Volume Control (LTR) -->
                        <div class="flex items-center gap-3" dir="ltr">
                            <iconify-icon icon="solar:volume-loud-bold" class="text-[var(--text-soft)]"></iconify-icon>
                            <input type="range" min="0" max="100" x-model="volume" @input="changeVolume()" class="flex-grow h-1 bg-[var(--border)] rounded-full appearance-none cursor-pointer" style="accent-color: var(--primary);">
                            <span class="text-xs font-bold text-[var(--text-muted)] min-w-[2rem] text-left" x-text="volume + '%'"></span>
                        </div>

                        <!-- Repeat & Download Buttons -->
                        <div class="flex items-center gap-2">
                            <button @click="toggleRepeat()"
                                    class="flex-1 flex items-center justify-center gap-2 px-3 py-2.5 rounded-xl text-sm font-bold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
                                    :class="repeatMode ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'text-[var(--text-muted)] hover:bg-[var(--surface)] border border-transparent'">
                                <iconify-icon icon="solar:repeat-bold" class="text-lg"></iconify-icon>
                                <span>تكرار</span>
                            </button>

                            <button @click="downloadSurah()" class="flex-1 flex items-center justify-center gap-2 px-3 py-2.5 rounded-xl text-sm font-bold bg-[var(--primary)] text-white transition-all duration-200 hover:brightness-110 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                                <iconify-icon icon="solar:download-minimalistic-bold" class="text-lg"></iconify-icon>
                                <span>تحميل</span>
                            </button>
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </main>

    <!-- Mobile Player (Fixed Bottom) -->
    <div x-show="selectedSurah && !focusMode" x-cloak class="lg:hidden fixed bottom-0 left-0 right-0 z-40 bg-[color-mix(in_srgb,var(--surface)_94%,transparent)] backdrop-blur-xl border-t border-[var(--border-strong)] shadow-[var(--shadow)]" style="padding-bottom: env(safe-area-inset-bottom);">
        <div class="px-4 py-3">
            <!-- Progress Bar -->
            <div @click="seekAudio($event)" class="h-1 bg-[var(--border)] rounded-full overflow-hidden cursor-pointer mb-3 relative group">
                <div class="absolute top-0 left-0 h-full bg-[var(--primary)] rounded-full" :style="'width: ' + progress + '%'"></div>
            </div>

            <!-- Player Controls -->
            <div class="flex items-center justify-between gap-3">
                <!-- Surah Info -->
                <div class="flex items-center gap-3 flex-1 min-w-0">
                    <div class="relative w-12 h-12 shrink-0 rounded-full p-0.5 bg-gradient-to-tr from-[var(--primary)] to-[var(--gold)]">
                        <div class="w-full h-full bg-[var(--surface)] rounded-full flex items-center justify-center overflow-hidden border border-[var(--border)]">
                            <iconify-icon icon="solar:vinyl-bold" class="text-[var(--text)] text-xl" :class="isPlaying ? 'animate-spin-playing' : ''"></iconify-icon>
                        </div>
                    </div>
                    <div class="flex-1 min-w-0">
                        <h4 class="text-sm font-bold text-[var(--text)] truncate" x-text="currentSurahData?.name || 'القرآن الكريم'"></h4>
                        <p class="text-xs text-[var(--text-muted)] truncate" x-text="selectedReciterName"></p>
                    </div>
                </div>

                <!-- Control Buttons -->
                <div class="flex items-center gap-2 shrink-0">
                    <button @click="skipBackward()" class="w-10 h-10 rounded-full bg-[var(--surface-2)] text-[var(--text-muted)] hover:text-[var(--primary)] hover:bg-[var(--primary-soft)] flex items-center justify-center transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        <iconify-icon icon="solar:skip-next-bold" class="text-lg"></iconify-icon>
                    </button>

                    <button @click="toggleAudio()" class="w-12 h-12 rounded-full bg-[var(--primary)] text-white flex items-center justify-center shadow-lg shadow-[color-mix(in_srgb,var(--primary)_35%,transparent)] hover:scale-105 active:scale-95 transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        <iconify-icon :icon="isPlaying ? 'solar:pause-bold' : 'solar:play-bold'" class="text-xl"></iconify-icon>
                    </button>

                    <button @click="skipForward()" class="w-10 h-10 rounded-full bg-[var(--surface-2)] text-[var(--text-muted)] hover:text-[var(--primary)] hover:bg-[var(--primary-soft)] flex items-center justify-center transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        <iconify-icon icon="solar:skip-previous-bold" class="text-lg"></iconify-icon>
                    </button>
                </div>
            </div>

            <!-- Time Display -->
            <div class="flex justify-between text-xs text-[var(--text-soft)] mt-2">
                <span x-text="currentTime"></span>
                <span x-text="duration"></span>
            </div>
        </div>
    </div>

    <!-- Tafsir Modal -->
    <div x-show="showTafsirModal" x-cloak class="fixed inset-0 z-[100] flex items-center justify-center p-4 modal-backdrop" @click.self="showTafsirModal = false">
        <div class="bg-[var(--surface)] rounded-2xl shadow-[var(--shadow)] max-w-3xl w-full max-h-[80vh] overflow-hidden border border-[var(--border)]" @click.stop>
            <!-- Modal Header -->
            <div class="flex items-center justify-between p-6 border-b border-[var(--border)]">
                <h3 class="text-2xl font-bold text-[var(--text)] flex items-center gap-3">
                    <iconify-icon icon="solar:book-bookmark-bold-duotone" class="text-[var(--primary)]"></iconify-icon>
                    التفسير
                </h3>
                <button @click="showTafsirModal = false" class="text-[var(--text-soft)] hover:text-[var(--text)] transition-colors duration-200 rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <iconify-icon icon="solar:close-circle-bold" class="text-3xl"></iconify-icon>
                </button>
            </div>

            <!-- Tafsir Tabs -->
            <div class="flex items-center gap-2 px-6 py-4 border-b border-[var(--border)] overflow-x-auto hide-scrollbar">
                <button @click="changeTafsir(16)" :class="selectedTafsir === 16 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    الميسر
                </button>
                <button @click="changeTafsir(14)" :class="selectedTafsir === 14 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    ابن كثير
                </button>
                <button @click="changeTafsir(91)" :class="selectedTafsir === 91 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    السعدي
                </button>
                <button @click="changeTafsir(90)" :class="selectedTafsir === 90 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    القرطبي
                </button>
                <button @click="changeTafsir(94)" :class="selectedTafsir === 94 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    البغوي
                </button>
                <button @click="changeTafsir(93)" :class="selectedTafsir === 93 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    الوسيط
                </button>
                <button @click="changeTafsir(15)" :class="selectedTafsir === 15 ? 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[var(--primary)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)] border border-[var(--border)] hover:bg-[var(--surface)]'" class="px-4 py-2 rounded-lg text-sm font-bold whitespace-nowrap transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    الطبري
                </button>
            </div>

            <!-- Modal Body -->
            <div class="p-6 overflow-y-auto max-h-[50vh]">
                <!-- الآية -->
                <div class="bg-[var(--surface-2)] rounded-xl p-6 mb-6 border border-[var(--border)]">
                    <div class="flex items-center gap-2 mb-3">
                        <span class="text-sm font-bold text-[var(--primary)]" x-text="currentTafsirAyah?.surahName"></span>
                        <span class="text-sm text-[var(--text-muted)]" x-text="'آية ' + currentTafsirAyah?.numberInSurah"></span>
                    </div>
                    <p class="font-quran text-2xl text-[var(--text)] leading-loose text-center" x-text="currentTafsirAyah?.text"></p>
                </div>

                <!-- التفسير -->
                <div x-show="loadingTafsir" class="text-center py-8">
                    <iconify-icon icon="solar:spinner-bold-duotone" class="text-4xl text-[var(--primary)] animate-spin"></iconify-icon>
                    <p class="text-[var(--text-muted)] mt-4">جارٍ تحميل التفسير...</p>
                </div>

                <div x-show="!loadingTafsir" class="prose max-w-none">
                    <p class="text-[var(--text-muted)] leading-loose text-lg" x-text="currentTafsirText"></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Alert Dialog -->
    <div x-show="showDialog" x-cloak class="fixed inset-0 z-[110] flex items-center justify-center p-4 modal-backdrop" @click.self="showDialog = false">
        <div class="bg-[var(--surface)] rounded-2xl shadow-[var(--shadow)] max-w-md w-full p-6 animate-fade-in-up border border-[var(--border)]" @click.stop>
            <div class="flex items-start gap-4 mb-4">
                <div class="w-12 h-12 rounded-full flex items-center justify-center shrink-0"
                     :class="dialogType === 'success' ? 'bg-[var(--primary-soft)] text-[var(--primary)]' : dialogType === 'error' ? 'bg-[color-mix(in_srgb,var(--danger)_20%,transparent)] text-[var(--danger)]' : 'bg-[var(--surface-2)] text-[var(--text-muted)]'">
                    <iconify-icon :icon="dialogType === 'success' ? 'solar:check-circle-bold' : dialogType === 'error' ? 'solar:close-circle-bold' : 'solar:info-circle-bold'" class="text-3xl"></iconify-icon>
                </div>
                <div class="flex-1">
                    <h3 class="text-lg font-bold text-[var(--text)] mb-1" x-text="dialogTitle"></h3>
                    <p class="text-[var(--text-muted)]" x-text="dialogMessage"></p>
                </div>
            </div>
            <div class="flex justify-end gap-3">
                <button @click="showDialog = false" class="px-6 py-2.5 rounded-xl font-bold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
                        :class="dialogType === 'success' ? 'bg-[var(--primary)] text-white hover:brightness-110' : 'bg-[var(--surface-2)] border border-[var(--border)] text-[var(--text)] hover:bg-[var(--surface)]'">
                    حسناً
                </button>
            </div>
        </div>
    </div>

    <!-- Reciter Selection Modal -->
    <div x-show="showReciterModal" x-cloak class="fixed inset-0 z-[100] flex items-center justify-center p-4 modal-backdrop" @click.self="showReciterModal = false">
        <div class="bg-[var(--surface)] rounded-2xl shadow-[var(--shadow)] max-w-2xl w-full max-h-[80vh] overflow-hidden border border-[var(--border)]" @click.stop>
            <div class="flex items-center justify-between p-6 border-b border-[var(--border)]">
                <h3 class="text-2xl font-bold text-[var(--text)] flex items-center gap-3">
                    <iconify-icon icon="solar:user-circle-bold-duotone" class="text-[var(--primary)]"></iconify-icon>
                    اختر القارئ
                </h3>
                <button @click="showReciterModal = false" class="text-[var(--text-soft)] hover:text-[var(--text)] transition-colors duration-200 rounded-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <iconify-icon icon="solar:close-circle-bold" class="text-3xl"></iconify-icon>
                </button>
            </div>

            <!-- Search Bar -->
            <div class="p-6 border-b border-[var(--border)] space-y-4">
                <div class="relative">
                    <iconify-icon icon="solar:magnifer-linear" class="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--text-soft)] text-lg"></iconify-icon>
                    <input type="text" x-model="reciterSearchQuery" @input="filterReciters()" placeholder="ابحث عن القارئ..." class="w-full bg-[var(--surface-2)] text-sm rounded-xl py-3 pr-11 pl-4 border border-[var(--border)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--surface)] transition-all duration-200 text-[var(--text)]">
                </div>
                <!-- Nationality Filter -->
                <div x-show="availableNationalities.length > 0" class="flex items-center gap-2 overflow-x-auto hide-scrollbar pb-1">
                    <button @click="selectedNationality = ''; filterReciters()"
                            :class="selectedNationality === '' ? 'bg-[var(--primary)] text-white shadow-md' : 'bg-[var(--surface-2)] text-[var(--text-muted)] hover:bg-[var(--surface)] border border-[var(--border)]'"
                            class="shrink-0 px-4 py-1.5 rounded-xl text-xs font-bold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        الكل
                        <span class="mr-0.5 opacity-75" x-text="'(' + reciters.length + ')'"></span>
                    </button>
                    <template x-for="nat in availableNationalities" :key="nat.code">
                        <button @click="selectedNationality = nat.code; filterReciters()"
                                :class="selectedNationality === nat.code ? 'bg-[var(--primary)] text-white shadow-md' : 'bg-[var(--surface-2)] text-[var(--text-muted)] hover:bg-[var(--surface)] border border-[var(--border)]'"
                                class="shrink-0 px-4 py-1.5 rounded-xl text-xs font-bold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                            <span x-text="nat.label"></span>
                            <span class="mr-0.5 opacity-75" x-text="'(' + nat.count + ')'"></span>
                        </button>
                    </template>
                </div>
            </div>

            <div class="p-6 overflow-y-auto max-h-[50vh]">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <template x-for="reciter in filteredReciters" :key="reciter.id">
                        <div :class="selectedReciter === reciter.id ? 'bg-[var(--primary-soft)] border-[var(--primary)]' : 'bg-[var(--surface-2)] border-[var(--border)]'"
                             class="rounded-xl border-2 transition-all overflow-hidden">
                            <button @click="selectReciter(reciter)"
                                    class="w-full flex items-center gap-4 p-4 hover:bg-[var(--surface)] transition-colors duration-200 text-right focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                                <div class="w-12 h-12 rounded-full flex items-center justify-center shrink-0 border border-[var(--border)]"
                                     :class="selectedReciter === reciter.id ? 'bg-[var(--primary-soft)] text-[var(--primary)]' : 'bg-[var(--surface)] text-[var(--text-soft)]'">
                                    <iconify-icon icon="solar:user-circle-bold" class="text-2xl"></iconify-icon>
                                </div>
                                <div class="flex-1">
                                    <h4 class="font-bold text-[var(--text)]" x-text="reciter.name"></h4>
                                    <div class="flex items-center gap-2">
                                        <p class="text-sm text-[var(--text-muted)]" x-text="reciter.style || 'مرتل'"></p>
                                        <template x-if="reciter.nationality">
                                            <span class="text-[10px] bg-[color-mix(in_srgb,var(--gold)_20%,transparent)] text-[var(--gold)] px-1.5 py-0.5 rounded font-medium" x-text="nationalityLabels[reciter.nationality] || reciter.nationality"></span>
                                        </template>
                                    </div>
                                </div>
                                <iconify-icon x-show="selectedReciter === reciter.id" icon="solar:check-circle-bold" class="text-2xl text-[var(--primary)]"></iconify-icon>
                            </button>
                            <div x-show="selectedReciter === reciter.id" class="border-t border-[var(--border)] p-3 bg-[var(--surface)]">
                                <button @click.stop="setDefaultReciter(reciter)" class="w-full flex items-center justify-center gap-2 px-4 py-2 rounded-lg text-sm font-bold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]"
                                        :class="defaultReciterId === reciter.id ? 'bg-[var(--primary)] text-white' : 'bg-[var(--surface-2)] border border-[var(--border)] text-[var(--text)] hover:bg-[var(--primary)] hover:text-white'">
                                    <iconify-icon :icon="defaultReciterId === reciter.id ? 'solar:star-bold' : 'solar:star-linear'" class="text-lg"></iconify-icon>
                                    <span x-text="defaultReciterId === reciter.id ? 'القارئ الافتراضي' : 'تعيين كافتراضي'"></span>
                                </button>
                            </div>
                        </div>
                    </template>
                </div>
            </div>
        </div>
    </div>

    <!-- Focus Mode Overlay -->
    <div x-show="focusMode"
         x-cloak
         x-transition:enter="transition ease-out duration-500"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-300"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-[200] overflow-hidden flex flex-col bg-[var(--surface-2)]"
         @mousemove="showFocusBar()"
         @touchstart.passive="showFocusBar()">

        <!-- Subtle dot-grid texture -->
        <div class="fixed inset-0 z-[199] pointer-events-none"
             style="background-image:radial-gradient(circle,color-mix(in srgb,var(--gold) 12%,transparent) 1px,transparent 1px);background-size:22px 22px;"></div>

        <!-- Top Bar (auto-hide) -->
        <div x-show="focusBarVisible"
             x-cloak
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0 -translate-y-full"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-200"
             x-transition:leave-start="opacity-100 translate-y-0"
             x-transition:leave-end="opacity-0 -translate-y-full"
             class="fixed top-0 left-0 right-0 z-[302] bg-[color-mix(in_srgb,var(--surface)_92%,transparent)] backdrop-blur-xl border-b border-[var(--border)]">
            <div class="max-w-4xl mx-auto px-4 sm:px-6 h-14 flex items-center justify-between gap-4">

                <!-- Exit -->
                <button @click="toggleFocusMode()"
                        class="flex items-center gap-2 px-3 py-1.5 rounded-xl border border-[var(--border)] bg-[var(--surface)] hover:bg-[var(--surface-2)] transition-all duration-200 text-[var(--text)] text-sm font-bold shadow-sm shrink-0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <iconify-icon icon="solar:arrow-right-bold" class="text-base"></iconify-icon>
                    <span class="hidden sm:inline">رجوع</span>
                    <kbd class="hidden md:inline-block px-1.5 py-0.5 text-xs font-mono bg-[var(--surface-2)] text-[var(--text-muted)] rounded border border-[var(--border)]">ESC</kbd>
                </button>

                <!-- Surah Name -->
                <div class="text-center min-w-0" x-show="selectedSurah">
                    <p class="font-bold text-[var(--text)] text-base truncate" style="font-family:'Amiri',serif;" x-text="currentSurahData?.name || ''"></p>
                    <p class="text-xs text-[var(--text-muted)]" x-text="(currentSurahData?.revelationType === 'Meccan' ? 'مكية' : 'مدنية') + ' · ' + (currentAyahs?.length || 0) + ' آية'"></p>
                </div>

                <!-- Font Controls -->
                <!-- Font Picker in Focus Mode -->
                <div class="relative">
                    <button @click="showFontMenu = !showFontMenu"
                            @click.away="showFontMenu = false"
                            class="flex items-center gap-1 px-2 py-1 rounded-xl border border-[var(--border)] bg-[var(--surface)] shadow-sm shrink-0 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] transition-all duration-200 hover:bg-[var(--surface-2)]">
                        <template x-if="fontLoading">
                            <span class="w-3 h-3 border-2 border-[var(--primary)] border-t-transparent rounded-full animate-spin block"></span>
                        </template>
                        <template x-if="!fontLoading">
                            <iconify-icon icon="solar:text-field-focus-bold" class="text-[var(--primary)] text-sm"></iconify-icon>
                        </template>
                        <iconify-icon icon="solar:alt-arrow-down-bold" class="text-[var(--text-soft)] text-xs"></iconify-icon>
                    </button>
                    <div x-show="showFontMenu"
                         x-transition:enter="transition ease-out duration-150"
                         x-transition:enter-start="opacity-0 translate-y-1"
                         x-transition:enter-end="opacity-100 translate-y-0"
                         x-transition:leave="transition ease-in duration-100"
                         x-transition:leave-start="opacity-100 translate-y-0"
                         x-transition:leave-end="opacity-0 translate-y-1"
                         class="absolute left-0 top-10 z-[400] w-52 bg-[var(--surface)] border border-[var(--border)] rounded-2xl shadow-xl p-1.5 max-h-64 overflow-y-auto"
                         style="min-width:13rem;">
                        <p class="text-[10px] font-bold text-[var(--text-soft)] px-2 py-1 uppercase tracking-wider">اختر خط القرآن</p>
                        <template x-for="font in availableFonts" :key="font.key">
                            <button @click="applyFont(font); showFontMenu = false"
                                    class="w-full flex items-center gap-3 px-3 py-2 rounded-xl text-right transition-all duration-150 hover:bg-[var(--surface-2)] active:scale-[0.98]"
                                    :class="selectedFont.key === font.key ? 'bg-[color-mix(in_srgb,var(--primary)_12%,transparent)] text-[var(--primary)]' : 'text-[var(--text)]'">
                                <span class="flex-1 text-xs font-bold text-right" x-text="font.name"></span>
                                <iconify-icon x-show="selectedFont.key === font.key" icon="solar:check-circle-bold" class="text-[var(--primary)] shrink-0 text-sm"></iconify-icon>
                            </button>
                        </template>
                    </div>
                </div>
                <div class="flex items-center gap-1 px-2 py-1 rounded-xl border border-[var(--border)] bg-[var(--surface)] shadow-sm shrink-0">
                    <button @click="decreaseFontSize()"
                            class="w-7 h-7 rounded-lg hover:bg-[var(--surface-2)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] flex items-center justify-center transition-colors duration-200 text-[var(--text-muted)] font-bold text-base">−</button>
                    <span class="text-xs font-bold text-[var(--text)] w-9 text-center" x-text="fontSize + 'px'"></span>
                    <button @click="increaseFontSize()"
                            class="w-7 h-7 rounded-lg hover:bg-[var(--surface-2)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] flex items-center justify-center transition-colors duration-200 text-[var(--text-muted)] font-bold text-base">+</button>
                </div>
            </div>
        </div>

        <!-- Main Scrollable Content -->
        <div class="flex-1 overflow-y-auto relative z-[201] focus-scroll-area">
            <div class="max-w-3xl mx-auto px-6 sm:px-10 pt-20 pb-32">

                <!-- Bismillah -->
                <div x-show="selectedSurah !== 1 && selectedSurah !== 9 && !loading && currentAyahs.length > 0"
                     class="text-center mb-10">
                    <p class="text-[var(--text)]" style="font-family:'Amiri',serif;font-size:2rem;line-height:2.4;">
                        بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
                    </p>
                    <div class="flex items-center justify-center gap-3 mt-1 opacity-35">
                        <div class="h-px w-20 bg-[var(--gold)]"></div>
                        <div class="w-1.5 h-1.5 rounded-full bg-[var(--gold)]"></div>
                        <div class="h-px w-20 bg-[var(--gold)]"></div>
                    </div>
                </div>

                <!-- Quranic Text -->
                <div x-show="!loading && currentAyahs.length > 0">
                    <div class="text-justify text-[var(--text)]"
                         :style="'font-family:\'' + selectedFont.cssFamily + '\',\'Amiri\',serif;font-size:' + fontSize + 'px;line-height:2.6;'"
                         dir="rtl">
                        <template x-for="(ayah, index) in currentAyahs" :key="ayah.numberInSurah">
                            <span class="ayah-focus-segment">
                                <span x-html="ayah.text"></span>
                                <span class="inline-flex items-center justify-center mx-1.5 ayah-number-container"
                                      style="width:26px;height:26px;vertical-align:middle;position:relative;">
                                    <svg class="absolute inset-0" viewBox="0 0 26 26" fill="none">
                                        <circle cx="13" cy="13" r="12" fill="color-mix(in srgb,var(--gold) 20%, var(--surface))" stroke="var(--gold)" stroke-width="1.5"/>
                                    </svg>
                                    <span class="relative text-xs font-bold text-[var(--text)]" x-text="ayah.numberInSurah"></span>
                                </span>
                            </span>
                        </template>
                    </div>
                </div>

                <!-- Loading -->
                <div x-show="loading" class="text-center py-32">
                    <div class="w-12 h-12 border-4 border-[var(--border)] border-t-[var(--primary)] rounded-full animate-spin mx-auto mb-4"></div>
                    <p class="text-[var(--text-muted)] font-medium">جارٍ التحميل...</p>
                </div>

                <!-- No Surah Selected -->
                <div x-show="!selectedSurah && !loading" class="text-center py-32">
                    <iconify-icon icon="solar:book-2-bold-duotone" class="text-6xl text-[var(--gold)] mb-4 block"></iconify-icon>
                    <p class="text-[var(--text)] font-bold text-xl mb-2">اختر سورة للبدء</p>
                    <p class="text-[var(--text-muted)] text-sm">اضغط ESC للرجوع واختيار سورة</p>
                </div>

            </div>
        </div>

        <!-- Bottom Navigation Pill (auto-hide) -->
        <div x-show="focusBarVisible && selectedSurah && !loading"
             x-cloak
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0 translate-y-4"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-200"
             x-transition:leave-start="opacity-100 translate-y-0"
             x-transition:leave-end="opacity-0 translate-y-4"
             class="fixed bottom-6 inset-x-0 z-[302] flex justify-center pointer-events-none">
            <div class="flex items-center gap-2 px-3 py-2 rounded-2xl shadow-[var(--shadow)] pointer-events-auto bg-[color-mix(in_srgb,var(--surface)_92%,transparent)] backdrop-blur-xl border border-[var(--border)]">

                <button @click="selectedSurah > 1 && selectSurah(selectedSurah - 1)"
                        :disabled="selectedSurah <= 1"
                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-sm font-bold text-[var(--text)] hover:bg-[var(--surface-2)] disabled:opacity-30 disabled:cursor-not-allowed transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <iconify-icon icon="solar:arrow-right-bold" class="text-sm"></iconify-icon>
                    <span class="hidden sm:inline">السابقة</span>
                </button>

                <div class="px-3 py-1 rounded-lg bg-[var(--surface-2)] border border-[var(--border)] text-xs font-bold text-[var(--text)] min-w-[52px] text-center"
                     x-text="selectedSurah + ' / 114'"></div>

                <button @click="selectedSurah < 114 && selectSurah(selectedSurah + 1)"
                        :disabled="selectedSurah >= 114"
                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-sm font-bold text-[var(--text)] hover:bg-[var(--surface-2)] disabled:opacity-30 disabled:cursor-not-allowed transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <span class="hidden sm:inline">التالية</span>
                    <iconify-icon icon="solar:arrow-left-bold" class="text-sm"></iconify-icon>
                </button>
            </div>
        </div>

    </div>

    <style>
    /* Focus Mode Styles */
    .glass-panel-focus {
        background: rgba(255, 255, 255, 0.75);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
    }

    .mushaf-page-premium {
        position: relative;
        min-height: calc(100vh - 10rem);
    }

    .mushaf-page-premium::before {
        content: '';
        position: absolute;
        inset: -4px;
        background: linear-gradient(135deg, rgba(251, 191, 36, 0.1) 0%, rgba(217, 119, 6, 0.1) 100%);
        border-radius: 28px;
        pointer-events: none;
        z-index: -1;
    }

    /* Ayah segment hover effects */
    .ayah-segment {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 4px 2px;
        border-radius: 6px;
        cursor: pointer;
    }

    .ayah-segment:hover {
        background: linear-gradient(135deg, rgba(251, 191, 36, 0.08) 0%, rgba(254, 243, 199, 0.15) 100%);
        box-shadow: 0 2px 8px rgba(217, 119, 6, 0.1);
    }

    .ayah-text {
        transition: color 0.3s;
    }

    .ayah-segment:hover .ayah-text {
        color: #92400e;
    }

    /* Ayah number animation */
    .ayah-number-container {
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .ayah-segment:hover .ayah-number-container {
        transform: scale(1.15) rotate(5deg);
    }

    .ayah-number-container svg {
        filter: drop-shadow(0 2px 4px rgba(217, 119, 6, 0.2));
    }

    /* Smooth scrollbar for focus mode */
    .z-\[200\]::-webkit-scrollbar {
        width: 10px;
    }

    .z-\[200\]::-webkit-scrollbar-track {
        background: rgba(251, 191, 36, 0.1);
        border-radius: 10px;
    }

    .z-\[200\]::-webkit-scrollbar-thumb {
        background: linear-gradient(180deg, #fbbf24 0%, #d97706 100%);
        border-radius: 10px;
        border: 2px solid rgba(255, 255, 255, 0.3);
    }

    .z-\[200\]::-webkit-scrollbar-thumb:hover {
        background: linear-gradient(180deg, #f59e0b 0%, #b45309 100%);
    }

    /* Fade in animation for ayahs */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .ayah-segment {
        animation: fadeInUp 0.6s ease-out backwards;
    }

    .ayah-segment:nth-child(1) { animation-delay: 0.05s; }
    .ayah-segment:nth-child(2) { animation-delay: 0.1s; }
    .ayah-segment:nth-child(3) { animation-delay: 0.15s; }
    .ayah-segment:nth-child(4) { animation-delay: 0.2s; }
    .ayah-segment:nth-child(5) { animation-delay: 0.25s; }
    </style>

    <!-- الفوتر -->
    <div x-show="!focusMode">
        @include('partials.web-footer')
    </div>

    <script>
        // Surahs data
        const surahsData = [
            {"number":1,"name":"الفاتحة","englishName":"Al-Fatihah","revelationType":"Meccan","numberOfAyahs":7},
            {"number":2,"name":"البقرة","englishName":"Al-Baqarah","revelationType":"Medinan","numberOfAyahs":286},
            {"number":3,"name":"آل عمران","englishName":"Ali 'Imran","revelationType":"Medinan","numberOfAyahs":200},
            {"number":4,"name":"النساء","englishName":"An-Nisa","revelationType":"Medinan","numberOfAyahs":176},
            {"number":5,"name":"المائدة","englishName":"Al-Ma'idah","revelationType":"Medinan","numberOfAyahs":120},
            {"number":6,"name":"الأنعام","englishName":"Al-An'am","revelationType":"Meccan","numberOfAyahs":165},
            {"number":7,"name":"الأعراف","englishName":"Al-A'raf","revelationType":"Meccan","numberOfAyahs":206},
            {"number":8,"name":"الأنفال","englishName":"Al-Anfal","revelationType":"Medinan","numberOfAyahs":75},
            {"number":9,"name":"التوبة","englishName":"At-Tawbah","revelationType":"Medinan","numberOfAyahs":129},
            {"number":10,"name":"يونس","englishName":"Yunus","revelationType":"Meccan","numberOfAyahs":109},
            {"number":11,"name":"هود","englishName":"Hud","revelationType":"Meccan","numberOfAyahs":123},
            {"number":12,"name":"يوسف","englishName":"Yusuf","revelationType":"Meccan","numberOfAyahs":111},
            {"number":13,"name":"الرعد","englishName":"Ar-Ra'd","revelationType":"Medinan","numberOfAyahs":43},
            {"number":14,"name":"إبراهيم","englishName":"Ibrahim","revelationType":"Meccan","numberOfAyahs":52},
            {"number":15,"name":"الحجر","englishName":"Al-Hijr","revelationType":"Meccan","numberOfAyahs":99},
            {"number":16,"name":"النحل","englishName":"An-Nahl","revelationType":"Meccan","numberOfAyahs":128},
            {"number":17,"name":"الإسراء","englishName":"Al-Isra","revelationType":"Meccan","numberOfAyahs":111},
            {"number":18,"name":"الكهف","englishName":"Al-Kahf","revelationType":"Meccan","numberOfAyahs":110},
            {"number":19,"name":"مريم","englishName":"Maryam","revelationType":"Meccan","numberOfAyahs":98},
            {"number":20,"name":"طه","englishName":"Taha","revelationType":"Meccan","numberOfAyahs":135},
            {"number":21,"name":"الأنبياء","englishName":"Al-Anbya","revelationType":"Meccan","numberOfAyahs":112},
            {"number":22,"name":"الحج","englishName":"Al-Hajj","revelationType":"Medinan","numberOfAyahs":78},
            {"number":23,"name":"المؤمنون","englishName":"Al-Mu'minun","revelationType":"Meccan","numberOfAyahs":118},
            {"number":24,"name":"النور","englishName":"An-Nur","revelationType":"Medinan","numberOfAyahs":64},
            {"number":25,"name":"الفرقان","englishName":"Al-Furqan","revelationType":"Meccan","numberOfAyahs":77},
            {"number":26,"name":"الشعراء","englishName":"Ash-Shu'ara","revelationType":"Meccan","numberOfAyahs":227},
            {"number":27,"name":"النمل","englishName":"An-Naml","revelationType":"Meccan","numberOfAyahs":93},
            {"number":28,"name":"القصص","englishName":"Al-Qasas","revelationType":"Meccan","numberOfAyahs":88},
            {"number":29,"name":"العنكبوت","englishName":"Al-'Ankabut","revelationType":"Meccan","numberOfAyahs":69},
            {"number":30,"name":"الروم","englishName":"Ar-Rum","revelationType":"Meccan","numberOfAyahs":60},
            {"number":31,"name":"لقمان","englishName":"Luqman","revelationType":"Meccan","numberOfAyahs":34},
            {"number":32,"name":"السجدة","englishName":"As-Sajdah","revelationType":"Meccan","numberOfAyahs":30},
            {"number":33,"name":"الأحزاب","englishName":"Al-Ahzab","revelationType":"Medinan","numberOfAyahs":73},
            {"number":34,"name":"سبأ","englishName":"Saba","revelationType":"Meccan","numberOfAyahs":54},
            {"number":35,"name":"فاطر","englishName":"Fatir","revelationType":"Meccan","numberOfAyahs":45},
            {"number":36,"name":"يس","englishName":"Ya-Sin","revelationType":"Meccan","numberOfAyahs":83},
            {"number":37,"name":"الصافات","englishName":"As-Saffat","revelationType":"Meccan","numberOfAyahs":182},
            {"number":38,"name":"ص","englishName":"Sad","revelationType":"Meccan","numberOfAyahs":88},
            {"number":39,"name":"الزمر","englishName":"Az-Zumar","revelationType":"Meccan","numberOfAyahs":75},
            {"number":40,"name":"غافر","englishName":"Ghafir","revelationType":"Meccan","numberOfAyahs":85},
            {"number":41,"name":"فصلت","englishName":"Fussilat","revelationType":"Meccan","numberOfAyahs":54},
            {"number":42,"name":"الشورى","englishName":"Ash-Shuraa","revelationType":"Meccan","numberOfAyahs":53},
            {"number":43,"name":"الزخرف","englishName":"Az-Zukhruf","revelationType":"Meccan","numberOfAyahs":89},
            {"number":44,"name":"الدخان","englishName":"Ad-Dukhan","revelationType":"Meccan","numberOfAyahs":59},
            {"number":45,"name":"الجاثية","englishName":"Al-Jathiyah","revelationType":"Meccan","numberOfAyahs":37},
            {"number":46,"name":"الأحقاف","englishName":"Al-Ahqaf","revelationType":"Meccan","numberOfAyahs":35},
            {"number":47,"name":"محمد","englishName":"Muhammad","revelationType":"Medinan","numberOfAyahs":38},
            {"number":48,"name":"الفتح","englishName":"Al-Fath","revelationType":"Medinan","numberOfAyahs":29},
            {"number":49,"name":"الحجرات","englishName":"Al-Hujurat","revelationType":"Medinan","numberOfAyahs":18},
            {"number":50,"name":"ق","englishName":"Qaf","revelationType":"Meccan","numberOfAyahs":45},
            {"number":51,"name":"الذاريات","englishName":"Adh-Dhariyat","revelationType":"Meccan","numberOfAyahs":60},
            {"number":52,"name":"الطور","englishName":"At-Tur","revelationType":"Meccan","numberOfAyahs":49},
            {"number":53,"name":"النجم","englishName":"An-Najm","revelationType":"Meccan","numberOfAyahs":62},
            {"number":54,"name":"القمر","englishName":"Al-Qamar","revelationType":"Meccan","numberOfAyahs":55},
            {"number":55,"name":"الرحمن","englishName":"Ar-Rahman","revelationType":"Medinan","numberOfAyahs":78},
            {"number":56,"name":"الواقعة","englishName":"Al-Waqi'ah","revelationType":"Meccan","numberOfAyahs":96},
            {"number":57,"name":"الحديد","englishName":"Al-Hadid","revelationType":"Medinan","numberOfAyahs":29},
            {"number":58,"name":"المجادلة","englishName":"Al-Mujadila","revelationType":"Medinan","numberOfAyahs":22},
            {"number":59,"name":"الحشر","englishName":"Al-Hashr","revelationType":"Medinan","numberOfAyahs":24},
            {"number":60,"name":"الممتحنة","englishName":"Al-Mumtahanah","revelationType":"Medinan","numberOfAyahs":13},
            {"number":61,"name":"الصف","englishName":"As-Saf","revelationType":"Medinan","numberOfAyahs":14},
            {"number":62,"name":"الجمعة","englishName":"Al-Jumu'ah","revelationType":"Medinan","numberOfAyahs":11},
            {"number":63,"name":"المنافقون","englishName":"Al-Munafiqun","revelationType":"Medinan","numberOfAyahs":11},
            {"number":64,"name":"التغابن","englishName":"At-Taghabun","revelationType":"Medinan","numberOfAyahs":18},
            {"number":65,"name":"الطلاق","englishName":"At-Talaq","revelationType":"Medinan","numberOfAyahs":12},
            {"number":66,"name":"التحريم","englishName":"At-Tahrim","revelationType":"Medinan","numberOfAyahs":12},
            {"number":67,"name":"الملك","englishName":"Al-Mulk","revelationType":"Meccan","numberOfAyahs":30},
            {"number":68,"name":"القلم","englishName":"Al-Qalam","revelationType":"Meccan","numberOfAyahs":52},
            {"number":69,"name":"الحاقة","englishName":"Al-Haqqah","revelationType":"Meccan","numberOfAyahs":52},
            {"number":70,"name":"المعارج","englishName":"Al-Ma'arij","revelationType":"Meccan","numberOfAyahs":44},
            {"number":71,"name":"نوح","englishName":"Nuh","revelationType":"Meccan","numberOfAyahs":28},
            {"number":72,"name":"الجن","englishName":"Al-Jinn","revelationType":"Meccan","numberOfAyahs":28},
            {"number":73,"name":"المزمل","englishName":"Al-Muzzammil","revelationType":"Meccan","numberOfAyahs":20},
            {"number":74,"name":"المدثر","englishName":"Al-Muddaththir","revelationType":"Meccan","numberOfAyahs":56},
            {"number":75,"name":"القيامة","englishName":"Al-Qiyamah","revelationType":"Meccan","numberOfAyahs":40},
            {"number":76,"name":"الإنسان","englishName":"Al-Insan","revelationType":"Medinan","numberOfAyahs":31},
            {"number":77,"name":"المرسلات","englishName":"Al-Mursalat","revelationType":"Meccan","numberOfAyahs":50},
            {"number":78,"name":"النبأ","englishName":"An-Naba","revelationType":"Meccan","numberOfAyahs":40},
            {"number":79,"name":"النازعات","englishName":"An-Nazi'at","revelationType":"Meccan","numberOfAyahs":46},
            {"number":80,"name":"عبس","englishName":"'Abasa","revelationType":"Meccan","numberOfAyahs":42},
            {"number":81,"name":"التكوير","englishName":"At-Takwir","revelationType":"Meccan","numberOfAyahs":29},
            {"number":82,"name":"الإنفطار","englishName":"Al-Infitar","revelationType":"Meccan","numberOfAyahs":19},
            {"number":83,"name":"المطففين","englishName":"Al-Mutaffifin","revelationType":"Meccan","numberOfAyahs":36},
            {"number":84,"name":"الإنشقاق","englishName":"Al-Inshiqaq","revelationType":"Meccan","numberOfAyahs":25},
            {"number":85,"name":"البروج","englishName":"Al-Buruj","revelationType":"Meccan","numberOfAyahs":22},
            {"number":86,"name":"الطارق","englishName":"At-Tariq","revelationType":"Meccan","numberOfAyahs":17},
            {"number":87,"name":"الأعلى","englishName":"Al-A'la","revelationType":"Meccan","numberOfAyahs":19},
            {"number":88,"name":"الغاشية","englishName":"Al-Ghashiyah","revelationType":"Meccan","numberOfAyahs":26},
            {"number":89,"name":"الفجر","englishName":"Al-Fajr","revelationType":"Meccan","numberOfAyahs":30},
            {"number":90,"name":"البلد","englishName":"Al-Balad","revelationType":"Meccan","numberOfAyahs":20},
            {"number":91,"name":"الشمس","englishName":"Ash-Shams","revelationType":"Meccan","numberOfAyahs":15},
            {"number":92,"name":"الليل","englishName":"Al-Layl","revelationType":"Meccan","numberOfAyahs":21},
            {"number":93,"name":"الضحى","englishName":"Ad-Duhaa","revelationType":"Meccan","numberOfAyahs":11},
            {"number":94,"name":"الشرح","englishName":"Ash-Sharh","revelationType":"Meccan","numberOfAyahs":8},
            {"number":95,"name":"التين","englishName":"At-Tin","revelationType":"Meccan","numberOfAyahs":8},
            {"number":96,"name":"العلق","englishName":"Al-'Alaq","revelationType":"Meccan","numberOfAyahs":19},
            {"number":97,"name":"القدر","englishName":"Al-Qadr","revelationType":"Meccan","numberOfAyahs":5},
            {"number":98,"name":"البينة","englishName":"Al-Bayyinah","revelationType":"Medinan","numberOfAyahs":8},
            {"number":99,"name":"الزلزلة","englishName":"Az-Zalzalah","revelationType":"Medinan","numberOfAyahs":8},
            {"number":100,"name":"العاديات","englishName":"Al-'Adiyat","revelationType":"Meccan","numberOfAyahs":11},
            {"number":101,"name":"القارعة","englishName":"Al-Qari'ah","revelationType":"Meccan","numberOfAyahs":11},
            {"number":102,"name":"التكاثر","englishName":"At-Takathur","revelationType":"Meccan","numberOfAyahs":8},
            {"number":103,"name":"العصر","englishName":"Al-'Asr","revelationType":"Meccan","numberOfAyahs":3},
            {"number":104,"name":"الهمزة","englishName":"Al-Humazah","revelationType":"Meccan","numberOfAyahs":9},
            {"number":105,"name":"الفيل","englishName":"Al-Fil","revelationType":"Meccan","numberOfAyahs":5},
            {"number":106,"name":"قريش","englishName":"Quraysh","revelationType":"Meccan","numberOfAyahs":4},
            {"number":107,"name":"الماعون","englishName":"Al-Ma'un","revelationType":"Meccan","numberOfAyahs":7},
            {"number":108,"name":"الكوثر","englishName":"Al-Kawthar","revelationType":"Meccan","numberOfAyahs":3},
            {"number":109,"name":"الكافرون","englishName":"Al-Kafirun","revelationType":"Meccan","numberOfAyahs":6},
            {"number":110,"name":"النصر","englishName":"An-Nasr","revelationType":"Medinan","numberOfAyahs":3},
            {"number":111,"name":"المسد","englishName":"Al-Masad","revelationType":"Meccan","numberOfAyahs":5},
            {"number":112,"name":"الإخلاص","englishName":"Al-Ikhlas","revelationType":"Meccan","numberOfAyahs":4},
            {"number":113,"name":"الفلق","englishName":"Al-Falaq","revelationType":"Meccan","numberOfAyahs":5},
            {"number":114,"name":"الناس","englishName":"An-Nas","revelationType":"Meccan","numberOfAyahs":6}
        ];

        // i18n System for Navbar
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
                            quranPremium: 'القرآن الكريم',
                            quranText: 'القرآن النصي',
                            hisnmuslim: 'حصن المسلم',
                            privacy: 'الخصوصية'
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
                        brand: {
                            name: "I'm Muslim"
                        },
                        nav: {
                            home: 'Home',
                            quranPremium: 'Holy Quran',
                            quranText: 'Quran Text',
                            hisnmuslim: 'Hisn Al-Muslim',
                            privacy: 'Privacy'
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
                }
            }
        }

        // ── Quran Fonts List ────────────────────────────────────────
        window.QURAN_FONTS_LIST = [
            { key: 'default',       name: 'الخط الافتراضي (أميري)', cssFamily: 'Amiri',          woff2: null },
            { key: 'quran_madina', name: 'مصحف المدينة',           cssFamily: 'QuranMadina',     woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/maddina.woff2' },
            { key: 'kfgqpc_hafs',  name: 'مجمع الملك فهد - حفص',  cssFamily: 'KFGQPCHafs',      woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/hafs-uthmanic-v14-full.woff2' },
            { key: 'kfgqpc_warsh', name: 'مجمع الملك فهد - ورش',  cssFamily: 'KFGQPCWarsh',     woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/warsh-v8-full.woff2' },
            { key: 'kfgqpc_qaloon',name: 'مجمع الملك فهد - قالون', cssFamily: 'KFGQPCQaloon',   woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qaloon-v8-full.woff2' },
            { key: 'kfgqpc_doori', name: 'مجمع الملك فهد - الدوري', cssFamily: 'KFGQPCDoori',   woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/doori-v8-full.woff2' },
            { key: 'amiri_quran',  name: 'الخط الأميري القرآني',   cssFamily: 'AmiriQuran',      woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/amiri-quran-full.woff2' },
            { key: 'al_qalam_majeed', name: 'خط القلم - قرآن مجيد', cssFamily: 'AlQalamMajeed', woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/al-qalam-quran-majeed.woff2' },
            { key: 'al_mushaf',    name: 'خط المصحف',              cssFamily: 'AlMushaf',        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/almushaf.woff2' },
            { key: 'quran_standard', name: 'خط القرآن المعياري',  cssFamily: 'QuranStandard',   woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qur-std.woff2' },
            { key: 'noorehuda',    name: 'خط نور الهدى - نسخ',    cssFamily: 'NoorehudaNaskh',  woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/noorehuda-regular.woff2' },
        ];
        window._loadedQuranFonts = new Set(['Amiri']);

        // Restore saved font on page load
        (async () => {
            const savedKey = localStorage.getItem('quran_font_key');
            if (savedKey && savedKey !== 'default') {
                const font = window.QURAN_FONTS_LIST.find(f => f.key === savedKey);
                if (font && font.woff2) {
                    const style = document.createElement('style');
                    style.textContent = `@font-face { font-family: '${font.cssFamily}'; src: url('${font.woff2}') format('woff2'); font-display: swap; }`;
                    document.head.appendChild(style);
                    try { await document.fonts.load(`1rem '${font.cssFamily}'`); } catch(_) {}
                    window._loadedQuranFonts.add(font.cssFamily);
                }
            }
        })();

        function quranApp() {
            return {
                // i18n integration
                ...i18n(),

                // Dark Mode
                darkMode: localStorage.getItem('darkMode') === 'true',

                // Font Size
                fontSize: localStorage.getItem('quranFontSize') || 28,

                // Quran Font Family
                availableFonts: window.QURAN_FONTS_LIST,
                selectedFont: (() => {
                    const key = localStorage.getItem('quran_font_key') || 'default';
                    return window.QURAN_FONTS_LIST.find(f => f.key === key) || window.QURAN_FONTS_LIST[0];
                })(),
                fontLoading: false,
                showFontMenu: false,

                // Surahs & Ayahs
                surahs: surahsData,
                selectedSurah: null,
                currentSurahData: null,
                currentAyahs: [],
                selectedAyah: null,

                // Reciters
                reciters: [],
                selectedReciter: 7, // Default: Alafasy
                selectedReciterName: 'مشاري راشد العفاسي',
                showReciterModal: false,

                // Audio Player
                audio: null,
                isPlaying: false,
                currentTime: '0:00',
                duration: '0:00',
                progress: 0,
                volume: 70,
                repeatMode: false,

                // Tafsir
                showTafsirModal: false,
                currentTafsirAyah: null,
                currentTafsirText: '',
                selectedTafsir: 16,
                loadingTafsir: false,

                // Bookmarks
                bookmarks: JSON.parse(localStorage.getItem('quranBookmarks') || '[]'),
                showBookmarks: false,

                // Focus Mode
                focusMode: false,
                focusBarVisible: true,
                focusBarTimer: null,

                // Loading State
                loading: false,

                // Search
                searchQuery: '',
                searchResults: [],

                // Download
                downloading: false,
                showDownloadModal: false,
                downloadProgress: 0,
                downloadedSize: '0 MB',
                totalSize: '0 MB',

                // Dialog
                showDialog: false,
                dialogType: 'info', // success, error, info
                dialogTitle: '',
                dialogMessage: '',

                // Reciter Search & Default
                reciterSearchQuery: '',
                selectedNationality: '',
                filteredReciters: [],
                defaultReciterId: localStorage.getItem('defaultReciterId') ? parseInt(localStorage.getItem('defaultReciterId')) : 7,

                nationalityLabels: {
                    'SA': 'سعودي', 'EG': 'مصري', 'AE': 'إماراتي', 'KW': 'كويتي',
                    'QA': 'قطري', 'BH': 'بحريني', 'OM': 'عماني', 'YE': 'يمني',
                    'IQ': 'عراقي', 'SY': 'سوري', 'JO': 'أردني', 'PS': 'فلسطيني',
                    'LB': 'لبناني', 'LY': 'ليبي', 'TN': 'تونسي', 'DZ': 'جزائري',
                    'MA': 'مغربي', 'MR': 'موريتاني', 'SD': 'سوداني', 'SO': 'صومالي',
                    'DJ': 'جيبوتي', 'KM': 'قمري', 'TR': 'تركي', 'IR': 'إيراني',
                    'AF': 'أفغاني', 'PK': 'باكستاني', 'IN': 'هندي', 'BD': 'بنغلاديشي',
                    'MY': 'ماليزي', 'ID': 'إندونيسي', 'NG': 'نيجيري', 'SN': 'سنغالي',
                    'ML': 'مالي', 'TD': 'تشادي', 'OTHER': 'أخرى',
                },

                get availableNationalities() {
                    const counts = {};
                    this.reciters.forEach(r => {
                        if (r.nationality) {
                            const code = r.nationality;
                            counts[code] = (counts[code] || 0) + 1;
                        }
                    });
                    return Object.entries(counts)
                        .map(([code, count]) => ({ code, label: this.nationalityLabels[code] || code, count }))
                        .sort((a, b) => b.count - a.count);
                },

                async init() {
                    await this.fetchReciters();
                    this.loadLastPosition();

                    // Set default reciter
                    if (this.defaultReciterId) {
                        this.selectedReciter = this.defaultReciterId;
                        const defaultReciter = this.reciters.find(r => r.id === this.defaultReciterId);
                        if (defaultReciter) {
                            this.selectedReciterName = defaultReciter.name;
                        }
                    }

                    // Keyboard shortcuts
                    document.addEventListener('keydown', (e) => {
                        // ESC key - Exit focus mode
                        if (e.key === 'Escape' && this.focusMode) {
                            this.toggleFocusMode();
                        }
                    });
                },

                async fetchReciters() {
                    try {
                        const resp = await fetch('/api/mp3quran/reciters');
                        const data = await resp.json();
                        this.reciters = data.reciters || data.data?.reciters || [];
                        this.filteredReciters = this.reciters;

                        if (this.reciters.length > 0) {
                            const defaultReciter = this.reciters.find(r => r.id === this.defaultReciterId);
                            if (defaultReciter) {
                                this.selectedReciter = defaultReciter.id;
                                this.selectedReciterName = defaultReciter.name;
                            } else {
                                const alafasy = this.reciters.find(r => r.id === 7);
                                if (alafasy) {
                                    this.selectedReciter = alafasy.id;
                                    this.selectedReciterName = alafasy.name;
                                } else {
                                    this.selectedReciter = this.reciters[0].id;
                                    this.selectedReciterName = this.reciters[0].name;
                                }
                            }
                        }
                    } catch (error) {
                        console.error('Error fetching reciters:', error);
                    }
                },

                filterReciters() {
                    let result = this.reciters;

                    if (this.selectedNationality) {
                        result = result.filter(r => r.nationality === this.selectedNationality);
                    }

                    if (this.reciterSearchQuery) {
                        const query = this.reciterSearchQuery.toLowerCase();
                        result = result.filter(r => r.name.toLowerCase().includes(query));
                    }

                    this.filteredReciters = result;
                },

                setDefaultReciter(reciter) {
                    this.defaultReciterId = reciter.id;
                    localStorage.setItem('defaultReciterId', reciter.id);
                    this.showAlert('success', 'تم الحفظ', `تم تعيين ${reciter.name} كقارئ افتراضي`);
                },

                showAlert(type, title, message) {
                    this.dialogType = type;
                    this.dialogTitle = title;
                    this.dialogMessage = message;
                    this.showDialog = true;
                },

                async selectSurah(surahNumber) {
                    this.selectedSurah = surahNumber;
                    this.currentSurahData = this.surahs.find(s => s.number === surahNumber);
                    this.selectedAyah = null;

                    await this.loadSurah();
                    this.saveLastPosition();
                },

                async loadSurah() {
                    this.loading = true;
                    try {
                        const response = await fetch(
                            `https://api.quran.com/api/v4/verses/by_chapter/${this.selectedSurah}` +
                            `?language=ar&words=false&per_page=300&fields=text_uthmani`
                        );
                        const data = await response.json();

                        if (data.verses) {
                            const ayahs = data.verses.map(verse => ({
                                number: verse.id,
                                numberInSurah: verse.verse_number,
                                verseKey: verse.verse_key,
                                text: verse.text_uthmani,
                                surahName: this.currentSurahData.name,
                            }));

                            this.currentAyahs = ayahs;
                            await this.setupAudio();
                        }
                    } catch (error) {
                        console.error('Error loading surah:', error);
                    } finally {
                        this.loading = false;
                    }
                },

                async setupAudio() {
                    this.stopAudio();

                    const reciter = this.reciters.find(r => r.id === this.selectedReciter);
                    if (!reciter) return;

                    let audioUrl = null;
                    if (reciter.moshaf && reciter.moshaf[0]) {
                        const moshaf = reciter.moshaf[0];
                        if (moshaf.direct_surah_urls && moshaf.direct_surah_urls[String(this.selectedSurah)]) {
                            audioUrl = moshaf.direct_surah_urls[String(this.selectedSurah)];
                        } else if (moshaf.server) {
                            const surahFormatted = this.selectedSurah.toString().padStart(3, '0');
                            audioUrl = `${moshaf.server}/${surahFormatted}.mp3`;
                        }
                    }

                    if (!audioUrl) return;

                    this.audio = new Audio(audioUrl);
                    this.audio.volume = this.volume / 100;

                    this.audio.addEventListener('loadedmetadata', () => {
                        this.duration = this.formatTime(this.audio.duration);
                    });

                    this.audio.addEventListener('timeupdate', () => {
                        this.currentTime = this.formatTime(this.audio.currentTime);
                        this.progress = (this.audio.currentTime / this.audio.duration) * 100;
                    });

                    this.audio.addEventListener('ended', () => {
                        if (this.repeatMode) {
                            this.audio.currentTime = 0;
                            this.audio.play();
                        } else {
                            this.isPlaying = false;
                        }
                    });
                },

                selectReciter(reciter) {
                    this.selectedReciter = reciter.id;
                    this.selectedReciterName = reciter.name;
                    if (this.selectedSurah) {
                        this.setupAudio();
                    }
                },

                toggleAudio() {
                    if (!this.audio) return;

                    if (this.isPlaying) {
                        this.audio.pause();
                        this.isPlaying = false;
                    } else {
                        this.audio.play();
                        this.isPlaying = true;
                    }
                },

                stopAudio() {
                    if (this.audio) {
                        this.audio.pause();
                        this.audio = null;
                        this.isPlaying = false;
                        this.currentTime = '0:00';
                        this.duration = '0:00';
                        this.progress = 0;
                    }
                },

                seekAudio(event) {
                    if (!this.audio) return;
                    const rect = event.currentTarget.getBoundingClientRect();
                    const x = event.clientX - rect.left;
                    const percentage = x / rect.width;
                    this.audio.currentTime = this.audio.duration * percentage;
                },

                changeVolume() {
                    if (this.audio) {
                        this.audio.volume = this.volume / 100;
                    }
                },

                toggleRepeat() {
                    this.repeatMode = !this.repeatMode;
                },

                skipForward() {
                    // Skip 10 seconds forward
                    if (this.audio) {
                        this.audio.currentTime = Math.min(this.audio.currentTime + 10, this.audio.duration);
                    }
                },

                skipBackward() {
                    // Skip 10 seconds backward
                    if (this.audio) {
                        this.audio.currentTime = Math.max(this.audio.currentTime - 10, 0);
                    }
                },

                selectAyah(ayah) {
                    this.selectedAyah = ayah.numberInSurah;
                },

                async showTafsir(ayah) {
                    this.currentTafsirAyah = ayah;
                    this.showTafsirModal = true;
                    this.loadingTafsir = true;

                    try {
                        const response = await fetch(
                            `https://api.quran.com/api/v4/tafsirs/${this.selectedTafsir}/by_ayah/${ayah.verseKey}?language=ar`
                        );
                        const data = await response.json();
                        this.currentTafsirText = data.tafsir?.text || 'لا يوجد تفسير لهذه الآية';
                    } catch (error) {
                        console.error('Error fetching tafsir:', error);
                        this.currentTafsirText = 'عذراً، حدث خطأ في تحميل التفسير';
                    } finally {
                        this.loadingTafsir = false;
                    }
                },

                async changeTafsir(tafsirType) {
                    if (this.selectedTafsir === tafsirType) return; // Already selected

                    this.selectedTafsir = tafsirType;

                    // Reload tafsir if modal is open
                    if (this.showTafsirModal && this.currentTafsirAyah) {
                        await this.reloadTafsir();
                    }
                },

                async reloadTafsir() {
                    if (!this.currentTafsirAyah) return;

                    this.loadingTafsir = true;

                    try {
                        const response = await fetch(
                            `https://api.quran.com/api/v4/tafsirs/${this.selectedTafsir}/by_ayah/${this.currentTafsirAyah.verseKey}?language=ar`
                        );
                        const data = await response.json();
                        this.currentTafsirText = data.tafsir?.text || 'لا يوجد تفسير لهذه الآية';
                    } catch (error) {
                        console.error('Error fetching tafsir:', error);
                        this.currentTafsirText = 'عذراً، حدث خطأ في تحميل التفسير';
                    } finally {
                        this.loadingTafsir = false;
                    }
                },

                async toggleFocusMode() {
                    this.focusMode = !this.focusMode;

                    if (this.focusMode) {
                        document.body.classList.add('overflow-hidden');
                        this.showSidebar = false;
                        this.showBookmarksPanel = false;
                        this.showTafsirModal = false;

                        if (!this.selectedSurah) {
                            await this.selectSurah(1);
                        }

                        if (this.isPlaying) {
                            this.audio.pause();
                            this.isPlaying = false;
                        }

                        // Show bar briefly on enter, then auto-hide
                        this.showFocusBar();
                    } else {
                        document.body.classList.remove('overflow-hidden');
                        clearTimeout(this.focusBarTimer);
                        this.focusBarVisible = true;
                    }
                },

                showFocusBar() {
                    this.focusBarVisible = true;
                    clearTimeout(this.focusBarTimer);
                    this.focusBarTimer = setTimeout(() => {
                        this.focusBarVisible = false;
                    }, 3000);
                },

                toggleBookmark(ayah) {
                    const bookmarkId = `${this.selectedSurah}-${ayah.numberInSurah}`;
                    const existingIndex = this.bookmarks.findIndex(b => b.id === bookmarkId);

                    if (existingIndex > -1) {
                        this.bookmarks.splice(existingIndex, 1);
                    } else {
                        this.bookmarks.push({
                            id: bookmarkId,
                            surahNumber: this.selectedSurah,
                            surahName: this.currentSurahData.name,
                            ayahNumber: ayah.numberInSurah,
                            ayahText: ayah.text,
                            timestamp: new Date().toISOString()
                        });
                    }

                    localStorage.setItem('quranBookmarks', JSON.stringify(this.bookmarks));
                },

                isBookmarked(ayah) {
                    const bookmarkId = `${this.selectedSurah}-${ayah.numberInSurah}`;
                    return this.bookmarks.some(b => b.id === bookmarkId);
                },

                removeBookmark(bookmarkId) {
                    this.bookmarks = this.bookmarks.filter(b => b.id !== bookmarkId);
                    localStorage.setItem('quranBookmarks', JSON.stringify(this.bookmarks));
                },

                goToBookmark(bookmark) {
                    this.showBookmarks = false;
                    this.selectSurah(bookmark.surahNumber);
                    setTimeout(() => {
                        this.selectedAyah = bookmark.ayahNumber;
                    }, 500);
                },

                copyAyah(ayah) {
                    const text = `${ayah.text}\n(${this.currentSurahData.name} - آية ${ayah.numberInSurah})`;
                    navigator.clipboard.writeText(text);

                    this.showAlert('success', 'تم النسخ', 'تم نسخ الآية بنجاح!');
                },

                async searchQuran() {
                    if (this.searchQuery.length < 3) {
                        this.searchResults = [];
                        return;
                    }

                    try {
                        const response = await fetch(`https://api.alquran.cloud/v1/search/${this.searchQuery}/all/ar`);
                        const data = await response.json();

                        if (data.code === 200 && data.data.matches) {
                            this.searchResults = data.data.matches.map(match => ({
                                surahNum: match.surah.number,
                                surahName: match.surah.name,
                                ayahNum: match.numberInSurah,
                                text: match.text
                            }));
                        }
                    } catch (error) {
                        console.error('Error searching Quran:', error);
                    }
                },

                goToSearchResult(result) {
                    this.searchResults = [];
                    this.searchQuery = '';
                    this.selectSurah(result.surahNum);
                    setTimeout(() => {
                        this.selectedAyah = result.ayahNum;
                    }, 500);
                },

                highlightSearchTerm(text, term) {
                    if (!term) return text;
                    const regex = new RegExp(`(${term})`, 'gi');
                    return text.replace(regex, '<mark class="bg-[color-mix(in_srgb,var(--gold)_35%,transparent)] text-[var(--text)] rounded px-1">$1</mark>');
                },

                downloadSurah() {
                    if (!this.audio || !this.audio.src) {
                        this.showAlert('error', 'خطأ', 'لا يوجد ملف صوتي للتحميل. يرجى اختيار سورة أولاً.');
                        return;
                    }

                    const surahName = this.currentSurahData?.name || 'سورة';
                    const fileName = `${surahName} - ${this.selectedReciterName}`;
                    const proxyUrl = `/quran/download?url=${encodeURIComponent(this.audio.src)}&name=${encodeURIComponent(fileName)}`;

                    const link = document.createElement('a');
                    link.href = proxyUrl;
                    link.download = fileName + '.mp3';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    this.showAlert('success', 'تم', 'بدأ تحميل السورة');
                },

                formatBytes(bytes) {
                    if (bytes === 0) return '0 MB';
                    const mb = bytes / (1024 * 1024);
                    return mb.toFixed(2) + ' MB';
                },

                navigateSurah(direction) {
                    if (direction === 'next' && this.selectedSurah < 114) {
                        this.selectSurah(this.selectedSurah + 1);
                    } else if (direction === 'prev' && this.selectedSurah > 1) {
                        this.selectSurah(this.selectedSurah - 1);
                    }
                },

                getNextSurahName() {
                    if (this.selectedSurah >= 114) return '';
                    return this.surahs[this.selectedSurah]?.name || '';
                },

                getPrevSurahName() {
                    if (this.selectedSurah <= 1) return '';
                    return this.surahs[this.selectedSurah - 2]?.name || '';
                },

                saveLastPosition() {
                    localStorage.setItem('lastSurah', this.selectedSurah);
                },

                loadLastPosition() {
                    const lastSurah = localStorage.getItem('lastSurah');
                    if (lastSurah) {
                        // Don't auto-load, just remember it
                    }
                },

                convertToArabicNumbers(num) {
                    if (!num) return '';
                    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
                    return String(num).split('').map(d => arabicNums[parseInt(d)] || d).join('');
                },

                formatTime(seconds) {
                    if (isNaN(seconds)) return '0:00';
                    const mins = Math.floor(seconds / 60);
                    const secs = Math.floor(seconds % 60);
                    return `${mins}:${secs.toString().padStart(2, '0')}`;
                },

                increaseFontSize() {
                    this.fontSize = Math.min(parseInt(this.fontSize) + 2, 48);
                    localStorage.setItem('quranFontSize', this.fontSize);
                },

                decreaseFontSize() {
                    this.fontSize = Math.max(parseInt(this.fontSize) - 2, 16);
                    localStorage.setItem('quranFontSize', this.fontSize);
                },

                async applyFont(font) {
                    if (font.key === this.selectedFont.key) return;
                    if (font.woff2 && !window._loadedQuranFonts.has(font.cssFamily)) {
                        this.fontLoading = true;
                        try {
                            const style = document.createElement('style');
                            style.textContent = `@font-face { font-family: '${font.cssFamily}'; src: url('${font.woff2}') format('woff2'); font-display: swap; }`;
                            document.head.appendChild(style);
                            await document.fonts.load(`1rem '${font.cssFamily}'`);
                            window._loadedQuranFonts.add(font.cssFamily);
                        } catch (e) {
                            console.error('Font load failed:', e);
                        } finally {
                            this.fontLoading = false;
                        }
                    }
                    this.selectedFont = font;
                    localStorage.setItem('quran_font_key', font.key);
                }
            }
        }

    </script>
</body>
</html>
