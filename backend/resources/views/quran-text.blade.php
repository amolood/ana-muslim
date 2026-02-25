@extends('layouts.web')

@section('content')
<div x-data="quranTextApp()" x-init="init()" class="pt-24 pb-12 px-4 sm:px-6 lg:px-8 max-w-7xl mx-auto">

    {{-- Font Size Control (Floating) --}}
    <div class="fixed bottom-24 left-4 z-40 glass-panel rounded-2xl p-3 shadow-xl">
        <div class="flex flex-col items-center gap-3">
            <button @click="fontSize = Math.min(fontSize + 2, 48)"
                    class="w-10 h-10 rounded-full bg-primary/10 hover:bg-primary/20 flex items-center justify-center transition-all">
                <iconify-icon icon="solar:add-circle-bold" class="text-2xl text-primary"></iconify-icon>
            </button>
            <span class="text-xs font-bold text-slate-600 dark:text-slate-400" x-text="fontSize + 'px'"></span>
            <button @click="fontSize = Math.max(fontSize - 2, 20)"
                    class="w-10 h-10 rounded-full bg-primary/10 hover:bg-primary/20 flex items-center justify-center transition-all">
                <iconify-icon icon="solar:minus-circle-bold" class="text-2xl text-primary"></iconify-icon>
            </button>
        </div>
    </div>

    {{-- Surahs Grid View --}}
    <div x-show="!selectedSurah" x-transition>
        <div class="mb-8 text-center">
            <h1 class="text-4xl font-bold text-slate-900 dark:text-white mb-3" x-text="t('quran.title')"></h1>
            <p class="text-slate-600 dark:text-slate-400" x-text="t('quran.subtitle')"></p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            <template x-for="surah in surahs" :key="surah.number">
                <button @click="selectSurah(surah.number)"
                        class="glass-panel p-6 rounded-2xl text-right hover:scale-105 transition-all group">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-lg"
                              x-text="surah.number"></span>
                        <span class="text-xs text-slate-500 dark:text-slate-400" x-text="surah.englishName"></span>
                    </div>
                    <h3 class="text-2xl font-bold text-slate-900 dark:text-white mb-2 font-arabic" x-text="surah.name"></h3>
                    <p class="text-sm text-slate-600 dark:text-slate-400"
                       x-text="surah.revelationType === 'Meccan' ? t('quran.meccan') : t('quran.medinan')"></p>
                    <p class="text-sm text-slate-500 dark:text-slate-500" x-text="surah.numberOfAyahs + ' ' + t('quran.ayahs')"></p>
                </button>
            </template>
        </div>
    </div>

    {{-- Surah Reading View --}}
    <div x-show="selectedSurah" x-transition>
        {{-- Back Button --}}
        <button @click="selectedSurah = null; ayahs = []"
                class="mb-6 glass-panel px-4 py-2 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 transition-all inline-flex items-center gap-2">
            <iconify-icon icon="solar:arrow-left-bold" class="text-xl"></iconify-icon>
            <span x-text="t('common.back')"></span>
        </button>

        {{-- Surah Container --}}
        <div class="glass-panel rounded-3xl p-8 md:p-12" style="background: linear-gradient(135deg, #fdfbf7 0%, #f9f6f0 100%);"
             :class="{'dark:bg-gradient-to-br dark:from-slate-900 dark:to-slate-800': true}">

            {{-- Loading State --}}
            <div x-show="loading" class="text-center py-20">
                <div class="loading-spinner mx-auto mb-4"></div>
                <p class="text-slate-600 dark:text-slate-400" x-text="t('common.loading')"></p>
            </div>

            {{-- Surah Content --}}
            <div x-show="!loading">
                {{-- Surah Header --}}
                <div class="text-center mb-8 pb-6 border-b-2 border-slate-200 dark:border-slate-700">
                    <h2 class="text-4xl font-bold text-slate-900 dark:text-white font-arabic mb-2"
                        x-text="'سورة ' + (selectedSurah ? surahs.find(s => s.number === selectedSurah)?.name : '')"></h2>
                    <p class="text-sm text-slate-600 dark:text-slate-400"
                       x-text="selectedSurah ? surahs.find(s => s.number === selectedSurah)?.englishName : ''"></p>
                </div>

                {{-- Basmala --}}
                <div x-show="selectedSurah !== 9 && selectedSurah !== 1"
                     class="text-center text-4xl font-arabic text-slate-800 dark:text-slate-200 mb-12"
                     style="font-family: 'Amiri Quran', serif;">
                    بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
                </div>

                {{-- Ayahs --}}
                <div class="space-y-6">
                    <template x-for="ayah in ayahs" :key="ayah.numberInSurah">
                        <div class="group relative p-6 rounded-2xl hover:bg-white/50 dark:hover:bg-slate-700/30 transition-all">
                            <div class="flex items-start gap-4">
                                {{-- Ayah Number Badge --}}
                                <div class="flex-shrink-0 w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">
                                    <span x-text="ayah.numberInSurah"></span>
                                </div>

                                {{-- Ayah Text --}}
                                <div class="flex-1">
                                    <p class="font-arabic text-slate-900 dark:text-slate-100 leading-loose text-justify"
                                       :style="'font-size: ' + fontSize + 'px; line-height: 2.2;'"
                                       style="font-family: 'Amiri Quran', serif;"
                                       x-html="ayah.text"></p>

                                    {{-- Translation (if available) --}}
                                    <p x-show="ayah.translation"
                                       class="mt-4 text-slate-600 dark:text-slate-400 text-sm leading-relaxed"
                                       x-text="ayah.translation"></p>
                                </div>

                                {{-- Actions --}}
                                <div class="flex-shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button @click="copyAyah(ayah)"
                                            class="w-10 h-10 rounded-full bg-slate-100 dark:bg-slate-700 hover:bg-primary/10 flex items-center justify-center transition-all"
                                            title="نسخ">
                                        <iconify-icon icon="solar:copy-bold" class="text-xl"></iconify-icon>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </template>
                </div>
            </div>
        </div>
    </div>
</div>

{{-- Loading Spinner CSS --}}
<style>
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
</style>

{{-- Alpine.js Component --}}
<script>
function quranTextApp() {
    return {
        ...i18n(),
        selectedSurah: null,
        ayahs: [],
        loading: false,
        fontSize: 34,
        surahs: [],

        async init() {
            await this.loadSurahs();
        },

        async loadSurahs() {
            try {
                const response = await fetch('https://api.alquran.cloud/v1/meta');
                const data = await response.json();
                this.surahs = data.data.surahs.references;
            } catch (error) {
                console.error('Error loading surahs:', error);
            }
        },

        async selectSurah(number) {
            this.selectedSurah = number;
            this.loading = true;
            this.ayahs = [];

            try {
                const response = await fetch(`https://api.alquran.cloud/v1/surah/${number}/quran-uthmani`);
                const data = await response.json();

                if (data.code === 200) {
                    this.ayahs = data.data.ayahs;
                }
            } catch (error) {
                console.error('Error loading surah:', error);
            } finally {
                this.loading = false;
            }
        },

        copyAyah(ayah) {
            const surah = this.surahs.find(s => s.number === this.selectedSurah);
            const text = `${ayah.text}\n\n(${surah.name} - آية ${ayah.numberInSurah})`;
            navigator.clipboard.writeText(text);

            // Show notification
            alert(this.t('common.copied'));
        },

        t(key) {
            const translations = {
                ar: {
                    quran: {
                        title: 'القرآن الكريم',
                        subtitle: 'اختر السورة التي تريد قراءتها',
                        meccan: 'مكية',
                        medinan: 'مدنية',
                        ayahs: 'آية'
                    },
                    common: {
                        loading: 'جاري التحميل...',
                        back: 'رجوع',
                        copied: 'تم النسخ!'
                    }
                },
                en: {
                    quran: {
                        title: 'Holy Quran',
                        subtitle: 'Choose the surah you want to read',
                        meccan: 'Meccan',
                        medinan: 'Medinan',
                        ayahs: 'verses'
                    },
                    common: {
                        loading: 'Loading...',
                        back: 'Back',
                        copied: 'Copied!'
                    }
                }
            };

            return key.split('.').reduce((o, i) => o[i], translations[this.locale]);
        }
    }
}
</script>
@endsection
