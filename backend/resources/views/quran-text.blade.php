@extends('layouts.web')

@section('content')
<div x-data="quranTextApp()" x-init="init()" dir="rtl" class="text-[var(--text)]">

    {{-- ═══════════════════════════════════════════════════
         SURAH GRID VIEW
    ═══════════════════════════════════════════════════ --}}
    <div x-show="!selectedSurah" x-cloak
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0 translate-y-2"
         x-transition:enter-end="opacity-100 translate-y-0">

        {{-- Hero Header --}}
        <div class="relative pt-44 pb-12 px-4 text-center overflow-hidden">
            <div class="absolute inset-0 -z-10 pointer-events-none">
                <div class="absolute top-16 right-1/3 w-80 h-80 rounded-full blur-3xl opacity-25 bg-[color-mix(in_srgb,var(--primary)_20%,transparent)]"></div>
            </div>
            <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-5 bg-[var(--primary-soft)] text-[var(--primary)] border border-[color-mix(in_srgb,var(--primary)_35%,transparent)]">
                <iconify-icon icon="solar:book-2-bold"></iconify-icon>
                القرآن الكريم
            </div>
            <h1 class="text-5xl font-bold text-[var(--text)] mb-3" style="font-family:'Amiri',serif;">
                القرآن الكريم
            </h1>
            <p class="text-[var(--text-muted)] text-lg">اختر سورة للقراءة</p>
        </div>

        {{-- Search Bar --}}
        <div class="px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto mb-8">
            <div class="relative max-w-sm mx-auto">
                <iconify-icon icon="solar:magnifer-linear" class="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--text-soft)] text-xl pointer-events-none"></iconify-icon>
                <input type="text" x-model="searchQuery"
                       placeholder="ابحث عن سورة..."
                       class="w-full bg-[var(--surface)] border border-[var(--border)] rounded-2xl py-3 pr-12 pl-4 text-[var(--text)] placeholder-[var(--text-soft)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)] transition-all duration-200 shadow-[var(--shadow)]">
            </div>
        </div>

        {{-- Load Error State --}}
        <div x-show="loadError" class="px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto mb-8">
            <div class="flex flex-col items-center justify-center py-16 text-center">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center mb-4 bg-[color-mix(in_srgb,var(--danger)_18%,transparent)]">
                    <iconify-icon icon="solar:wifi-router-minimalistic-bold" class="text-3xl text-[var(--danger)]"></iconify-icon>
                </div>
                <h3 class="font-bold text-[var(--text)] text-lg mb-1">تعذّر تحميل القرآن</h3>
                <p class="text-[var(--text-soft)] text-sm mb-5">تحقق من اتصالك بالإنترنت ثم حاول مجدداً</p>
                <button @click="loadError = false; loadSurahs()"
                        class="flex items-center gap-2 px-6 py-2.5 rounded-2xl font-bold text-sm text-white transition-all duration-200 hover:brightness-110 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] bg-[var(--primary)]">
                    <iconify-icon icon="solar:refresh-bold"></iconify-icon>
                    إعادة المحاولة
                </button>
            </div>
        </div>

        {{-- Surahs Grid --}}
        <div x-show="!loadError" class="px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto pb-20">
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3">
                <template x-for="surah in filteredSurahs" :key="surah.number">
                    <button @click="selectSurah(surah.number)"
                            class="group bg-[var(--surface)] rounded-2xl p-4 text-center shadow-[var(--shadow)] hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-[var(--border)] hover:border-[var(--primary)] active:scale-[0.99] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)]">

                        {{-- Number Badge --}}
                        <div class="w-11 h-11 rounded-full mx-auto mb-3 flex items-center justify-center font-bold text-sm shadow-md bg-[var(--surface-2)] border border-[var(--border)] text-[var(--text)]"
                             x-text="surah.number"></div>

                        {{-- Arabic Name --}}
                        <h3 class="font-bold text-[var(--text)] text-xl leading-tight mb-1"
                            style="font-family:'Amiri',serif;"
                            x-text="surah.name"></h3>

                        {{-- English Name --}}
                        <p class="text-xs text-[var(--text-soft)] mb-2 truncate" dir="ltr" x-text="surah.englishName"></p>

                        {{-- Type Badge --}}
                        <span class="inline-block text-xs px-2 py-0.5 rounded-full font-medium"
                              :class="surah.revelationType === 'Meccan'
                                  ? 'bg-[color-mix(in_srgb,var(--gold)_18%,transparent)] text-[var(--gold)] border border-[color-mix(in_srgb,var(--gold)_30%,transparent)]'
                                  : 'bg-[var(--primary-soft)] text-[var(--primary)] border border-[color-mix(in_srgb,var(--primary)_30%,transparent)]'"
                              x-text="surah.revelationType === 'Meccan' ? 'مكية' : 'مدنية'"></span>

                        {{-- Ayah Count --}}
                        <p class="text-xs text-[var(--text-soft)] mt-1.5" x-text="surah.numberOfAyahs + ' آية'"></p>
                    </button>
                </template>

                {{-- Empty state --}}
                <div x-show="filteredSurahs.length === 0" class="col-span-full text-center py-16 text-[var(--text-soft)]">
                    <iconify-icon icon="solar:book-minimalistic-linear" class="text-5xl mb-3 block"></iconify-icon>
                    <p>لا توجد نتائج للبحث</p>
                </div>
            </div>
        </div>
    </div>

    {{-- ═══════════════════════════════════════════════════
         SURAH READING VIEW
    ═══════════════════════════════════════════════════ --}}
    <div x-show="selectedSurah" x-cloak
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         class="pt-16">

        {{-- Sticky Reading Bar --}}
        <div class="sticky top-24 z-30 bg-[color-mix(in_srgb,var(--surface)_92%,transparent)] border-b border-[var(--border)] shadow-[var(--shadow)] backdrop-blur-xl">
            <div class="max-w-4xl mx-auto px-4 py-3 flex items-center justify-between gap-4">

                {{-- Back --}}
                <button @click="selectedSurah = null; ayahs = []"
                        class="flex items-center gap-2 px-4 py-2 rounded-xl bg-[var(--surface-2)] border border-[var(--border)] hover:bg-[var(--surface)] transition-all duration-200 text-[var(--text)] font-bold text-sm shrink-0 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                    <iconify-icon icon="solar:arrow-right-bold" class="text-base"></iconify-icon>
                    <span class="hidden sm:inline">العودة</span>
                </button>

                {{-- Surah Name --}}
                <div class="text-center min-w-0">
                    <h2 class="font-bold text-[var(--text)] truncate"
                        style="font-family:'Amiri',serif;font-size:1.25rem;"
                        x-text="surahs.find(s => s.number === selectedSurah)?.name || ''"></h2>
                    <p class="text-xs text-[var(--text-soft)]"
                       x-text="(surahs.find(s => s.number === selectedSurah)?.numberOfAyahs || '') + ' آية  •  سورة ' + (selectedSurah || '')"></p>
                </div>

                {{-- Font Controls --}}
                <div class="flex items-center gap-2 shrink-0">

                    {{-- Font Picker --}}
                    <div class="relative">
                        <button @click="showFontMenu = !showFontMenu"
                                @click.away="showFontMenu = false"
                                class="flex items-center gap-1.5 h-9 px-3 rounded-xl bg-[var(--surface-2)] border border-[var(--border)] hover:bg-[var(--surface)] transition-all duration-200 text-xs font-bold text-[var(--text)] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                            <template x-if="fontLoading">
                                <span class="w-3 h-3 border-2 border-[var(--primary)] border-t-transparent rounded-full animate-spin block"></span>
                            </template>
                            <template x-if="!fontLoading">
                                <iconify-icon icon="solar:text-field-focus-bold" class="text-[var(--primary)] text-base"></iconify-icon>
                            </template>
                            <span class="hidden sm:inline max-w-[80px] truncate" x-text="selectedFont.name"></span>
                            <iconify-icon icon="solar:alt-arrow-down-bold" class="text-[var(--text-soft)] text-xs"></iconify-icon>
                        </button>

                        {{-- Dropdown Menu --}}
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

                    {{-- Font Size --}}
                    <button @click="fontSize = Math.max(fontSize - 2, 22)"
                            class="w-9 h-9 rounded-xl bg-[var(--surface-2)] border border-[var(--border)] hover:bg-[var(--surface)] flex items-center justify-center transition-all duration-200 text-[var(--text-muted)] text-lg font-bold active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        −
                    </button>
                    <span class="text-xs font-bold text-[var(--text-soft)] w-10 text-center" x-text="fontSize + 'px'"></span>
                    <button @click="fontSize = Math.min(fontSize + 2, 56)"
                            class="w-9 h-9 rounded-xl bg-[var(--surface-2)] border border-[var(--border)] hover:bg-[var(--surface)] flex items-center justify-center transition-all duration-200 text-[var(--text-muted)] text-lg font-bold active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)]">
                        +
                    </button>
                </div>
            </div>
        </div>

        {{-- Loading --}}
        <div x-show="loading" class="min-h-[60vh] flex items-center justify-center">
            <div class="text-center">
                <div class="w-14 h-14 rounded-full border-4 border-[color-mix(in_srgb,var(--primary)_20%,transparent)] border-t-[var(--primary)] animate-spin mx-auto mb-4"></div>
                <p class="text-[var(--text-muted)]">جارٍ تحميل السورة...</p>
            </div>
        </div>

        {{-- Surah Error State --}}
        <div x-show="!loading && surahError" class="min-h-[60vh] flex items-center justify-center px-4">
            <div class="text-center">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4 bg-[color-mix(in_srgb,var(--danger)_18%,transparent)]">
                    <iconify-icon icon="solar:cloud-cross-bold" class="text-3xl text-[var(--danger)]"></iconify-icon>
                </div>
                <h3 class="font-bold text-[var(--text)] text-lg mb-1">تعذّر تحميل السورة</h3>
                <p class="text-[var(--text-soft)] text-sm mb-5">تحقق من اتصالك بالإنترنت ثم حاول مجدداً</p>
                <button @click="selectSurah(selectedSurah)"
                        class="flex items-center gap-2 px-6 py-2.5 rounded-2xl font-bold text-sm text-white mx-auto transition-all duration-200 hover:brightness-110 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] bg-[var(--primary)]">
                    <iconify-icon icon="solar:refresh-bold"></iconify-icon>
                    إعادة المحاولة
                </button>
            </div>
        </div>

        {{-- Surah Content --}}
        <div x-show="!loading && !surahError" class="max-w-4xl mx-auto px-4 py-10 pb-24">

            {{-- Surah Title Block --}}
            <div class="text-center mb-10">
                {{-- Basmala --}}
                <div x-show="selectedSurah !== 9 && selectedSurah !== 1" class="mb-2">
                    <p class="text-[var(--text)]"
                       style="font-family:'Amiri',serif;font-size:2.2rem;line-height:2.2;">
                        بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
                    </p>
                    <div class="flex items-center justify-center gap-3 opacity-50 mt-1">
                        <div class="h-px w-24 bg-[var(--border-strong)]"></div>
                        <iconify-icon icon="solar:star-fall-bold" class="text-[var(--gold)] text-sm"></iconify-icon>
                        <div class="h-px w-24 bg-[var(--border-strong)]"></div>
                    </div>
                </div>
            </div>

            {{-- Mushaf Text --}}
            <div class="rounded-3xl p-6 sm:p-10 md:p-14 shadow-[var(--shadow)] bg-[var(--surface-2)] border border-[var(--border)]">

                <div class="text-[var(--text)] leading-loose text-justify"
                     :style="'font-family:\'' + selectedFont.cssFamily + '\',\'Amiri\',serif;font-size:' + fontSize + 'px;line-height:2.5;'"
                     dir="rtl">
                    <template x-for="ayah in ayahs" :key="ayah.numberInSurah">
                        <span>
                            <span x-text="ayah.text"></span><span class="inline-flex items-center justify-center rounded-full text-white mx-1.5 font-bold bg-[var(--primary)] border border-[color-mix(in_srgb,var(--primary)_35%,transparent)]"
                                  style="font-family:'Readex Pro',sans-serif;vertical-align:middle;width:1.6em;height:1.6em;font-size:.55em;"
                                  x-text="ayah.numberInSurah"></span>
                        </span>
                    </template>
                </div>
            </div>

            {{-- Surah Navigation --}}
            <div class="flex items-center justify-between mt-8 gap-3">

                {{-- Previous Surah --}}
                <button @click="navigateSurah('prev')" :disabled="selectedSurah <= 1"
                        class="flex items-center gap-3 flex-1 px-5 py-4 bg-[var(--surface)] border border-[var(--border)] rounded-2xl shadow-[var(--shadow)] hover:shadow-lg hover:border-[var(--primary)] transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed text-right focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)]">
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 bg-[var(--primary-soft)] border border-[color-mix(in_srgb,var(--primary)_35%,transparent)] text-[var(--primary)]">
                        <iconify-icon icon="solar:arrow-right-bold" class="text-xl"></iconify-icon>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs text-[var(--text-soft)] mb-0.5">السابقة</p>
                        <p class="font-bold text-[var(--text)] text-sm truncate"
                           style="font-family:'Amiri',serif;"
                           x-text="selectedSurah > 1 ? (surahs[selectedSurah - 2]?.name || '') : ''"></p>
                    </div>
                </button>

                {{-- Counter --}}
                <div class="text-center px-4 shrink-0">
                    <p class="text-sm font-bold text-[var(--text-muted)]" x-text="selectedSurah + ' / 114'"></p>
                </div>

                {{-- Next Surah --}}
                <button @click="navigateSurah('next')" :disabled="selectedSurah >= 114"
                        class="flex items-center gap-3 flex-1 px-5 py-4 bg-[var(--surface)] border border-[var(--border)] rounded-2xl shadow-[var(--shadow)] hover:shadow-lg hover:border-[var(--primary)] transition-all duration-200 disabled:opacity-40 disabled:cursor-not-allowed text-left justify-end focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--primary)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--bg)]">
                    <div class="min-w-0 text-right">
                        <p class="text-xs text-[var(--text-soft)] mb-0.5">التالية</p>
                        <p class="font-bold text-[var(--text)] text-sm truncate"
                           style="font-family:'Amiri',serif;"
                           x-text="selectedSurah < 114 ? (surahs[selectedSurah]?.name || '') : ''"></p>
                    </div>
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 bg-[var(--primary-soft)] border border-[color-mix(in_srgb,var(--primary)_35%,transparent)] text-[var(--primary)]">
                        <iconify-icon icon="solar:arrow-left-bold" class="text-xl"></iconify-icon>
                    </div>
                </button>
            </div>
        </div>
    </div>
</div>

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

@keyframes spin { to { transform: rotate(360deg); } }
</style>

<script>
// ── Available Quran Fonts ────────────────────────────────────────────────────
const QURAN_FONTS = [
    {
        key: 'default',
        name: 'الخط الافتراضي (أميري)',
        cssFamily: 'Amiri',
        woff2: null, // already loaded via Google Fonts / local
    },
    {
        key: 'quran_madina',
        name: 'مصحف المدينة',
        cssFamily: 'QuranMadina',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/maddina.woff2',
    },
    {
        key: 'kfgqpc_hafs',
        name: 'مجمع الملك فهد - حفص',
        cssFamily: 'KFGQPCHafs',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/hafs-uthmanic-v14-full.woff2',
    },
    {
        key: 'kfgqpc_warsh',
        name: 'مجمع الملك فهد - ورش',
        cssFamily: 'KFGQPCWarsh',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/warsh-v8-full.woff2',
    },
    {
        key: 'kfgqpc_qaloon',
        name: 'مجمع الملك فهد - قالون',
        cssFamily: 'KFGQPCQaloon',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qaloon-v8-full.woff2',
    },
    {
        key: 'kfgqpc_doori',
        name: 'مجمع الملك فهد - الدوري',
        cssFamily: 'KFGQPCDoori',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/doori-v8-full.woff2',
    },
    {
        key: 'amiri_quran',
        name: 'الخط الأميري القرآني',
        cssFamily: 'AmiriQuran',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/amiri-quran-full.woff2',
    },
    {
        key: 'al_qalam_majeed',
        name: 'خط القلم - قرآن مجيد',
        cssFamily: 'AlQalamMajeed',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/al-qalam-quran-majeed.woff2',
    },
    {
        key: 'al_mushaf',
        name: 'خط المصحف',
        cssFamily: 'AlMushaf',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/almushaf.woff2',
    },
    {
        key: 'quran_standard',
        name: 'خط القرآن المعياري',
        cssFamily: 'QuranStandard',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/qur-std.woff2',
    },
    {
        key: 'noorehuda',
        name: 'خط نور الهدى - نسخ',
        cssFamily: 'NoorehudaNaskh',
        woff2: 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/fonts/noorehuda-regular.woff2',
    },
];

// tracks which font families have already been injected into the page
const _loadedFontFamilies = new Set(['Amiri']);

function quranTextApp() {
    const savedFontKey = localStorage.getItem('quran_font_key') || 'default';
    const initialFont = QURAN_FONTS.find(f => f.key === savedFontKey) || QURAN_FONTS[0];

    return {
        selectedSurah: null,
        ayahs: [],
        loading: false,
        loadError: false,
        surahError: false,
        fontSize: 34,
        surahs: [],
        searchQuery: '',
        availableFonts: QURAN_FONTS,
        selectedFont: initialFont,
        fontLoading: false,
        showFontMenu: false,

        get filteredSurahs() {
            if (!this.searchQuery.trim()) return this.surahs;
            const q = this.searchQuery.trim();
            return this.surahs.filter(s =>
                s.name.includes(q) || s.englishName.toLowerCase().includes(q.toLowerCase())
            );
        },

        async init() {
            // Restore saved font on page load
            if (initialFont.woff2 && !_loadedFontFamilies.has(initialFont.cssFamily)) {
                await this._injectFontFace(initialFont);
            }
            await this.loadSurahs();
        },

        async applyFont(font) {
            if (font.key === this.selectedFont.key) return;
            if (font.woff2 && !_loadedFontFamilies.has(font.cssFamily)) {
                this.fontLoading = true;
                try {
                    await this._injectFontFace(font);
                } catch (e) {
                    console.error('Font load failed:', e);
                } finally {
                    this.fontLoading = false;
                }
            }
            this.selectedFont = font;
            localStorage.setItem('quran_font_key', font.key);
        },

        async _injectFontFace(font) {
            // Create a <style> tag with the @font-face rule
            const style = document.createElement('style');
            style.textContent = `@font-face { font-family: '${font.cssFamily}'; src: url('${font.woff2}') format('woff2'); font-display: swap; }`;
            document.head.appendChild(style);

            // Force the browser to load the font before we switch
            await document.fonts.load(`1rem '${font.cssFamily}'`);
            _loadedFontFamilies.add(font.cssFamily);
        },

        async loadSurahs() {
            try {
                const response = await fetch('https://api.quran.com/api/v4/chapters?language=ar');
                const data = await response.json();
                this.surahs = data.chapters.map(c => ({
                    number: c.id,
                    name: c.name_arabic,
                    englishName: c.name_simple,
                    numberOfAyahs: c.verses_count,
                    revelationType: c.revelation_place === 'makkah' ? 'Meccan' : 'Medinan',
                }));
            } catch (error) {
                console.error('Error loading surahs:', error);
                this.loadError = true;
            }
        },

        async selectSurah(number) {
            this.selectedSurah = number;
            this.loading = true;
            this.surahError = false;
            this.ayahs = [];
            window.scrollTo({ top: 0, behavior: 'smooth' });

            try {
                const response = await fetch(
                    `https://api.quran.com/api/v4/verses/by_chapter/${number}` +
                    `?language=ar&words=false&per_page=300&fields=text_uthmani`
                );
                const data = await response.json();

                if (data.verses) {
                    this.ayahs = data.verses.map(v => ({
                        numberInSurah: v.verse_number,
                        text: v.text_uthmani,
                    }));
                }
            } catch (error) {
                console.error('Error loading surah:', error);
                this.surahError = true;
            } finally {
                this.loading = false;
            }
        },

        navigateSurah(direction) {
            if (direction === 'next' && this.selectedSurah < 114) {
                this.selectSurah(this.selectedSurah + 1);
            } else if (direction === 'prev' && this.selectedSurah > 1) {
                this.selectSurah(this.selectedSurah - 1);
            }
        },
    };
}
</script>
@endsection
