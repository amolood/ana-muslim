<!DOCTYPE html>
<html lang="ar" dir="rtl" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>القرآن الكريم - نصي - أنا المسلم</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Amiri+Quran&family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['IBM Plex Sans Arabic', 'sans-serif'],
                        arabic: ['Amiri Quran', 'serif'],
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

        .glass-panel {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(0, 0, 0, 0.05);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.08);
        }

        .dark .glass-panel {
            background: rgba(15, 23, 42, 0.9);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.6);
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

        /* Mushaf Page Styling */
        .mushaf-page {
            background: linear-gradient(135deg, #fdfbf7 0%, #f9f6f0 100%);
            border: 3px solid #d4c5a9;
            box-shadow: 0 25px 70px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.9);
            position: relative;
        }

        .mushaf-page::before {
            content: '';
            position: absolute;
            inset: 12px;
            border: 1px solid rgba(212, 197, 169, 0.3);
            border-radius: 16px;
            pointer-events: none;
        }

        .dark .mushaf-page {
            background: linear-gradient(135deg, #1a1f2e 0%, #151923 100%);
            border: 3px solid #2d3748;
            box-shadow: 0 25px 70px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.05);
        }

        .dark .mushaf-page::before {
            border-color: rgba(45, 55, 72, 0.5);
        }

        .ayah-text {
            font-family: 'Amiri Quran', serif;
            font-size: 34px;
            line-height: 2.5;
            text-align: justify;
            color: #1a202c;
            text-shadow: 0 1px 2px rgba(0,0,0,0.02);
        }

        .dark .ayah-text {
            color: #f7fafc;
            text-shadow: 0 1px 3px rgba(0,0,0,0.3);
        }

        .ayah-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: linear-gradient(135deg, #11D4B4 0%, #0da88a 100%);
            color: white;
            font-size: 15px;
            font-weight: bold;
            margin: 0 10px;
            position: relative;
            top: 3px;
            box-shadow: 0 5px 15px rgba(17, 212, 180, 0.35);
        }

        .basmala {
            font-family: 'Amiri Quran', serif;
            font-size: 42px;
            text-align: center;
            color: #11D4B4;
            margin: 48px 0;
            text-shadow: 0 2px 8px rgba(17, 212, 180, 0.2);
        }

        .surah-header {
            text-align: center;
            padding: 32px;
            border-bottom: 4px solid #11D4B4;
            margin-bottom: 40px;
            position: relative;
        }

        .surah-header::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 50%;
            transform: translateX(-50%);
            width: 120px;
            height: 4px;
            background: linear-gradient(90deg, transparent, #11D4B4, transparent);
        }

        .loading-spinner {
            border: 4px solid rgba(17, 212, 180, 0.1);
            border-top-color: #11D4B4;
            border-radius: 50%;
            width: 48px;
            height: 48px;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Enhanced Audio Player */
        .audio-player-enhanced {
            background: linear-gradient(135deg, rgba(17, 212, 180, 0.12) 0%, rgba(17, 212, 180, 0.06) 100%);
            border: 2px solid rgba(17, 212, 180, 0.25);
            backdrop-filter: blur(12px);
        }

        .dark .audio-player-enhanced {
            background: linear-gradient(135deg, rgba(17, 212, 180, 0.15) 0%, rgba(17, 212, 180, 0.08) 100%);
            border-color: rgba(17, 212, 180, 0.3);
        }

        .play-button-large {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            background: linear-gradient(135deg, #11D4B4 0%, #0da88a 100%);
            box-shadow: 0 10px 28px rgba(17, 212, 180, 0.45);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .play-button-large:hover {
            transform: scale(1.08);
            box-shadow: 0 14px 38px rgba(17, 212, 180, 0.55);
        }

        .play-button-large:active {
            transform: scale(0.98);
        }

        .progress-bar-enhanced {
            height: 8px;
            background: rgba(17, 212, 180, 0.15);
            border-radius: 4px;
            overflow: hidden;
            cursor: pointer;
            transition: height 0.2s ease;
        }

        .progress-bar-enhanced:hover {
            height: 10px;
        }

        .progress-fill-enhanced {
            height: 100%;
            background: linear-gradient(90deg, #11D4B4 0%, #0da88a 100%);
            transition: width 0.1s linear;
            position: relative;
        }

        .progress-fill-enhanced::after {
            content: '';
            position: absolute;
            right: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 14px;
            height: 14px;
            background: white;
            border-radius: 50%;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }

        .translation-box {
            background: rgba(17, 212, 180, 0.06);
            border-right: 4px solid #11D4B4;
            padding: 24px;
            margin-top: 28px;
            border-radius: 14px;
            transition: all 0.3s ease;
        }

        .translation-box:hover {
            background: rgba(17, 212, 180, 0.09);
            box-shadow: 0 4px 16px rgba(17, 212, 180, 0.1);
        }

        .dark .translation-box {
            background: rgba(17, 212, 180, 0.12);
        }

        .dark .translation-box:hover {
            background: rgba(17, 212, 180, 0.16);
        }

        .surah-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .surah-card:hover {
            transform: translateY(-6px) scale(1.02);
            box-shadow: 0 16px 40px rgba(17, 212, 180, 0.2);
        }

        .reciter-dropdown {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease-out;
        }

        .reciter-dropdown.open {
            max-height: 200px;
        }
    </style>
</head>
<body
    x-data="quranTextApp()"
    x-init="init()"
    :dir="locale === 'ar' ? 'rtl' : 'ltr'"
    class="bg-[#F1F5F9] dark:bg-[#0B1121] text-slate-800 dark:text-slate-100 transition-colors duration-500 min-h-screen relative overflow-x-hidden selection:bg-primary/30">

    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <!-- Navbar -->
    @include('partials.web-navbar')

    <main class="max-w-7xl mx-auto px-4 pt-32 pb-20 relative z-10">

        <!-- Header with controls -->
        <div class="mb-8 flex flex-col gap-6">
            <div class="text-center">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-panel text-xs font-medium text-slate-700 dark:text-slate-300 mb-4">
                    <iconify-icon icon="solar:book-2-bold" class="text-primary"></iconify-icon>
                    <span x-text="t('badge')"></span>
                </div>
                <h1 class="text-5xl font-bold mb-3 text-slate-900 dark:text-white" x-text="t('title')"></h1>
                <p class="text-xl text-slate-600 dark:text-slate-400 max-w-2xl mx-auto" x-text="t('subtitle')"></p>
            </div>

            <!-- Controls Row -->
            <div x-show="view === 'ayahs'" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Translation selector -->
                <div>
                    <label class="block text-sm font-bold mb-2 text-slate-700 dark:text-slate-300" x-text="t('selectTranslation')"></label>
                    <select x-model="selectedTranslation" @change="loadSurah()"
                            class="w-full px-4 py-3 rounded-xl glass-panel text-sm font-medium text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary">
                        <option value="">بدون ترجمة</option>
                        <option value="en.sahih">English - Sahih International</option>
                        <option value="en.pickthall">English - Pickthall</option>
                        <option value="en.yusufali">English - Yusuf Ali</option>
                        <option value="fr.hamidullah">Français - Hamidullah</option>
                        <option value="de.bubenheim">Deutsch - Bubenheim</option>
                        <option value="es.cortes">Español - Julio Cortes</option>
                        <option value="tr.diyanet">Türkçe - Diyanet</option>
                        <option value="ur.jalandhry">اردو - جالندہری</option>
                        <option value="id.indonesian">Indonesia - Kementerian Agama</option>
                    </select>
                </div>

                <!-- Reciter selector -->
                <div>
                    <label class="block text-sm font-bold mb-2 text-slate-700 dark:text-slate-300" x-text="t('selectReciter')"></label>
                    <select x-model="selectedReciter" @change="changeReciter()"
                            class="w-full px-4 py-3 rounded-xl glass-panel text-sm font-medium text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary">
                        <template x-for="reciter in reciters" :key="reciter.id">
                            <option :value="reciter.id" x-text="reciter.name"></option>
                        </template>
                    </select>
                </div>
            </div>
        </div>

        <!-- Surahs Grid -->
        <div x-show="view === 'surahs'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 mb-8">
            <template x-for="i in 114" :key="i">
                <button @click="selectedSurah = i; view = 'ayahs'; loadSurah()"
                        class="surah-card glass-panel p-6 rounded-2xl text-right group">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-12 h-12 rounded-full bg-primary/10 dark:bg-primary/20 flex items-center justify-center text-primary font-bold text-lg" x-text="i"></span>
                        <span class="text-xs font-medium text-slate-500 dark:text-slate-400" x-text="getSurahName(i, 'en')"></span>
                    </div>
                    <h3 class="text-2xl font-bold text-slate-900 dark:text-white mb-2 font-quran" x-text="getSurahName(i, 'ar')"></h3>
                    <p class="text-sm text-slate-600 dark:text-slate-400" x-text="getSurahInfo(i)"></p>
                </button>
            </template>
        </div>

        <!-- Surah View (Mushaf Style) -->
        <div x-show="view === 'ayahs'" x-cloak>
            <!-- Back Button -->
            <button @click="view = 'surahs'; ayahs = []; stopAudio()" class="mb-8 flex items-center gap-2 text-primary hover:gap-3 transition-all font-bold">
                <iconify-icon icon="solar:alt-arrow-right-linear" class="text-2xl"></iconify-icon>
                <span x-text="t('backToSurahs')"></span>
            </button>

            <!-- Loading State -->
            <div x-show="loading" class="flex flex-col items-center justify-center py-24">
                <div class="loading-spinner"></div>
                <p class="mt-5 text-slate-600 dark:text-slate-400 text-lg font-medium" x-text="t('loading')"></p>
            </div>

            <!-- Enhanced Audio Player -->
            <div x-show="!loading && ayahs.length > 0" class="audio-player-enhanced glass-panel rounded-3xl p-8 mb-10">
                <div class="flex items-center gap-8">
                    <!-- Play/Pause Button -->
                    <button @click="toggleAudio()" class="play-button-large flex items-center justify-center text-white shrink-0">
                        <iconify-icon :icon="isPlaying ? 'solar:pause-bold' : 'solar:play-bold'" class="text-4xl"></iconify-icon>
                    </button>

                    <div class="flex-1">
                        <div class="flex items-center justify-between mb-3">
                            <div>
                                <span class="text-lg font-bold text-slate-900 dark:text-white font-quran" x-text="'سورة ' + getSurahName(selectedSurah, 'ar')"></span>
                                <p class="text-xs text-slate-600 dark:text-slate-400 mt-1" x-text="getReciterName(selectedReciter)"></p>
                            </div>
                            <span class="text-sm font-mono text-slate-600 dark:text-slate-400" x-text="currentTime + ' / ' + duration"></span>
                        </div>

                        <!-- Enhanced Progress Bar -->
                        <div class="progress-bar-enhanced" @click="seekAudio($event)">
                            <div class="progress-fill-enhanced" :style="'width: ' + progress + '%'"></div>
                        </div>

                        <!-- Volume and Speed Controls -->
                        <div class="flex items-center gap-4 mt-4">
                            <div class="flex items-center gap-2">
                                <iconify-icon icon="solar:volume-loud-bold" class="text-slate-600 dark:text-slate-400"></iconify-icon>
                                <input type="range" min="0" max="100" x-model="volume" @input="changeVolume()" class="w-20 h-1 bg-slate-200 dark:bg-slate-700 rounded-lg appearance-none cursor-pointer">
                            </div>
                            <button @click="toggleSpeed()" class="px-3 py-1 rounded-lg glass-panel text-xs font-bold text-slate-700 dark:text-slate-300 hover:text-primary transition-colors">
                                <span x-text="playbackSpeed + 'x'"></span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Mushaf Page -->
            <div x-show="!loading" class="mushaf-page rounded-3xl p-10 md:p-16">
                <!-- Surah Header -->
                <div class="surah-header">
                    <h2 class="text-4xl font-bold text-slate-900 dark:text-white font-quran" x-text="'سورة ' + getSurahName(selectedSurah, 'ar')"></h2>
                    <p class="text-sm text-slate-600 dark:text-slate-400 mt-3 font-medium" x-text="getSurahInfo(selectedSurah)"></p>
                </div>

                <!-- Basmala (except for At-Tawbah) -->
                <div x-show="selectedSurah !== 9 && selectedSurah !== 1" class="basmala">
                    بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ
                </div>

                <!-- Ayahs as continuous text -->
                <div class="ayah-text" dir="rtl">
                    <template x-for="(ayah, index) in ayahs" :key="ayah.number">
                        <span>
                            <span x-text="ayah.text"></span>
                            <span class="ayah-number" x-text="convertToArabicNumber(ayah.numberInSurah)"></span>
                            <span x-show="index < ayahs.length - 1"> </span>
                        </span>
                    </template>
                </div>

                <!-- Translation (if selected) -->
                <template x-if="selectedTranslation && ayahs.length > 0">
                    <div class="mt-12 space-y-5">
                        <h3 class="text-2xl font-bold text-slate-900 dark:text-white flex items-center gap-3">
                            <iconify-icon icon="solar:translation-bold" class="text-primary"></iconify-icon>
                            <span x-text="t('translation')"></span>
                        </h3>
                        <template x-for="ayah in ayahs" :key="'trans-' + ayah.number">
                            <div class="translation-box">
                                <div class="flex gap-4">
                                    <span class="shrink-0 font-bold text-primary text-lg" x-text="ayah.numberInSurah + '.'"></span>
                                    <p class="text-slate-700 dark:text-slate-300 leading-relaxed text-base"
                                       x-text="ayah.translation"
                                       :dir="locale === 'ar' ? 'rtl' : 'ltr'"></p>
                                </div>
                            </div>
                        </template>
                    </div>
                </template>
            </div>
        </div>
    </main>

    <!-- ✅ تعريف quranTextApp() قبل تحميل Alpine.js -->
    <script>
        const surahsData = [
            { ar: 'الفاتحة', en: 'Al-Fatihah', ayahs: 7, type: 'Meccan' },
            { ar: 'البقرة', en: 'Al-Baqarah', ayahs: 286, type: 'Medinan' },
            { ar: 'آل عمران', en: 'Aal-E-Imran', ayahs: 200, type: 'Medinan' },
            { ar: 'النساء', en: 'An-Nisa', ayahs: 176, type: 'Medinan' },
            { ar: 'المائدة', en: 'Al-Maidah', ayahs: 120, type: 'Medinan' },
            { ar: 'الأنعام', en: 'Al-Anaam', ayahs: 165, type: 'Meccan' },
            { ar: 'الأعراف', en: 'Al-Araf', ayahs: 206, type: 'Meccan' },
            { ar: 'الأنفال', en: 'Al-Anfal', ayahs: 75, type: 'Medinan' },
            { ar: 'التوبة', en: 'At-Tawbah', ayahs: 129, type: 'Medinan' },
            { ar: 'يونس', en: 'Yunus', ayahs: 109, type: 'Meccan' },
            { ar: 'هود', en: 'Hud', ayahs: 123, type: 'Meccan' },
            { ar: 'يوسف', en: 'Yusuf', ayahs: 111, type: 'Meccan' },
            { ar: 'الرعد', en: 'Ar-Rad', ayahs: 43, type: 'Medinan' },
            { ar: 'إبراهيم', en: 'Ibrahim', ayahs: 52, type: 'Meccan' },
            { ar: 'الحجر', en: 'Al-Hijr', ayahs: 99, type: 'Meccan' },
            { ar: 'النحل', en: 'An-Nahl', ayahs: 128, type: 'Meccan' },
            { ar: 'الإسراء', en: 'Al-Isra', ayahs: 111, type: 'Meccan' },
            { ar: 'الكهف', en: 'Al-Kahf', ayahs: 110, type: 'Meccan' },
            { ar: 'مريم', en: 'Maryam', ayahs: 98, type: 'Meccan' },
            { ar: 'طه', en: 'Taha', ayahs: 135, type: 'Meccan' },
            { ar: 'الأنبياء', en: 'Al-Anbiya', ayahs: 112, type: 'Meccan' },
            { ar: 'الحج', en: 'Al-Hajj', ayahs: 78, type: 'Medinan' },
            { ar: 'المؤمنون', en: 'Al-Muminun', ayahs: 118, type: 'Meccan' },
            { ar: 'النور', en: 'An-Nur', ayahs: 64, type: 'Medinan' },
            { ar: 'الفرقان', en: 'Al-Furqan', ayahs: 77, type: 'Meccan' },
            { ar: 'الشعراء', en: 'Ash-Shuara', ayahs: 227, type: 'Meccan' },
            { ar: 'النمل', en: 'An-Naml', ayahs: 93, type: 'Meccan' },
            { ar: 'القصص', en: 'Al-Qasas', ayahs: 88, type: 'Meccan' },
            { ar: 'العنكبوت', en: 'Al-Ankabut', ayahs: 69, type: 'Meccan' },
            { ar: 'الروم', en: 'Ar-Rum', ayahs: 60, type: 'Meccan' },
            { ar: 'لقمان', en: 'Luqman', ayahs: 34, type: 'Meccan' },
            { ar: 'السجدة', en: 'As-Sajdah', ayahs: 30, type: 'Meccan' },
            { ar: 'الأحزاب', en: 'Al-Ahzab', ayahs: 73, type: 'Medinan' },
            { ar: 'سبأ', en: 'Saba', ayahs: 54, type: 'Meccan' },
            { ar: 'فاطر', en: 'Fatir', ayahs: 45, type: 'Meccan' },
            { ar: 'يس', en: 'Ya-Sin', ayahs: 83, type: 'Meccan' },
            { ar: 'الصافات', en: 'As-Saffat', ayahs: 182, type: 'Meccan' },
            { ar: 'ص', en: 'Sad', ayahs: 88, type: 'Meccan' },
            { ar: 'الزمر', en: 'Az-Zumar', ayahs: 75, type: 'Meccan' },
            { ar: 'غافر', en: 'Ghafir', ayahs: 85, type: 'Meccan' },
            { ar: 'فصلت', en: 'Fussilat', ayahs: 54, type: 'Meccan' },
            { ar: 'الشورى', en: 'Ash-Shuraa', ayahs: 53, type: 'Meccan' },
            { ar: 'الزخرف', en: 'Az-Zukhruf', ayahs: 89, type: 'Meccan' },
            { ar: 'الدخان', en: 'Ad-Dukhan', ayahs: 59, type: 'Meccan' },
            { ar: 'الجاثية', en: 'Al-Jathiyah', ayahs: 37, type: 'Meccan' },
            { ar: 'الأحقاف', en: 'Al-Ahqaf', ayahs: 35, type: 'Meccan' },
            { ar: 'محمد', en: 'Muhammad', ayahs: 38, type: 'Medinan' },
            { ar: 'الفتح', en: 'Al-Fath', ayahs: 29, type: 'Medinan' },
            { ar: 'الحجرات', en: 'Al-Hujurat', ayahs: 18, type: 'Medinan' },
            { ar: 'ق', en: 'Qaf', ayahs: 45, type: 'Meccan' },
            { ar: 'الذاريات', en: 'Adh-Dhariyat', ayahs: 60, type: 'Meccan' },
            { ar: 'الطور', en: 'At-Tur', ayahs: 49, type: 'Meccan' },
            { ar: 'النجم', en: 'An-Najm', ayahs: 62, type: 'Meccan' },
            { ar: 'القمر', en: 'Al-Qamar', ayahs: 55, type: 'Meccan' },
            { ar: 'الرحمن', en: 'Ar-Rahman', ayahs: 78, type: 'Medinan' },
            { ar: 'الواقعة', en: 'Al-Waqiah', ayahs: 96, type: 'Meccan' },
            { ar: 'الحديد', en: 'Al-Hadid', ayahs: 29, type: 'Medinan' },
            { ar: 'المجادلة', en: 'Al-Mujadila', ayahs: 22, type: 'Medinan' },
            { ar: 'الحشر', en: 'Al-Hashr', ayahs: 24, type: 'Medinan' },
            { ar: 'الممتحنة', en: 'Al-Mumtahanah', ayahs: 13, type: 'Medinan' },
            { ar: 'الصف', en: 'As-Saf', ayahs: 14, type: 'Medinan' },
            { ar: 'الجمعة', en: 'Al-Jumuah', ayahs: 11, type: 'Medinan' },
            { ar: 'المنافقون', en: 'Al-Munafiqun', ayahs: 11, type: 'Medinan' },
            { ar: 'التغابن', en: 'At-Taghabun', ayahs: 18, type: 'Medinan' },
            { ar: 'الطلاق', en: 'At-Talaq', ayahs: 12, type: 'Medinan' },
            { ar: 'التحريم', en: 'At-Tahrim', ayahs: 12, type: 'Medinan' },
            { ar: 'الملك', en: 'Al-Mulk', ayahs: 30, type: 'Meccan' },
            { ar: 'القلم', en: 'Al-Qalam', ayahs: 52, type: 'Meccan' },
            { ar: 'الحاقة', en: 'Al-Haqqah', ayahs: 52, type: 'Meccan' },
            { ar: 'المعارج', en: 'Al-Maarij', ayahs: 44, type: 'Meccan' },
            { ar: 'نوح', en: 'Nuh', ayahs: 28, type: 'Meccan' },
            { ar: 'الجن', en: 'Al-Jinn', ayahs: 28, type: 'Meccan' },
            { ar: 'المزمل', en: 'Al-Muzzammil', ayahs: 20, type: 'Meccan' },
            { ar: 'المدثر', en: 'Al-Muddaththir', ayahs: 56, type: 'Meccan' },
            { ar: 'القيامة', en: 'Al-Qiyamah', ayahs: 40, type: 'Meccan' },
            { ar: 'الإنسان', en: 'Al-Insan', ayahs: 31, type: 'Medinan' },
            { ar: 'المرسلات', en: 'Al-Mursalat', ayahs: 50, type: 'Meccan' },
            { ar: 'النبأ', en: 'An-Naba', ayahs: 40, type: 'Meccan' },
            { ar: 'النازعات', en: 'An-Naziat', ayahs: 46, type: 'Meccan' },
            { ar: 'عبس', en: 'Abasa', ayahs: 42, type: 'Meccan' },
            { ar: 'التكوير', en: 'At-Takwir', ayahs: 29, type: 'Meccan' },
            { ar: 'الانفطار', en: 'Al-Infitar', ayahs: 19, type: 'Meccan' },
            { ar: 'المطففين', en: 'Al-Mutaffifin', ayahs: 36, type: 'Meccan' },
            { ar: 'الانشقاق', en: 'Al-Inshiqaq', ayahs: 25, type: 'Meccan' },
            { ar: 'البروج', en: 'Al-Buruj', ayahs: 22, type: 'Meccan' },
            { ar: 'الطارق', en: 'At-Tariq', ayahs: 17, type: 'Meccan' },
            { ar: 'الأعلى', en: 'Al-Ala', ayahs: 19, type: 'Meccan' },
            { ar: 'الغاشية', en: 'Al-Ghashiyah', ayahs: 26, type: 'Meccan' },
            { ar: 'الفجر', en: 'Al-Fajr', ayahs: 30, type: 'Meccan' },
            { ar: 'البلد', en: 'Al-Balad', ayahs: 20, type: 'Meccan' },
            { ar: 'الشمس', en: 'Ash-Shams', ayahs: 15, type: 'Meccan' },
            { ar: 'الليل', en: 'Al-Layl', ayahs: 21, type: 'Meccan' },
            { ar: 'الضحى', en: 'Ad-Duhaa', ayahs: 11, type: 'Meccan' },
            { ar: 'الشرح', en: 'Ash-Sharh', ayahs: 8, type: 'Meccan' },
            { ar: 'التين', en: 'At-Tin', ayahs: 8, type: 'Meccan' },
            { ar: 'العلق', en: 'Al-Alaq', ayahs: 19, type: 'Meccan' },
            { ar: 'القدر', en: 'Al-Qadr', ayahs: 5, type: 'Meccan' },
            { ar: 'البينة', en: 'Al-Bayyinah', ayahs: 8, type: 'Medinan' },
            { ar: 'الزلزلة', en: 'Az-Zalzalah', ayahs: 8, type: 'Medinan' },
            { ar: 'العاديات', en: 'Al-Adiyat', ayahs: 11, type: 'Meccan' },
            { ar: 'القارعة', en: 'Al-Qariah', ayahs: 11, type: 'Meccan' },
            { ar: 'التكاثر', en: 'At-Takathur', ayahs: 8, type: 'Meccan' },
            { ar: 'العصر', en: 'Al-Asr', ayahs: 3, type: 'Meccan' },
            { ar: 'الهمزة', en: 'Al-Humazah', ayahs: 9, type: 'Meccan' },
            { ar: 'الفيل', en: 'Al-Fil', ayahs: 5, type: 'Meccan' },
            { ar: 'قريش', en: 'Quraysh', ayahs: 4, type: 'Meccan' },
            { ar: 'الماعون', en: 'Al-Maun', ayahs: 7, type: 'Meccan' },
            { ar: 'الكوثر', en: 'Al-Kawthar', ayahs: 3, type: 'Meccan' },
            { ar: 'الكافرون', en: 'Al-Kafirun', ayahs: 6, type: 'Meccan' },
            { ar: 'النصر', en: 'An-Nasr', ayahs: 3, type: 'Medinan' },
            { ar: 'المسد', en: 'Al-Masad', ayahs: 5, type: 'Meccan' },
            { ar: 'الإخلاص', en: 'Al-Ikhlas', ayahs: 4, type: 'Meccan' },
            { ar: 'الفلق', en: 'Al-Falaq', ayahs: 5, type: 'Meccan' },
            { ar: 'الناس', en: 'An-Nas', ayahs: 6, type: 'Meccan' }
        ];

        // Will be populated from API
        let recitersData = [];
        let recitersMap = {};

        function quranTextApp() {
            return {
                locale: localStorage.getItem('locale') || 'ar',
                view: 'surahs',
                selectedSurah: 1,
                selectedTranslation: '',
                selectedReciter: null,
                reciters: [],
                ayahs: [],
                loading: false,

                // Audio player state
                audio: null,
                isPlaying: false,
                currentTime: '0:00',
                duration: '0:00',
                progress: 0,
                volume: 80,
                playbackSpeed: 1,
                currentAyahIndex: 0,

                translations: {
                    ar: {
                        appName: 'أنا المسلم',
                        nav: {
                            home: 'الرئيسية',
                            quranText: 'القرآن النصي',
                            hisnmuslim: 'حصن المسلم'
                        },
                        badge: 'قراءة القرآن الكريم',
                        title: 'القرآن الكريم - نصي',
                        subtitle: 'اقرأ القرآن بأسلوب المصحف مع الترجمة والاستماع بصوت أشهر القراء',
                        selectTranslation: 'اختر الترجمة (اختياري)',
                        selectReciter: 'اختر القارئ',
                        backToSurahs: 'العودة للسور',
                        loading: 'جاري التحميل...',
                        translation: 'الترجمة'
                    },
                    en: {
                        appName: "I'm Muslim",
                        nav: {
                            home: 'Home',
                            quranText: 'Quran Text',
                            hisnmuslim: 'Hisn Al-Muslim'
                        },
                        badge: 'Read the Holy Quran',
                        title: 'The Holy Quran - Text',
                        subtitle: 'Read the Quran in Mushaf style with translation and listen to renowned reciters',
                        selectTranslation: 'Select Translation (optional)',
                        selectReciter: 'Select Reciter',
                        backToSurahs: 'Back to Surahs',
                        loading: 'Loading...',
                        translation: 'Translation'
                    }
                },

                init() {
                    document.documentElement.lang = this.locale;
                    document.documentElement.dir = this.locale === 'ar' ? 'rtl' : 'ltr';
                },

                t(key) {
                    return key.split('.').reduce((o, i) => o?.[i], this.translations[this.locale]) || key;
                },

                toggleLocale() {
                    this.locale = this.locale === 'ar' ? 'en' : 'ar';
                    localStorage.setItem('locale', this.locale);
                    document.documentElement.lang = this.locale;
                    document.documentElement.dir = this.locale === 'ar' ? 'rtl' : 'ltr';
                },

                getSurahName(num, lang) {
                    return surahsData[num - 1]?.[lang] || '';
                },

                getSurahInfo(num) {
                    const surah = surahsData[num - 1];
                    return this.locale === 'ar'
                        ? `${surah.ayahs} آية • ${surah.type === 'Meccan' ? 'مكية' : 'مدنية'}`
                        : `${surah.ayahs} verses • ${surah.type}`;
                },

                getReciterName(reciterId) {
                    if (!reciterId) reciterId = this.selectedReciter;
                    return recitersMap[reciterId]?.name || '';
                },

                convertToArabicNumber(num) {
                    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
                    return String(num).split('').map(d => arabicNums[parseInt(d)]).join('');
                },

                async init() {
                    await this.fetchReciters();
                },

                async fetchReciters() {
                    try {
                        const resp = await fetch('/api/mp3quran/reciters');
                        const data = await resp.json();
                        this.reciters = data.reciters || data.data?.reciters || [];

                        // Build recitersMap using the full reciter object
                        recitersData = this.reciters;
                        this.reciters.forEach(r => {
                            recitersMap[r.id] = r;
                        });

                        // Set default reciter (مشاري العفاسي - ID: 7)
                        if (this.reciters.length > 0) {
                            const alafasy = this.reciters.find(r => r.id === 7);
                            this.selectedReciter = alafasy ? alafasy.id : this.reciters[0].id;
                        }
                    } catch (e) {
                        console.error('Error fetching reciters:', e);
                    }
                },

                async loadSurah() {
                    this.loading = true;
                    this.ayahs = [];
                    this.stopAudio();

                    try {
                        // Get Arabic text
                        const arabicRes = await fetch(`https://api.alquran.cloud/v1/surah/${this.selectedSurah}/quran-uthmani`);
                        const arabicData = await arabicRes.json();

                        // Get translation if selected
                        let transData = null;
                        if (this.selectedTranslation) {
                            const transRes = await fetch(`https://api.alquran.cloud/v1/surah/${this.selectedSurah}/${this.selectedTranslation}`);
                            transData = await transRes.json();
                        }

                        if (arabicData.data) {
                            this.ayahs = arabicData.data.ayahs.map((ayah, index) => ({
                                number: ayah.number,
                                numberInSurah: ayah.numberInSurah,
                                text: ayah.text,
                                translation: transData ? transData.data.ayahs[index]?.text || '' : ''
                            }));

                            // Setup audio for this surah
                            this.setupAudio();
                        }
                    } catch (error) {
                        console.error('Error loading surah:', error);
                        alert(this.locale === 'ar' ? 'خطأ في تحميل السورة' : 'Error loading surah');
                    } finally {
                        this.loading = false;
                    }
                },

                setupAudio() {
                    this.stopAudio();

                    const reciter = recitersMap[this.selectedReciter];
                    if (!reciter) {
                        console.error('Reciter not found');
                        return;
                    }

                    // Get audio URL for the surah (same logic as /quran page)
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

                    if (!audioUrl) {
                        console.error('No audio URL found for this surah');
                        return;
                    }

                    this.audio = new Audio(audioUrl);
                    this.audio.volume = this.volume / 100;
                    this.audio.playbackRate = this.playbackSpeed;

                    this.audio.addEventListener('loadedmetadata', () => {
                        this.duration = this.formatTime(this.audio.duration);
                    });

                    this.audio.addEventListener('timeupdate', () => {
                        this.currentTime = this.formatTime(this.audio.currentTime);
                        this.progress = (this.audio.currentTime / this.audio.duration) * 100;
                    });

                    this.audio.addEventListener('ended', () => {
                        this.isPlaying = false;
                    });
                },

                changeReciter() {
                    const wasPlaying = this.isPlaying;
                    this.stopAudio();

                    const reciter = recitersMap[this.selectedReciter];
                    if (!reciter) {
                        console.error('Reciter not found');
                        return;
                    }

                    // Get audio URL for current surah with new reciter
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

                    if (!audioUrl) {
                        console.error('No audio URL found');
                        return;
                    }

                    this.audio = new Audio(audioUrl);
                    this.audio.volume = this.volume / 100;
                    this.audio.playbackRate = this.playbackSpeed;

                    this.audio.addEventListener('loadedmetadata', () => {
                        this.duration = this.formatTime(this.audio.duration);
                    });

                    this.audio.addEventListener('timeupdate', () => {
                        this.currentTime = this.formatTime(this.audio.currentTime);
                        this.progress = (this.audio.currentTime / this.audio.duration) * 100;
                    });

                    this.audio.addEventListener('ended', () => {
                        this.isPlaying = false;
                    });

                    if (wasPlaying) {
                        this.audio.play().catch(e => console.error("Audio play error:", e));
                        this.isPlaying = true;
                    }
                },

                toggleAudio() {
                    if (!this.audio) return;

                    if (this.isPlaying) {
                        this.audio.pause();
                        this.isPlaying = false;
                    } else {
                        this.audio.play().catch(e => console.error("Audio play error:", e));
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
                        this.currentAyahIndex = 0;
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

                toggleSpeed() {
                    const speeds = [1, 1.25, 1.5, 0.75];
                    const currentIndex = speeds.indexOf(this.playbackSpeed);
                    this.playbackSpeed = speeds[(currentIndex + 1) % speeds.length];
                    if (this.audio) {
                        this.audio.playbackRate = this.playbackSpeed;
                    }
                },

                formatTime(seconds) {
                    if (isNaN(seconds)) return '0:00';
                    const mins = Math.floor(seconds / 60);
                    const secs = Math.floor(seconds % 60);
                    return `${mins}:${secs.toString().padStart(2, '0')}`;
                }
            }
        }
    </script>

    <!-- ✅ تحميل Alpine.js بعد تعريف جميع الدوال -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</body>
</html>
