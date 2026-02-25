@extends('layouts.web')

@section('content')
<main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-10 sm:pt-28 sm:pb-16">
    <div id="chapterContent">
        <!-- Loading State -->
        <div id="loadingState" class="flex items-center justify-center py-20">
            <div class="loading-spinner"></div>
        </div>

        <!-- Error State -->
        <div id="errorState" class="hidden text-center py-20">
            <iconify-icon icon="solar:danger-circle-bold" width="64" height="64" class="text-red-500 mb-4"></iconify-icon>
            <h3 class="text-lg font-semibold text-slate-700 dark:text-slate-300 mb-2">حدث خطأ</h3>
            <p class="text-sm text-slate-500 dark:text-slate-500 mb-4">لم نتمكن من تحميل الأذكار</p>
            <a href="{{ url('/hisnmuslim') }}" class="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-xl hover:bg-primary/90 transition-colors">
                <iconify-icon icon="solar:arrow-right-linear" width="20" height="20"></iconify-icon>
                العودة إلى حصن المسلم
            </a>
        </div>

        <!-- Content will be loaded here -->
    </div>
</main>

@push('styles')
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

    .dua-card {
        transition: all 0.3s ease;
    }

    .dua-card:hover {
        transform: translateY(-2px);
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

    .animate-fade-in-up {
        animation: fadeInUp 0.6s ease-out;
    }
</style>
@endpush

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', async function() {
    const chapterId = {{ $chapterId }};
    const loadingState = document.getElementById('loadingState');
    const errorState = document.getElementById('errorState');
    const chapterContent = document.getElementById('chapterContent');

    try {
        const response = await fetch(`/api/hisnmuslim/duas/${chapterId}`);
        const data = await response.json();

        if (!data.chapter || !data.duas) {
            throw new Error('Invalid data');
        }

        loadingState.remove();

        const { chapter, duas } = data;

        const html = `
            <!-- Back Button -->
            <div class="mb-8">
                <a href="{{ url('/hisnmuslim') }}" class="inline-flex items-center gap-2 text-sm font-medium text-slate-600 dark:text-slate-400 hover:text-primary transition-colors">
                    <iconify-icon icon="solar:arrow-right-linear" width="20" height="20"></iconify-icon>
                    العودة إلى حصن المسلم
                </a>
            </div>

            <!-- Chapter Header -->
            <div class="text-center mb-12 animate-fade-in-up">
                <div class="inline-flex items-center gap-2 bg-white dark:bg-slate-800 px-4 py-1.5 rounded-full shadow-sm border border-slate-200/60 dark:border-slate-700 mb-6">
                    <iconify-icon icon="solar:book-bookmark-linear" width="16" height="16" class="text-primary"></iconify-icon>
                    <span class="text-sm font-medium text-slate-600 dark:text-slate-400">حصن المسلم</span>
                </div>

                <h1 class="text-3xl sm:text-4xl font-bold text-slate-900 dark:text-white mb-4">
                    ${chapter.title_ar}
                </h1>

                <p class="text-slate-500 dark:text-slate-400">
                    ${duas.length} ${duas.length === 1 ? 'ذكر' : 'أذكار'}
                </p>

                ${chapter.audio_url ? `
                    <div class="mt-6">
                        <button onclick="playAudio('${chapter.audio_url}')" class="inline-flex items-center gap-2 px-6 py-3 bg-primary text-white rounded-2xl hover:bg-primary/90 transition-all shadow-lg hover:shadow-xl">
                            <iconify-icon icon="solar:play-bold" width="20" height="20"></iconify-icon>
                            <span class="font-medium">استماع للباب كاملاً</span>
                        </button>
                    </div>
                ` : ''}
            </div>

            <!-- Duas List -->
            <div class="space-y-6">
                ${duas.map((dua, index) => `
                    <div class="dua-card bg-white dark:bg-slate-800 rounded-3xl p-6 sm:p-8 shadow-sm border border-slate-200/60 dark:border-slate-700 hover:shadow-lg hover:border-primary/30 dark:hover:border-primary/30 transition-all">
                        <!-- Dua Number -->
                        <div class="flex items-center justify-between mb-6">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center border border-primary/20">
                                    <span class="text-lg font-bold text-primary">${index + 1}</span>
                                </div>
                                ${dua.count && dua.count !== '1' ? `
                                    <div class="flex items-center gap-2 px-3 py-1.5 bg-slate-100 dark:bg-slate-900 rounded-lg">
                                        <iconify-icon icon="solar:refresh-linear" width="16" height="16" class="text-slate-500 dark:text-slate-400"></iconify-icon>
                                        <span class="text-sm font-medium text-slate-600 dark:text-slate-400">يُكرر ${dua.count} ${dua.count === '3' ? 'مرات' : 'مرة'}</span>
                                    </div>
                                ` : ''}
                            </div>

                            <button onclick="copyDua('${dua.text_ar.replace(/'/g, "\\'")}', ${index})" class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-900 flex items-center justify-center text-slate-400 hover:bg-primary/10 hover:text-primary transition-colors" title="نسخ">
                                <iconify-icon icon="solar:copy-linear" width="20" height="20"></iconify-icon>
                            </button>
                        </div>

                        <!-- Arabic Text -->
                        <div class="mb-6 p-6 bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 rounded-2xl">
                            <p class="text-2xl sm:text-3xl font-arabic leading-loose text-slate-800 dark:text-slate-200 text-center" style="font-family: 'Amiri', serif;">
                                ${dua.text_ar}
                            </p>
                        </div>

                        <!-- Translation (if available) -->
                        ${dua.translation_ar ? `
                            <div class="mb-4 p-4 bg-amber-50 dark:bg-amber-900/10 rounded-xl border border-amber-100 dark:border-amber-900/20">
                                <div class="flex items-center gap-2 mb-2">
                                    <iconify-icon icon="solar:document-text-linear" width="18" height="18" class="text-amber-600 dark:text-amber-400"></iconify-icon>
                                    <span class="text-sm font-bold text-amber-800 dark:text-amber-400">المعنى:</span>
                                </div>
                                <p class="text-base text-amber-900 dark:text-amber-300 leading-relaxed">
                                    ${dua.translation_ar}
                                </p>
                            </div>
                        ` : ''}

                        <!-- Reference (if available) -->
                        ${dua.reference ? `
                            <div class="flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400">
                                <iconify-icon icon="solar:bookmark-linear" width="16" height="16"></iconify-icon>
                                <span>${dua.reference}</span>
                            </div>
                        ` : ''}
                    </div>
                `).join('')}
            </div>

            <!-- Audio Player (hidden) -->
            <audio id="chapterAudio" class="hidden"></audio>
        `;

        chapterContent.innerHTML = html;

    } catch (error) {
        console.error('Error loading chapter:', error);
        loadingState.classList.add('hidden');
        errorState.classList.remove('hidden');
    }
});

// Play audio function
function playAudio(url) {
    const audio = document.getElementById('chapterAudio');
    if (audio.src === url && !audio.paused) {
        audio.pause();
    } else {
        audio.src = url;
        audio.play();
    }
}

// Copy dua function
function copyDua(text, index) {
    navigator.clipboard.writeText(text).then(() => {
        // Show success feedback
        const button = event.target.closest('button');
        const icon = button.querySelector('iconify-icon');
        icon.setAttribute('icon', 'solar:check-circle-bold');
        button.classList.add('text-green-500');

        setTimeout(() => {
            icon.setAttribute('icon', 'solar:copy-linear');
            button.classList.remove('text-green-500');
        }, 2000);
    });
}
</script>
@endpush
@endsection
