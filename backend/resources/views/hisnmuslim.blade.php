@extends('layouts.web')

@section('content')
<main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-10 sm:pt-28 sm:pb-16">

    <!-- Hero & Search Section -->
    <div class="flex flex-col items-center text-center mb-16 w-full">
        <div class="inline-flex items-center gap-2 bg-white dark:bg-slate-800 px-4 py-15 rounded-full shadow-sm border border-slate-200/60 dark:border-slate-700 mb-8 animate-fade-in-up">
            <iconify-icon icon="solar:book-bookmark-linear" width="16" height="16" class="text-primary"></iconify-icon>
            <span class="text-sm font-medium text-slate-600 dark:text-slate-400">من أذكار وأدعية المسلم</span>
        </div>

        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-semibold tracking-tight text-slate-900 dark:text-white mb-6 drop-shadow-sm">
            حصن المسلم
        </h1>

        <p class="text-base sm:text-lg text-slate-500 dark:text-slate-400 max-w-2xl mx-auto leading-relaxed mb-10">
            أذكار وأدعية من الكتاب والسنة مع الأحاديث الصوتية مرتبة لسهولة الوصول والحفظ
        </p>

        <!-- Search Bar (UX Improvement) -->
        <div class="w-full max-w-2xl mx-auto relative group">
            <div class="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none text-slate-400 group-focus-within:text-primary transition-colors">
                <iconify-icon icon="solar:magnifer-linear" width="20" height="20"></iconify-icon>
            </div>
            <input type="text" id="searchInput" placeholder="ابحث في الأذكار والأدعية..." class="w-full bg-white dark:bg-slate-800 border border-slate-200/80 dark:border-slate-700 rounded-2xl py-3.5 pr-12 pl-16 text-sm text-slate-800 dark:text-white shadow-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all duration-300">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <kbd class="hidden sm:inline-flex items-center gap-1 bg-slate-50 dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-lg px-2 py-1 text-xs font-medium text-slate-400 font-sans">
                    <span class="text-xs">⌘</span> K
                </kbd>
            </div>
        </div>

        <!-- Quick Filters (UX Improvement) -->
        <div class="flex flex-wrap items-center justify-center gap-2 mt-6">
            <button class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-primary/10 text-primary border border-primary/20 transition-colors" data-filter="all">الكل</button>
            <button class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 hover:text-slate-900 dark:hover:text-white transition-colors shadow-sm" data-filter="الصباح">الصباح والمساء</button>
            <button class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 hover:text-slate-900 dark:hover:text-white transition-colors shadow-sm" data-filter="النوم">النوم</button>
            <button class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 hover:text-slate-900 dark:hover:text-white transition-colors shadow-sm" data-filter="الوضوء">الوضوء</button>
            <button class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-700 hover:text-slate-900 dark:hover:text-white transition-colors shadow-sm" data-filter="المنزل">المنزل</button>
        </div>
    </div>

    <!-- Grid Section -->
    <div id="chaptersGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 sm:gap-6">
        <!-- Loading State -->
        <div id="loadingState" class="col-span-full flex items-center justify-center py-20">
            <div class="loading-spinner"></div>
        </div>

        <!-- Chapters will be loaded here dynamically -->
    </div>

    <!-- Empty State -->
    <div id="emptyState" class="hidden col-span-full flex flex-col items-center justify-center py-20 text-center">
        <iconify-icon icon="solar:magnifer-bug-linear" width="64" height="64" class="text-slate-300 dark:text-slate-700 mb-4"></iconify-icon>
        <h3 class="text-lg font-semibold text-slate-700 dark:text-slate-300 mb-2">لم يتم العثور على نتائج</h3>
        <p class="text-sm text-slate-500 dark:text-slate-500">جرب البحث بكلمات مختلفة</p>
    </div>
</main>

@push('styles')
<style>
    .animate-fade-in-up {
        animation: fadeInUp 0.6s ease-out;
    }

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

    .chapter-card {
        transition: all 0.3s ease;
    }

    .chapter-card:hover {
        transform: translateY(-4px);
    }
</style>
@endpush

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', async function() {
    const chaptersGrid = document.getElementById('chaptersGrid');
    const loadingState = document.getElementById('loadingState');
    const emptyState = document.getElementById('emptyState');
    const searchInput = document.getElementById('searchInput');

    let allChapters = [];
    let currentFilter = 'all';

    // Icon mapping for different chapter types
    const iconMapping = {
        'الصباح': 'solar:sun-2-linear',
        'المساء': 'solar:sun-2-linear',
        'النوم': 'solar:moon-linear',
        'الاستيقاظ': 'solar:alarm-linear',
        'الخلاء': 'solar:door-linear',
        'الوضوء': 'solar:drop-linear',
        'المنزل': 'solar:home-angle-linear',
        'الخروج': 'solar:home-angle-linear',
        'دخول': 'solar:home-smile-linear',
        'المسجد': 'solar:mosque-bold',
        'الصلاة': 'solar:meditation-round-linear',
        'السفر': 'solar:suitcase-linear',
        'الطعام': 'solar:cup-hot-linear',
        'default': 'solar:book-bookmark-linear'
    };

    function getIconForChapter(chapterName) {
        for (const [key, icon] of Object.entries(iconMapping)) {
            if (chapterName.includes(key)) {
                return icon;
            }
        }
        return iconMapping.default;
    }

    // Fetch chapters from API
    async function loadChapters() {
        try {
            const response = await fetch('/api/hisnmuslim/chapters');
            const data = await response.json();

            // تحقق من أن البيانات مصفوفة
            if (Array.isArray(data)) {
                allChapters = data;
                renderChapters(allChapters);
            } else if (data.success && data.data) {
                allChapters = data.data;
                renderChapters(allChapters);
            } else {
                throw new Error('Invalid data format');
            }
        } catch (error) {
            console.error('Error loading chapters:', error);
            loadingState.innerHTML = `
                <div class="text-center">
                    <iconify-icon icon="solar:danger-circle-bold" width="48" height="48" class="text-red-500 mb-4"></iconify-icon>
                    <p class="text-slate-600 dark:text-slate-400">حدث خطأ في تحميل البيانات</p>
                </div>
            `;
        }
    }

    // Render chapters
    function renderChapters(chapters) {
        loadingState.classList.add('hidden');

        if (chapters.length === 0) {
            emptyState.classList.remove('hidden');
            return;
        }

        emptyState.classList.add('hidden');

        chaptersGrid.innerHTML = chapters.map(chapter => {
            const chapterName = chapter.title_ar || chapter.name || 'باب';
            const icon = getIconForChapter(chapterName);
            const duasCount = chapter.duas_count || 0;

            return `
                <a href="/hisnmuslim/${chapter.id}" class="chapter-card group relative bg-white dark:bg-slate-800 rounded-3xl p-6 shadow-sm border border-slate-200/60 dark:border-slate-700 hover:shadow-lg hover:shadow-slate-200/50 dark:hover:shadow-slate-900/50 hover:border-primary/30 dark:hover:border-primary/30 transition-all duration-300 flex flex-col min-h-[14rem] overflow-hidden cursor-pointer">
                    <!-- Background decoration -->
                    <div class="absolute -left-6 -top-6 text-slate-50 dark:text-slate-900 opacity-0 group-hover:opacity-100 transition-opacity duration-500 transform group-hover:scale-110 pointer-events-none">
                        <iconify-icon icon="${icon}" width="140" height="140"></iconify-icon>
                    </div>

                    <div class="relative z-10 flex flex-col h-full">
                        <div class="flex justify-between items-start w-full mb-4">
                            <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center text-slate-500 dark:text-slate-400 group-hover:from-primary/10 group-hover:to-primary/5 group-hover:text-primary border border-slate-100 dark:border-slate-700 group-hover:border-primary/20 transition-colors">
                                <iconify-icon icon="${icon}" width="24" height="24"></iconify-icon>
                            </div>
                            <button onclick="event.preventDefault(); toggleBookmark(${chapter.id})" class="w-8 h-8 rounded-full bg-slate-50 dark:bg-slate-900 flex items-center justify-center text-slate-400 hover:bg-primary/10 hover:text-primary transition-colors" title="حفظ">
                                <iconify-icon icon="solar:bookmark-linear" width="18" height="18"></iconify-icon>
                            </button>
                        </div>

                        <div class="mt-auto">
                            <h3 class="text-xl font-medium text-slate-800 dark:text-white tracking-tight group-hover:text-primary transition-colors mb-2">${chapterName}</h3>
                            <p class="text-sm text-slate-500 dark:text-slate-400 line-clamp-2 leading-relaxed">${chapter.description || 'أذكار وأدعية مأثورة من السنة النبوية'}</p>
                        </div>

                        <div class="mt-5 pt-4 border-t border-slate-100 dark:border-slate-700 flex items-center justify-between">
                            <span class="text-xs font-medium text-slate-400 bg-slate-50 dark:bg-slate-900 px-2.5 py-1 rounded-md">${duasCount} ${duasCount === 1 ? 'ذكر' : 'أذكار'}</span>
                            <span class="flex items-center gap-1.5 text-xs font-medium text-primary hover:text-primary/80 transition-colors">
                                عرض
                                <iconify-icon icon="solar:arrow-left-linear" width="18" height="18"></iconify-icon>
                            </span>
                        </div>
                    </div>
                </a>
            `;
        }).join('');
    }

    // Search functionality
    searchInput.addEventListener('input', function(e) {
        const searchTerm = e.target.value.toLowerCase().trim();

        if (searchTerm === '') {
            filterChapters(currentFilter);
            return;
        }

        const filtered = allChapters.filter(chapter => {
            const chapterName = (chapter.title_ar || chapter.name || '').toLowerCase();
            const chapterDesc = (chapter.description || '').toLowerCase();
            return chapterName.includes(searchTerm) || chapterDesc.includes(searchTerm);
        });

        renderChapters(filtered);
    });

    // Filter functionality
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            // Update active state
            document.querySelectorAll('.filter-btn').forEach(b => {
                b.classList.remove('bg-primary/10', 'text-primary', 'border-primary/20');
                b.classList.add('bg-white', 'dark:bg-slate-800', 'text-slate-600', 'dark:text-slate-400', 'border-slate-200', 'dark:border-slate-700');
            });

            this.classList.remove('bg-white', 'dark:bg-slate-800', 'text-slate-600', 'dark:text-slate-400', 'border-slate-200', 'dark:border-slate-700');
            this.classList.add('bg-primary/10', 'text-primary', 'border-primary/20');

            const filter = this.dataset.filter;
            currentFilter = filter;
            filterChapters(filter);
        });
    });

    function filterChapters(filter) {
        if (filter === 'all') {
            renderChapters(allChapters);
            return;
        }

        const filtered = allChapters.filter(chapter => {
            const chapterName = chapter.title_ar || chapter.name || '';
            return chapterName.includes(filter);
        });

        renderChapters(filtered);
    }

    // Bookmark functionality (placeholder)
    window.toggleBookmark = function(chapterId) {
        // Implement bookmark functionality
        console.log('Toggle bookmark for chapter:', chapterId);
    };

    // Keyboard shortcut for search (Cmd/Ctrl + K)
    document.addEventListener('keydown', function(e) {
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
            e.preventDefault();
            searchInput.focus();
        }
    });

    // Load chapters on page load
    await loadChapters();
});
</script>
@endpush
@endsection
