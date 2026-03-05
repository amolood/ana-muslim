@extends('layouts.web', ['title' => 'سياسة الخصوصية - أنا المسلم', 'description' => 'سياسة الخصوصية لتطبيق أنا المسلم - حماية بياناتك الشخصية'])

@push('styles')
<style>
    .section-line {
        border-top: 1px solid rgba(148, 163, 184, 0.1);
    }
</style>
@endpush

@section('content')
<div x-data="privacyApp()">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <div class="max-w-3xl mx-auto px-4 pt-32 pb-24 relative z-10">
        <!-- Header -->
        <div class="text-center mb-12">
            <div class="inline-flex items-center justify-center mb-6">
                <img src="{{ \App\Models\AnaMuslimSetting::getValue('app_logo', asset('assets/anaalmuslim.svg')) }}"
                     alt="I'm Muslim Logo"
                     class="h-20 w-auto">
            </div>
            <h1 class="text-3xl md:text-4xl font-bold mb-3 text-slate-900 dark:text-white">سياسة الخصوصية</h1>
            <p class="text-slate-500 dark:text-slate-400">تطبيق أنا المسلم — آخر تحديث: 24 فبراير 2026</p>
        </div>

        <!-- Content card -->
        <div class="glass-panel rounded-[2rem] p-8 md:p-12 space-y-8">
            <p class="text-slate-800 dark:text-slate-300 leading-relaxed text-lg font-medium">
                خصوصيتك تهمنا جداً. في تطبيق "أنا المسلم"، نحن ملتزمون بحماية بياناتك الشخصية وتوضح كيفية استخدامها لمساعدتك في أداء عباداتك اليومية.
            </p>

            <!-- Section 1 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:database-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">١. المعلومات التي نجمعها</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed font-medium">نحن لا نجمع أي بيانات شخصية يمكن أن تحدد هويتك (مثل الاسم أو البريد الإلكتروني) دون إذن صريح منك.</p>
            </div>

            <!-- Section 2 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:map-point-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٢. استخدام الموقع الجغرافي</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed mb-4">يحتاج التطبيق للوصول إلى موقعك الجغرافي (GPS) للقيام بالوظائف التالية فقط:</p>
                <ul class="space-y-2 text-slate-700 dark:text-slate-400">
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        حساب أوقات الصلاة بدقة حسب مدينتك وموقعك الحالي.
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        تحديد اتجاه القبلة بدقة.
                    </li>
                </ul>
                <div class="mt-4 flex items-start gap-3 p-4 bg-primary/5 rounded-xl border border-primary/10">
                    <iconify-icon icon="solar:info-circle-linear" class="text-primary text-xl shrink-0 mt-0.5"></iconify-icon>
                    <p class="text-sm text-slate-700 dark:text-slate-400">يتم معالجة بيانات الموقع محلياً على جهازك ولا نقوم بتخزينها أو مشاركتها مع أي طرف ثالث على خوادمنا.</p>
                </div>
            </div>

            <!-- Section 3 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:bell-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٣. الإشعارات والتنبيهات</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">يستخدم التطبيق تنبيهات النظام لإرسال إشعارات الأذان والأذكار. يمكنك التحكم الكامل في هذه التنبيهات من خلال إعدادات التطبيق أو إعدادات النظام في هاتفك.</p>
            </div>

            <!-- Section 4 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:shield-check-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٤. مشاركة البيانات مع أطراف ثالثة</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">نحن <span class="text-slate-900 dark:text-white font-semibold">لا نبيع</span>، ولا نتبادل، ولا نشارك أي بيانات للمستخدمين مع شركات أو جهات خارجية لأغراض تسويقية أو تجارية.</p>
            </div>

            <!-- Section 5 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:user-check-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٥. حقوقك</h2>
                </div>
                <ul class="space-y-2 text-slate-700 dark:text-slate-400">
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        سحب أذونات الموقع في أي وقت من إعدادات جهازك.
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        إيقاف جميع الإشعارات.
                    </li>
                    <li class="flex items-start gap-2">
                        <iconify-icon icon="solar:check-circle-linear" class="text-primary mt-0.5 shrink-0"></iconify-icon>
                        استخدام التطبيق بشكل كامل دون الحاجة لإنشاء حساب أو تقديم بيانات شخصية.
                    </li>
                </ul>
            </div>

            <!-- Section 6 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:phone-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٦. التواصل معنا</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">إذا كان لديك أي استفسارات حول سياسة الخصوصية أو كيفية استخدام بياناتك، يمكنك التواصل معنا عبر:</p>
                <div class="mt-3 flex items-center gap-2 text-primary">
                    <iconify-icon icon="solar:letter-linear" class="text-lg"></iconify-icon>
                    <a href="mailto:privacy@anamuslim.app" class="hover:underline">privacy@anamuslim.app</a>
                </div>
            </div>

            <!-- Section 7 -->
            <div class="section-line pt-8">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                        <iconify-icon icon="solar:refresh-linear" class="text-primary text-lg"></iconify-icon>
                    </div>
                    <h2 class="text-xl font-bold text-slate-900 dark:text-white">٧. التحديثات على السياسة</h2>
                </div>
                <p class="text-slate-700 dark:text-slate-400 leading-relaxed">قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سيتم إعلامك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني المُسجل (إن وجد).</p>
            </div>

            <!-- Footer inside card -->
            <div class="section-line pt-8 text-center">
                <span class="text-sm text-slate-500 dark:text-slate-400">© 2026 أنا المسلم. جميع الحقوق محفوظة.</span>
            </div>
        </div>

        <!-- Back button -->
        <div class="mt-8 text-center">
            <a href="{{ url('/') }}" class="inline-flex items-center gap-2 text-sm text-slate-400 hover:text-primary transition-colors">
                <iconify-icon icon="solar:arrow-right-linear"></iconify-icon>
                العودة إلى الصفحة الرئيسية
            </a>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    function privacyApp() {
        return {
            locale: localStorage.getItem('locale') || 'ar'
        }
    }
</script>
@endpush
