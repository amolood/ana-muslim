@extends('layouts.web', ['title' => 'شروط الاستخدام - أنا المسلم', 'description' => 'شروط وأحكام استخدام تطبيق أنا المسلم'])

@push('styles')
<style>
    .section-line {
        border-top: 1px solid rgba(148, 163, 184, 0.1);
    }
</style>
@endpush

@section('content')
<div x-data="termsApp()">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <div class="max-w-3xl mx-auto px-4 pt-32 pb-24 relative z-10">
        <!-- Header -->
        <div class="text-center mb-12">
            <div class="inline-flex items-center justify-center w-18 h-18 mb-6">
                <svg width="72" height="72" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M256 42 C270 28 284 26 295 30 C282 40 276 54 278 68 C280 82 290 93 304 97 C310 99 316 99 320 98 C312 114 294 122 274 118 C251 113 238 91 242 68 C245 55 250 47 256 42Z" fill="#2d7a22"/>
                    <circle cx="256" cy="108" r="5" fill="#2d7a22"/>
                    <circle cx="256" cy="122" r="3.5" fill="#2d7a22"/>
                    <path d="M256 148 C210 148 148 192 148 268 C148 334 196 390 256 405 C316 390 364 334 364 268 C364 192 302 148 256 148Z" fill="#6abf45"/>
                    <path d="M256 148 L304 220 L256 248 L208 220 Z" fill="#2d7a22" opacity="0.85"/>
                    <path d="M256 250 C240 250 224 264 224 285 L224 370 C234 378 245 382 256 383 C267 382 278 378 288 370 L288 285 C288 264 272 250 256 250Z" fill="#020617"/>
                </svg>
            </div>
            <h1 class="text-3xl md:text-4xl font-bold mb-3 text-slate-900 dark:text-white">شروط الاستخدام</h1>
            <p class="text-slate-500 dark:text-slate-400">تطبيق أنا المسلم — آخر تحديث: 25 فبراير 2026</p>
        </div>

        <!-- Content card -->
        <div class="glass-panel rounded-[2rem] p-8 md:p-12 space-y-8">
            <p class="text-slate-800 dark:text-slate-300 leading-relaxed text-lg font-medium">
                مرحباً بك في تطبيق "أنا المسلم". باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بالشروط والأحكام التالية. يرجى قراءتها بعناية.
            </p>

            <!-- Section 1 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:document-text-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">١. قبول الشروط</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">
                    باستخدامك لتطبيق "أنا المسلم"، فإنك توافق على الالتزام بهذه الشروط والأحكام وجميع القوانين واللوائح المعمول بها. إذا كنت لا توافق على أي من هذه الشروط، يُرجى عدم استخدام التطبيق.
                </p>
            </div>

            <!-- Section 2 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:user-check-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٢. الاستخدام المسموح</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed mb-4">يُسمح لك باستخدام التطبيق للأغراض الشخصية والدينية التالية:</p>
                <ul class="space-y-2 text-slate-700 dark:text-slate-400">
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        قراءة واستماع القرآن الكريم
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        الاطلاع على أوقات الصلاة والأذكار اليومية
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        استخدام ميزات تحديد القبلة والتقويم الهجري
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        قراءة الأحاديث النبوية والأدعية من حصن المسلم
                    </li>
                </ul>
            </div>

            <!-- Section 3 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-red-500/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:danger-triangle-linear" class="text-red-600 text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٣. الاستخدام المحظور</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed mb-4">يُحظر عليك استخدام التطبيق في:</p>
                <ul class="space-y-2 text-slate-700 dark:text-slate-400">
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:close-circle-linear" class="text-red-600 mt-0.5 shrink-0"></iconify-icon>
                        أي نشاط غير قانوني أو غير أخلاقي
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:close-circle-linear" class="text-red-600 mt-0.5 shrink-0"></iconify-icon>
                        نسخ أو توزيع محتوى التطبيق دون إذن مسبق
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:close-circle-linear" class="text-red-600 mt-0.5 shrink-0"></iconify-icon>
                        محاولة اختراق أو إتلاف أو تعطيل التطبيق
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:close-circle-linear" class="text-red-600 mt-0.5 shrink-0"></iconify-icon>
                        استخدام التطبيق لأغراض تجارية دون موافقة خطية
                    </li>
                </ul>
            </div>

            <!-- Section 4 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:copyright-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٤. حقوق الملكية الفكرية</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">
                    جميع المحتويات الموجودة في التطبيق بما في ذلك النصوص، الصور، التصاميم، والأيقونات محمية بموجب حقوق الطبع والنشر. القرآن الكريم والأحاديث النبوية هي كلام الله ورسوله وهي مُتاحة للجميع، لكن التصميم والتطبيق محمي بحقوق الملكية الفكرية.
                </p>
            </div>

            <!-- Section 5 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:shield-warning-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٥. إخلاء المسؤولية</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed mb-4">
                    نسعى جاهدين لتوفير محتوى دقيق وصحيح، لكننا لا نضمن:
                </p>
                <ul class="space-y-2 text-slate-700 dark:text-slate-400">
                    <li class="flex items-start gap-2">
                        <span class="text-primary mt-0.5 shrink-0">•</span>
                        دقة حساب أوقات الصلاة بنسبة 100% (يُنصح بالتحقق من المصادر المحلية)
                    </li>
                    <li class="flex items-start gap-2">
                        <span class="text-primary mt-0.5 shrink-0">•</span>
                        دقة تحديد القبلة في جميع الظروف (قد تتأثر بدقة GPS والبيئة المحيطة)
                    </li>
                    <li class="flex items-start gap-2">
                        <span class="text-primary mt-0.5 shrink-0">•</span>
                        عمل التطبيق بشكل مستمر دون انقطاع أو أخطاء
                    </li>
                </ul>
            </div>

            <!-- Section 6 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:refresh-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٦. التحديثات والتعديلات</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">
                    نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر التطبيق. استمرارك في استخدام التطبيق بعد التعديلات يعني موافقتك على الشروط الجديدة.
                </p>
            </div>

            <!-- Section 7 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:letter-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٧. التواصل معنا</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed mb-4">
                    إذا كان لديك أي استفسار حول هذه الشروط، يمكنك التواصل معنا عبر:
                </p>
                <div class="bg-primary/5 rounded-xl p-4 border border-primary/10">
                    <a href="{{ url('/contact') }}" class="text-primary hover:text-primary-700 font-bold flex items-center gap-2">
                        <iconify-icon icon="solar:arrow-left-linear" class="text-xl"></iconify-icon>
                        صفحة التواصل
                    </a>
                </div>
            </div>

            <!-- Footer Notice -->
            <div class="mt-12 pt-8 border-t border-slate-200 dark:border-slate-700">
                <p class="text-sm text-center text-slate-500 dark:text-slate-400">
                    بتحميلك واستخدامك لتطبيق "أنا المسلم"، فإنك توافق على هذه الشروط والأحكام
                </p>
            </div>
        </div>
    </div>
</div>

<script>
function termsApp() {
    return {
        ...i18n()
    }
}
</script>
@endsection
