@extends('layouts.web')

@section('content')
<div x-data="quranTextApp()" x-init="init()" dir="rtl">

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
                <div class="absolute top-16 right-1/3 w-80 h-80 rounded-full blur-3xl opacity-10" style="background:#11D4B4;"></div>
            </div>
            <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-bold mb-5" style="background:rgba(17,212,180,.1);color:#11D4B4;">
                <iconify-icon icon="solar:book-2-bold"></iconify-icon>
                القرآن الكريم
            </div>
            <h1 class="text-5xl font-bold text-slate-900 dark:text-white mb-3" style="font-family:'Amiri',serif;">
                القرآن الكريم
            </h1>
            <p class="text-slate-500 dark:text-slate-400 text-lg">اختر سورة للقراءة</p>
        </div>

        {{-- Search Bar --}}
        <div class="px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto mb-8">
            <div class="relative max-w-sm mx-auto">
                <iconify-icon icon="solar:magnifer-linear" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xl pointer-events-none"></iconify-icon>
                <input type="text" x-model="searchQuery"
                       placeholder="ابحث عن سورة..."
                       class="w-full bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-2xl py-3 pr-12 pl-4 text-slate-900 dark:text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#11D4B4]/50 focus:border-[#11D4B4] transition-all shadow-sm">
            </div>
        </div>

        {{-- Load Error State --}}
        <div x-show="loadError" class="px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto mb-8">
            <div class="flex flex-col items-center justify-center py-16 text-center">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center mb-4" style="background:rgba(239,68,68,.1);">
                    <iconify-icon icon="solar:wifi-router-minimalistic-bold" class="text-3xl" style="color:#ef4444;"></iconify-icon>
                </div>
                <h3 class="font-bold text-slate-800 dark:text-white text-lg mb-1">تعذّر تحميل القرآن</h3>
                <p class="text-slate-400 dark:text-slate-500 text-sm mb-5">تحقق من اتصالك بالإنترنت ثم حاول مجدداً</p>
                <button @click="loadError = false; loadSurahs()"
                        class="flex items-center gap-2 px-6 py-2.5 rounded-2xl font-bold text-sm text-white transition-all hover:opacity-90"
                        style="background:linear-gradient(135deg,#11D4B4,#0d9e87);">
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
                            class="group glass-panel rounded-2xl p-4 text-center hover:shadow-lg transition-all duration-300 hover:-translate-y-1 border border-transparent hover:border-[#11D4B4]/30 focus:outline-none focus:ring-2 focus:ring-[#11D4B4]/40">

                        {{-- Number Badge --}}
                        <div class="w-11 h-11 rounded-full mx-auto mb-3 flex items-center justify-center font-bold text-sm shadow-md"
                             style="background:#1e293b;color:#e2e8f0;letter-spacing:0.02em;"
                             x-text="surah.number"></div>

                        {{-- Arabic Name --}}
                        <h3 class="font-bold text-slate-900 dark:text-white text-xl leading-tight mb-1"
                            style="font-family:'Amiri',serif;"
                            x-text="surah.name"></h3>

                        {{-- English Name --}}
                        <p class="text-xs text-slate-400 dark:text-slate-500 mb-2 truncate" dir="ltr" x-text="surah.englishName"></p>

                        {{-- Type Badge --}}
                        <span class="inline-block text-xs px-2 py-0.5 rounded-full font-medium"
                              :class="surah.revelationType === 'Meccan'
                                  ? 'bg-amber-50 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400'
                                  : 'bg-emerald-50 text-emerald-700 dark:bg-emerald-900/20 dark:text-emerald-400'"
                              x-text="surah.revelationType === 'Meccan' ? 'مكية' : 'مدنية'"></span>

                        {{-- Ayah Count --}}
                        <p class="text-xs text-slate-400 dark:text-slate-500 mt-1.5" x-text="surah.numberOfAyahs + ' آية'"></p>
                    </button>
                </template>

                {{-- Empty state --}}
                <div x-show="filteredSurahs.length === 0" class="col-span-full text-center py-16 text-slate-400 dark:text-slate-500">
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
        <div class="sticky top-24 z-30 glass-panel border-b border-slate-200/60 dark:border-slate-700/60 shadow-sm">
            <div class="max-w-4xl mx-auto px-4 py-3 flex items-center justify-between gap-4">

                {{-- Back --}}
                <button @click="selectedSurah = null; ayahs = []"
                        class="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all text-slate-700 dark:text-slate-300 font-bold text-sm shrink-0">
                    <iconify-icon icon="solar:arrow-right-bold" class="text-base"></iconify-icon>
                    <span class="hidden sm:inline">العودة</span>
                </button>

                {{-- Surah Name --}}
                <div class="text-center min-w-0">
                    <h2 class="font-bold text-slate-900 dark:text-white truncate"
                        style="font-family:'Amiri',serif;font-size:1.25rem;"
                        x-text="surahs.find(s => s.number === selectedSurah)?.name || ''"></h2>
                    <p class="text-xs text-slate-400"
                       x-text="(surahs.find(s => s.number === selectedSurah)?.numberOfAyahs || '') + ' آية  •  سورة ' + (selectedSurah || '')"></p>
                </div>

                {{-- Font Size --}}
                <div class="flex items-center gap-1 shrink-0">
                    <button @click="fontSize = Math.max(fontSize - 2, 22)"
                            class="w-9 h-9 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 flex items-center justify-center transition-all text-slate-600 dark:text-slate-400 text-lg font-bold">
                        −
                    </button>
                    <span class="text-xs font-bold text-slate-500 w-10 text-center" x-text="fontSize + 'px'"></span>
                    <button @click="fontSize = Math.min(fontSize + 2, 56)"
                            class="w-9 h-9 rounded-xl bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 flex items-center justify-center transition-all text-slate-600 dark:text-slate-400 text-lg font-bold">
                        +
                    </button>
                </div>
            </div>
        </div>

        {{-- Loading --}}
        <div x-show="loading" class="min-h-[60vh] flex items-center justify-center">
            <div class="text-center">
                <div class="w-14 h-14 rounded-full border-4 border-[#11D4B4]/20 mx-auto mb-4"
                     style="border-top-color:#11D4B4;animation:spin 1s linear infinite;"></div>
                <p class="text-slate-500 dark:text-slate-400">جارٍ تحميل السورة...</p>
            </div>
        </div>

        {{-- Surah Error State --}}
        <div x-show="!loading && surahError" class="min-h-[60vh] flex items-center justify-center px-4">
            <div class="text-center">
                <div class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4" style="background:rgba(239,68,68,.1);">
                    <iconify-icon icon="solar:cloud-cross-bold" class="text-3xl" style="color:#ef4444;"></iconify-icon>
                </div>
                <h3 class="font-bold text-slate-800 dark:text-white text-lg mb-1">تعذّر تحميل السورة</h3>
                <p class="text-slate-400 dark:text-slate-500 text-sm mb-5">تحقق من اتصالك بالإنترنت ثم حاول مجدداً</p>
                <button @click="selectSurah(selectedSurah)"
                        class="flex items-center gap-2 px-6 py-2.5 rounded-2xl font-bold text-sm text-white mx-auto transition-all hover:opacity-90"
                        style="background:linear-gradient(135deg,#11D4B4,#0d9e87);">
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
                    <p class="text-slate-800 dark:text-slate-200"
                       style="font-family:'Amiri',serif;font-size:2.2rem;line-height:2.2;">
                        بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
                    </p>
                    <div class="flex items-center justify-center gap-3 opacity-30 mt-1">
                        <div class="h-px w-24 bg-slate-400"></div>
                        <iconify-icon icon="solar:star-fall-bold" class="text-amber-500 text-sm"></iconify-icon>
                        <div class="h-px w-24 bg-slate-400"></div>
                    </div>
                </div>
            </div>

            {{-- Mushaf Text --}}
            <div class="rounded-3xl p-6 sm:p-10 md:p-14 shadow-sm"
                 style="background:linear-gradient(160deg,#fdfbf7 0%,#f7f3eb 100%);border:1px solid rgba(0,0,0,.06);">

                <div class="dark:hidden text-slate-900 leading-loose text-justify"
                     :style="'font-family:\'Amiri\',serif;font-size:' + fontSize + 'px;line-height:2.5;'"
                     dir="rtl">
                    <template x-for="ayah in ayahs" :key="ayah.numberInSurah">
                        <span>
                            <span x-text="ayah.text"></span><span class="inline-flex items-center justify-center rounded-full text-white mx-1.5 font-bold"
                                  style="background:linear-gradient(135deg,#11D4B4,#0d9e87);font-family:'Readex Pro',sans-serif;vertical-align:middle;width:1.6em;height:1.6em;font-size:.55em;"
                                  x-text="ayah.numberInSurah"></span>
                        </span>
                    </template>
                </div>

                <div class="hidden dark:block text-slate-100 leading-loose text-justify"
                     :style="'font-family:\'Amiri\',serif;font-size:' + fontSize + 'px;line-height:2.5;'"
                     dir="rtl"
                     style="background:transparent;">
                    <template x-for="ayah in ayahs" :key="'dk-' + ayah.numberInSurah">
                        <span>
                            <span x-text="ayah.text"></span><span class="inline-flex items-center justify-center rounded-full text-white mx-1.5 font-bold"
                                  style="background:linear-gradient(135deg,#11D4B4,#0d9e87);font-family:'Readex Pro',sans-serif;vertical-align:middle;width:1.6em;height:1.6em;font-size:.55em;"
                                  x-text="ayah.numberInSurah"></span>
                        </span>
                    </template>
                </div>
            </div>

            {{-- Surah Navigation --}}
            <div class="flex items-center justify-between mt-8 gap-3">

                {{-- Previous Surah --}}
                <button @click="navigateSurah('prev')" :disabled="selectedSurah <= 1"
                        class="flex items-center gap-3 flex-1 px-5 py-4 glass-panel rounded-2xl hover:shadow-md transition-all disabled:opacity-40 disabled:cursor-not-allowed text-right">
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                         style="background:rgba(17,212,180,.1);">
                        <iconify-icon icon="solar:arrow-right-bold" class="text-xl" style="color:#11D4B4;"></iconify-icon>
                    </div>
                    <div class="min-w-0">
                        <p class="text-xs text-slate-400 mb-0.5">السابقة</p>
                        <p class="font-bold text-slate-800 dark:text-white text-sm truncate"
                           style="font-family:'Amiri',serif;"
                           x-text="selectedSurah > 1 ? (surahs[selectedSurah - 2]?.name || '') : ''"></p>
                    </div>
                </button>

                {{-- Counter --}}
                <div class="text-center px-4 shrink-0">
                    <p class="text-sm font-bold text-slate-500 dark:text-slate-400" x-text="selectedSurah + ' / 114'"></p>
                </div>

                {{-- Next Surah --}}
                <button @click="navigateSurah('next')" :disabled="selectedSurah >= 114"
                        class="flex items-center gap-3 flex-1 px-5 py-4 glass-panel rounded-2xl hover:shadow-md transition-all disabled:opacity-40 disabled:cursor-not-allowed text-left justify-end">
                    <div class="min-w-0 text-right">
                        <p class="text-xs text-slate-400 mb-0.5">التالية</p>
                        <p class="font-bold text-slate-800 dark:text-white text-sm truncate"
                           style="font-family:'Amiri',serif;"
                           x-text="selectedSurah < 114 ? (surahs[selectedSurah]?.name || '') : ''"></p>
                    </div>
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                         style="background:rgba(17,212,180,.1);">
                        <iconify-icon icon="solar:arrow-left-bold" class="text-xl" style="color:#11D4B4;"></iconify-icon>
                    </div>
                </button>
            </div>
        </div>
    </div>
</div>

<style>
@keyframes spin { to { transform: rotate(360deg); } }
</style>

<script>
function quranTextApp() {
    return {
        selectedSurah: null,
        ayahs: [],
        loading: false,
        loadError: false,
        surahError: false,
        fontSize: 34,
        surahs: [],
        searchQuery: '',

        get filteredSurahs() {
            if (!this.searchQuery.trim()) return this.surahs;
            const q = this.searchQuery.trim();
            return this.surahs.filter(s =>
                s.name.includes(q) || s.englishName.toLowerCase().includes(q.toLowerCase())
            );
        },

        async init() {
            await this.loadSurahs();
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
