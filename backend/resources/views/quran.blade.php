<!DOCTYPE html>
<html lang="ar" dir="rtl" class="dark">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>المصحف الشريف - أنا المسلم</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    @vite(['resources/css/app.css', 'resources/js/app.js'])
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
            background: rgba(15, 23, 42, 0.85); /* Increased opacity for better contrast */
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
        
        input[type="range"] { -webkit-appearance: none; background: transparent; cursor: pointer; direction: ltr !important; }
        input[type="range"]::-webkit-slider-runnable-track { background: rgba(17, 212, 180, 0.1); height: 4px; border-radius: 2px; }
        input[type="range"]::-webkit-slider-thumb { -webkit-appearance: none; height: 12px; width: 12px; background: #11D4B4; border-radius: 50%; margin-top: -4px; }
    </style>
</head>
<body 
    x-data="quranApp()"
    :dir="locale === 'ar' ? 'rtl' : 'ltr'"
    class="bg-[#F1F5F9] dark:bg-[#0B1121] text-slate-800 dark:text-slate-100 transition-colors duration-500 min-h-screen relative overflow-x-hidden selection:bg-primary/30">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    @include('partials.web-navbar')

    <main class="max-w-7xl mx-auto px-4 pt-32 pb-40 relative z-10">
        <div class="flex flex-col gap-8">
            <!-- Header Section -->
            <div class="flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div class="flex items-center gap-4">
                    <template x-if="view === 'surahs'">
                        <button @click="view = 'reciters'" class="w-12 h-12 rounded-2xl glass-button flex items-center justify-center text-primary hover:scale-105 transition-all">
                            <iconify-icon icon="solar:alt-arrow-right-linear" class="text-2xl"></iconify-icon>
                        </button>
                    </template>
                    <div>
                        <h1 class="text-4xl font-bold mb-2 text-slate-900 dark:text-white" 
                            x-text="view === 'reciters' ? 'المصحف الشريف' : 'سور القارئ: ' + selectedReciter.name"></h1>
                        <p class="text-slate-600 dark:text-slate-400 text-lg"
                           x-text="view === 'reciters' ? 'استمع إلى تلاوات عطرة من كبار القراء' : 'اختر السورة لبدء الاستماع'"></p>
                    </div>
                </div>

                <!-- Global Search (Visible in Reciters View) -->
                <template x-if="view === 'reciters'">
                    <div class="relative w-full md:w-96">
                        <iconify-icon icon="solar:magnifer-linear"
                                      class="absolute right-5 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500 text-xl"></iconify-icon>
                        <input type="text"
                               x-model="search"
                               placeholder="ابحث عن قارئ..."
                               class="w-full h-14 pr-13 pl-6 rounded-2xl bg-white/50 dark:bg-slate-800/50 border border-primary/10 backdrop-blur-xl focus:border-primary focus:ring-4 focus:ring-primary/10 text-base font-semibold transition-all outline-none text-slate-800 dark:text-white placeholder:text-slate-400 dark:placeholder:text-slate-600">
                    </div>
                </template>
            </div>

            <!-- Nationality Filter (Visible in Reciters View) -->
            <div x-show="view === 'reciters' && availableNationalities.length > 0" x-transition class="relative">
                <div class="flex flex-wrap items-center gap-2 pb-2">
                    <button @click="selectedNationality = ''"
                            :class="selectedNationality === '' ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'glass-panel text-slate-600 dark:text-slate-400 hover:text-primary hover:border-primary/20'"
                            class="px-5 py-2.5 rounded-2xl text-sm font-bold transition-all border border-transparent">
                        الكل
                        <span class="mr-1 text-xs opacity-75" x-text="'(' + reciters.length + ')'"></span>
                    </button>
                    <template x-for="nat in availableNationalities" :key="nat.label">
                        <button @click="selectedNationality = nat.label"
                                :class="selectedNationality === nat.label ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'glass-panel text-slate-600 dark:text-slate-400 hover:text-primary hover:border-primary/20'"
                                class="px-5 py-2.5 rounded-2xl text-sm font-bold transition-all border border-transparent">
                            <span x-text="nat.label"></span>
                            <span class="mr-1 text-xs opacity-75" x-text="'(' + nat.count + ')'"></span>
                        </button>
                    </template>
                </div>
            </div>

            <!-- Reciters Grid View -->
            <div x-show="view === 'reciters'" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                    <template x-for="r in filteredReciters" :key="r.id">
                        <button @click="selectReciter(r)" 
                                class="glass-panel rounded-3xl p-6 flex flex-col items-center gap-4 hover:shadow-2xl hover:shadow-primary/10 transition-all border border-transparent hover:border-primary/20 group">
                            <div class="w-20 h-20 rounded-2xl bg-primary/10 flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all font-bold text-2xl shadow-sm" x-text="r.letter"></div>
                            <h3 class="font-bold text-slate-800 dark:text-white text-base group-hover:text-primary transition-colors" x-text="r.name"></h3>
                            <div class="flex items-center gap-2 mt-1">
                                <template x-if="r.nationality">
                                    <span class="text-[10px] bg-amber-500/10 text-amber-600 dark:text-amber-400 px-2 py-0.5 rounded-md font-medium" x-text="getNationalityLabel(r.nationality)"></span>
                                </template>
                            </div>
                        </button>
                    </template>
                </div>
                <!-- Empty State -->
                <template x-if="filteredReciters.length === 0">
                    <div class="py-20 text-center glass-panel rounded-[2.5rem]">
                        <iconify-icon icon="solar:user-block-linear" class="text-6xl text-slate-300 dark:text-slate-600 mb-4"></iconify-icon>
                        <p class="text-slate-400 dark:text-slate-500 font-bold text-xl">لم نعثر على أي نتائج</p>
                    </div>
                </template>
            </div>

            <!-- Surahs Grid View -->
            <div x-show="view === 'surahs'" x-transition:enter="transition ease-out duration-300" x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0">
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
                    <template x-for="i in 114" :key="i">
                        <button @click="playSurah(i)" 
                                :class="currentSurahNum === i && isPlaying ? 'bg-primary/20 border-primary/40' : 'border-transparent'"
                                class="glass-button rounded-2xl p-5 flex flex-col items-center justify-center gap-3 cursor-pointer hover:bg-primary/10 hover:border-primary/40 transition-all border group relative">
                            <span class="text-xl font-bold text-slate-500 dark:text-slate-400 group-hover:text-primary transition-colors" x-text="i"></span>
                            <h5 class="font-bold text-sm text-center text-slate-800 dark:text-white" x-text="'سورة ' + getSurahName(i)"></h5>
                            
                            <template x-if="currentSurahNum === i && isPlaying">
                                <div class="absolute top-2 left-2 w-2 h-2 rounded-full bg-primary animate-ping"></div>
                            </template>
                        </button>
                    </template>
                </div>
            </div>
        </div>
    </main>

    <!-- Sticky Audio Player -->
    <div id="sticky-player" class="fixed bottom-6 left-6 right-6 max-w-5xl mx-auto z-[60] glass-panel rounded-[2rem] p-4 md:p-6 shadow-2xl border-primary/20 animate-slide-up hidden">
        <div id="loading-bar" class="loading-bar"></div>
        <div class="flex flex-col gap-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4 overflow-hidden">
                    <div class="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center text-primary shrink-0 relative overflow-hidden">
                        <iconify-icon icon="solar:music-note-broken" class="text-2xl"></iconify-icon>
                        <div id="player-spinner" class="absolute inset-0 bg-primary/20 flex items-center justify-center hidden">
                            <iconify-icon icon="solar:spinner-bold" class="text-2xl animate-spin text-primary"></iconify-icon>
                        </div>
                    </div>
                    <div class="min-w-0">
                        <h4 id="player-surah-name" class="font-bold text-lg text-slate-900 dark:text-white truncate">اسم السورة</h4>
                        <p id="player-reciter-name" class="text-sm text-slate-600 dark:text-slate-400 truncate">اسم القارئ</p>
                    </div>
                </div>
                <div class="flex items-center gap-2 md:gap-4 shrink-0">
                    <button onclick="prevSurah()" class="w-10 h-10 rounded-full glass-button flex items-center justify-center text-slate-600 dark:text-slate-400 hover:text-primary transition-colors">
                        <iconify-icon icon="solar:skip-next-bold" class="text-xl"></iconify-icon>
                    </button>
                    <button onclick="togglePlay()" id="play-btn" class="w-14 h-14 rounded-full bg-primary text-white flex items-center justify-center shadow-lg shadow-primary/30 hover:scale-105 transition-transform">
                        <iconify-icon icon="solar:play-bold" id="play-btn-icon" class="text-3xl"></iconify-icon>
                    </button>
                    <button onclick="nextSurah()" class="w-10 h-10 rounded-full glass-button flex items-center justify-center text-slate-600 dark:text-slate-400 hover:text-primary transition-colors">
                        <iconify-icon icon="solar:skip-previous-bold" class="text-xl"></iconify-icon>
                    </button>
                </div>
            </div>
            
            <div class="flex items-center gap-4">
                <span id="curr-time" class="text-[10px] font-medium text-slate-400 w-10">0:00</span>
                <input type="range" id="player-seek" class="flex-1" value="0" min="0" max="100">
                <span id="dur-time" class="text-[10px] font-medium text-slate-400 w-10">0:00</span>
                <div class="hidden md:flex items-center gap-2 group relative">
                    <button id="mute-btn" class="text-slate-400 hover:text-primary transition-colors">
                        <iconify-icon icon="solar:volume-loud-linear" class="text-xl"></iconify-icon>
                    </button>
                    <input type="range" id="volume-slider" class="w-0 group-hover:w-20 transition-all overflow-hidden" value="1" min="0" max="1" step="0.1">
                </div>
            </div>
        </div>
    </div>

    <!-- ✅ تعريف quranApp() قبل تحميل Alpine.js -->
    <script>
        function quranApp() {
            const nationalityLabels = {
                'SA': 'سعودي', 'EG': 'مصري', 'AE': 'إماراتي', 'KW': 'كويتي',
                'QA': 'قطري', 'BH': 'بحريني', 'OM': 'عماني', 'YE': 'يمني',
                'IQ': 'عراقي', 'SY': 'سوري', 'JO': 'أردني', 'PS': 'فلسطيني',
                'LB': 'لبناني', 'LY': 'ليبي', 'TN': 'تونسي', 'DZ': 'جزائري',
                'MA': 'مغربي', 'MR': 'موريتاني', 'SD': 'سوداني', 'SO': 'صومالي',
                'DJ': 'جيبوتي', 'KM': 'قمري', 'TR': 'تركي', 'IR': 'إيراني',
                'AF': 'أفغاني', 'PK': 'باكستاني', 'IN': 'هندي', 'BD': 'بنغلاديشي',
                'MY': 'ماليزي', 'ID': 'إندونيسي', 'NG': 'نيجيري', 'SN': 'سنغالي',
                'ML': 'مالي', 'TD': 'تشادي', 'OTHER': 'أخرى',
            };

            return {
                view: 'reciters',
                locale: localStorage.getItem('locale') || 'ar',
                translations: {
                    ar: { title: 'المصحف الشريف', subtitle: 'استمع إلى تلاوات عطرة من كبار القراء', search: 'ابحث عن قارئ...', back: 'عودة للمقرئين', 'nav.home': 'الرئيسية', 'nav.quranText': 'نص القرآن', 'nav.quranPremium': 'القرآن المميز', 'nav.hisnmuslim': 'حصن المسلم', 'nav.privacy': 'الخصوصية', 'nav.menu': 'القائمة' },
                    en: { title: 'The Holy Quran', subtitle: 'Listen to beautiful recitations from top reciters', search: 'Search for reciter...', back: 'Back to reciters', 'nav.home': 'Home', 'nav.quranText': 'Quran Text', 'nav.quranPremium': 'Quran Premium', 'nav.hisnmuslim': 'Hisnul Muslim', 'nav.privacy': 'Privacy', 'nav.menu': 'Menu' }
                },
                t(key) { return this.translations[this.locale][key]; },
                toggleLocale() {
                    this.locale = this.locale === 'ar' ? 'en' : 'ar';
                    localStorage.setItem('locale', this.locale);
                    document.documentElement.lang = this.locale;
                    document.documentElement.dir = this.locale === 'ar' ? 'rtl' : 'ltr';
                },
                // ... (rest of search/select logic)
                search: '',
                selectedNationality: '',
                reciters: [],
                selectedReciter: null,
                currentSurahNum: null,
                isPlaying: false,

                async init() {
                    await this.fetchReciters();
                    // Sync local state with global audio state if needed
                    setInterval(() => {
                        this.currentSurahNum = window.currentSurahNum;
                        this.isPlaying = window.isPlaying;
                    }, 500);
                },

                async fetchReciters() {
                    try {
                        const resp = await fetch('/api/mp3quran/reciters');
                        const data = await resp.json();
                        this.reciters = data.reciters || data.data?.reciters || [];
                    } catch (e) {
                        console.error('Error fetching reciters:', e);
                    }
                },

                get availableNationalities() {
                    const counts = {};
                    this.reciters.forEach(r => {
                        if (r.nationality) {
                            const label = this.getNationalityLabel(r.nationality);
                            counts[label] = (counts[label] || 0) + 1;
                        }
                    });
                    return Object.entries(counts)
                        .map(([label, count]) => ({ label, count }))
                        .sort((a, b) => b.count - a.count);
                },

                get filteredReciters() {
                    let result = this.reciters;
                    if (this.selectedNationality) {
                        result = result.filter(r => this.getNationalityLabel(r.nationality) === this.selectedNationality);
                    }
                    if (this.search) {
                        const s = this.search.toLowerCase();
                        result = result.filter(r => r.name.toLowerCase().includes(s));
                    }
                    return result;
                },
                
                selectReciter(r) {
                    this.selectedReciter = r;
                    this.view = 'surahs';
                    this.search = '';
                    this.selectedNationality = '';
                    window.currentReciter = r;
                },

                getNationalityLabel(code) {
                    return nationalityLabels[code] || code;
                },

                playSurah(num) {
                    window.playSurah(num, this.selectedReciter);
                },

                getSurahName(num) {
                    return window.getSurahName(num);
                }
            }
        }
    </script>

    <!-- ✅ تحميل Alpine.js بعد تعريف جميع الدوال -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <script>
        // Global Audio State & Functions
        const stickyPlayer = document.getElementById('sticky-player');
        const playBtnIcon = document.getElementById('play-btn-icon');
        const playerSurahName = document.getElementById('player-surah-name');
        const playerReciterName = document.getElementById('player-reciter-name');
        const playerSeek = document.getElementById('player-seek');
        const currTimeText = document.getElementById('curr-time');
        const durTimeText = document.getElementById('dur-time');
        const muteBtn = document.getElementById('mute-btn');
        const volumeSlider = document.getElementById('volume-slider');
        const loadingBar = document.getElementById('loading-bar');
        const playerSpinner = document.getElementById('player-spinner');

        window.isPlaying = false;
        let mainAudio = new Audio();
        window.currentSurahNum = null;
        window.currentReciter = null;

        async function playSurah(num, reciter = window.currentReciter) {
            if (!reciter) return;

            window.currentSurahNum = num;
            window.currentReciter = reciter;

            let audioUrl = null;
            if (reciter.moshaf && reciter.moshaf[0]) {
                const moshaf = reciter.moshaf[0];
                if (moshaf.direct_surah_urls && moshaf.direct_surah_urls[String(num)]) {
                    audioUrl = moshaf.direct_surah_urls[String(num)];
                } else if (moshaf.server) {
                    const surahFormatted = num.toString().padStart(3, '0');
                    audioUrl = `${moshaf.server}/${surahFormatted}.mp3`;
                }
            }

            if (!audioUrl) return;

            playerSurahName.textContent = `سورة ${getSurahName(num)}`;
            playerReciterName.textContent = reciter.name;
            stickyPlayer.classList.remove('hidden');

            mainAudio.src = audioUrl;
            mainAudio.play();
            window.isPlaying = true;
            playBtnIcon.setAttribute('icon', 'solar:pause-bold');

            playerSpinner.classList.remove('hidden');
            loadingBar.style.width = '0%';

            mainAudio.onwaiting = () => { playerSpinner.classList.remove('hidden'); loadingBar.style.width = '50%'; };
            mainAudio.onplaying = () => { playerSpinner.classList.add('hidden'); loadingBar.style.width = '100%'; setTimeout(() => loadingBar.style.width = '0%', 500); };
            mainAudio.onended = () => nextSurah();
        }

        function togglePlay() {
            if (window.isPlaying) {
                mainAudio.pause();
                playBtnIcon.setAttribute('icon', 'solar:play-bold');
            } else {
                mainAudio.play();
                playBtnIcon.setAttribute('icon', 'solar:pause-bold');
            }
            window.isPlaying = !window.isPlaying;
        }

        mainAudio.ontimeupdate = (e) => {
            const { currentTime, duration } = e.target;
            currTimeText.textContent = formatTime(currentTime);
            if (duration) {
                durTimeText.textContent = formatTime(duration);
                playerSeek.value = (currentTime / duration) * 100;
            }
        };

        playerSeek.oninput = (e) => {
            const val = e.target.value;
            if (mainAudio.duration) {
                mainAudio.currentTime = (val / 100) * mainAudio.duration;
            }
        };

        volumeSlider.oninput = (e) => {
            mainAudio.volume = e.target.value;
            updateVolumeIcon(e.target.value);
        };

        function updateVolumeIcon(vol) {
            let icon = 'solar:volume-loud-linear';
            if (vol == 0) icon = 'solar:mute-linear';
            else if (vol < 0.5) icon = 'solar:volume-low-linear';
            muteBtn.innerHTML = `<iconify-icon icon="${icon}" class="text-xl"></iconify-icon>`;
        }

        function formatTime(seconds) {
            const h = Math.floor(seconds / 3600);
            const m = Math.floor((seconds % 3600) / 60);
            const s = Math.floor(seconds % 60);
            return (h > 0 ? h + ":" : "") + m + ":" + (s < 10 ? "0" + s : s);
        }

        function nextSurah() {
            if (window.currentSurahNum < 114) playSurah(window.currentSurahNum + 1);
            else playSurah(1);
        }

        function prevSurah() {
            if (window.currentSurahNum > 1) playSurah(window.currentSurahNum - 1);
            else playSurah(114);
        }

        function getSurahName(num) {
            const names = ["الفاتحة","البقرة","آل عمران","النساء","المائدة","الأنعام","الأعراف","الأنفال","التوبة","يونس","هود","يوسف","الرعد","إبراهيم","الحجر","النحل","الإسراء","الكهف","مريم","طه","الأنبياء","الحج","المؤمنون","النور","الفرقان","الشعراء","النمل","القصص","العنكبوت","الروم","لقمان","السجدة","الأحزاب","سبأ","فاطر","يس","الصافات","ص","الزمر","غافر","فصلت","الشورى","الزخرف","الدخان","الجاثية","الأحقاف","محمد","الفتح","الحجرات","ق","الذاريات","الطور","النجم","القمر","الرحمن","الواقعة","الحديد","المجادلة","الحشر","الممتحنة","الصف","الجمعة","المنافقون","التغابن","الطلاق","التحريم","الملك","القلم","الحاقة","المعارج","نوح","الجن","المزمل","المدثر","القيامة","الإنسان","المرسلات","النبأ","النازعات","عبس","التكوير","الانفطار","المطففين","الانشقاق","البروج","الطارق","الأعلى","الغاشية","الفجر","البلد","الشمس","الليل","الضحى","الشرح","التين","العلق","القدر","البينة","الزلزلة","العاديات","القارعة","التكاثر","العصر","الهمزة","الفيل","قريش","الماعون","الكوثر","الكافرون","النصر","المسد","الإخلاص","الفلق","الناس"];
            return names[num - 1];
        }

        window.getSurahName = getSurahName;
        window.playSurah = playSurah;
    </script>
</body>
</html>
