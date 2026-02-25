@extends('layouts.web', ['title' => 'تواصل معنا - أنا المسلم', 'description' => 'تواصل مع فريق تطبيق أنا المسلم'])

@push('styles')
<style>
    .contact-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .contact-card:hover {
        transform: translateY(-4px);
    }
</style>
@endpush

@section('content')
<div x-data="contactApp()">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <div class="max-w-5xl mx-auto px-4 pt-32 pb-24 relative z-10">
        <!-- Header -->
        <div class="text-center mb-16">
            <div class="inline-flex items-center justify-center w-20 h-20 mb-6 rounded-2xl bg-gradient-to-br from-primary to-emerald-500 shadow-lg">
                <iconify-icon icon="solar:letter-bold-duotone" class="text-5xl text-white"></iconify-icon>
            </div>
            <h1 class="text-4xl md:text-5xl font-bold mb-4 text-slate-900 dark:text-white">تواصل معنا</h1>
            <p class="text-lg text-slate-600 dark:text-slate-400 max-w-2xl mx-auto">
                نحن هنا للإجابة على استفساراتك ومساعدتك. تواصل معنا عبر إحدى القنوات التالية
            </p>
        </div>

        <!-- Contact Methods Grid -->
        <div class="grid md:grid-cols-3 gap-6 mb-16">
            <!-- Email -->
            <div class="contact-card glass-panel rounded-2xl p-8 text-center">
                <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-primary/10 flex items-center justify-center">
                    <iconify-icon icon="solar:letter-bold-duotone" class="text-3xl text-primary"></iconify-icon>
                </div>
                <h3 class="text-lg font-bold text-slate-900 dark:text-white mb-2">البريد الإلكتروني</h3>
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-4">راسلنا عبر البريد الإلكتروني</p>
                <a href="mailto:support@anaalmuslim.com" class="text-primary hover:text-primary-700 font-bold inline-flex items-center gap-2">
                    <span>support@anaalmuslim.com</span>
                    <iconify-icon icon="solar:arrow-left-linear" class="text-lg"></iconify-icon>
                </a>
            </div>

            <!-- GitHub -->
            <div class="contact-card glass-panel rounded-2xl p-8 text-center">
                <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-slate-900/10 dark:bg-white/10 flex items-center justify-center">
                    <iconify-icon icon="bi:github" class="text-3xl text-slate-900 dark:text-white"></iconify-icon>
                </div>
                <h3 class="text-lg font-bold text-slate-900 dark:text-white mb-2">GitHub</h3>
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-4">تقارير المشاكل والمقترحات</p>
                <a href="https://github.com/amolood/ana-muslim" target="_blank" rel="noopener" class="text-primary hover:text-primary-700 font-bold inline-flex items-center gap-2">
                    <span>فتح Issue</span>
                    <iconify-icon icon="solar:arrow-left-linear" class="text-lg"></iconify-icon>
                </a>
            </div>

            <!-- Social Media -->
            <div class="contact-card glass-panel rounded-2xl p-8 text-center">
                <div class="w-16 h-16 mx-auto mb-4 rounded-xl bg-blue-500/10 flex items-center justify-center">
                    <iconify-icon icon="solar:chat-round-dots-bold-duotone" class="text-3xl text-blue-500"></iconify-icon>
                </div>
                <h3 class="text-lg font-bold text-slate-900 dark:text-white mb-2">وسائل التواصل</h3>
                <p class="text-sm text-slate-600 dark:text-slate-400 mb-4">تابعنا على مواقع التواصل</p>
                <div class="flex items-center justify-center gap-3">
                    <a href="#" class="w-10 h-10 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center hover:bg-primary/10 transition-colors">
                        <iconify-icon icon="bi:twitter-x" class="text-xl text-slate-700 dark:text-slate-300"></iconify-icon>
                    </a>
                    <a href="#" class="w-10 h-10 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center hover:bg-primary/10 transition-colors">
                        <iconify-icon icon="bi:facebook" class="text-xl text-slate-700 dark:text-slate-300"></iconify-icon>
                    </a>
                    <a href="#" class="w-10 h-10 rounded-lg bg-slate-100 dark:bg-slate-800 flex items-center justify-center hover:bg-primary/10 transition-colors">
                        <iconify-icon icon="bi:instagram" class="text-xl text-slate-700 dark:text-slate-300"></iconify-icon>
                    </a>
                </div>
            </div>
        </div>

        <!-- Contact Form -->
        <div class="glass-panel rounded-[2rem] p-8 md:p-12">
            <div class="max-w-2xl mx-auto">
                <h2 class="text-2xl font-bold text-slate-900 dark:text-white mb-2 text-center">أرسل رسالة</h2>
                <p class="text-slate-600 dark:text-slate-400 mb-8 text-center">
                    املأ النموذج أدناه وسنرد عليك في أقرب وقت ممكن
                </p>

                <form @submit.prevent="submitForm" class="space-y-6">
                    <!-- Name -->
                    <div>
                        <label for="name" class="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">
                            الاسم الكامل
                        </label>
                        <input type="text"
                               id="name"
                               x-model="form.name"
                               required
                               class="w-full px-4 py-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-slate-900 dark:text-white"
                               placeholder="أدخل اسمك الكامل">
                    </div>

                    <!-- Email -->
                    <div>
                        <label for="email" class="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">
                            البريد الإلكتروني
                        </label>
                        <input type="email"
                               id="email"
                               x-model="form.email"
                               required
                               class="w-full px-4 py-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-slate-900 dark:text-white"
                               placeholder="example@email.com">
                    </div>

                    <!-- Subject -->
                    <div>
                        <label for="subject" class="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">
                            الموضوع
                        </label>
                        <select id="subject"
                                x-model="form.subject"
                                required
                                class="w-full px-4 py-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-slate-900 dark:text-white">
                            <option value="">اختر الموضوع</option>
                            <option value="bug">الإبلاغ عن مشكلة</option>
                            <option value="feature">اقتراح ميزة جديدة</option>
                            <option value="support">طلب دعم فني</option>
                            <option value="feedback">ملاحظات وتقييم</option>
                            <option value="other">أخرى</option>
                        </select>
                    </div>

                    <!-- Message -->
                    <div>
                        <label for="message" class="block text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">
                            الرسالة
                        </label>
                        <textarea id="message"
                                  x-model="form.message"
                                  required
                                  rows="6"
                                  class="w-full px-4 py-3 rounded-xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-slate-900 dark:text-white resize-none"
                                  placeholder="اكتب رسالتك هنا..."></textarea>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit"
                            :disabled="submitting"
                            class="w-full py-4 bg-gradient-to-r from-primary to-emerald-500 text-white font-bold rounded-xl hover:shadow-lg hover:shadow-primary/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                        <template x-if="!submitting">
                            <span>إرسال الرسالة</span>
                        </template>
                        <template x-if="submitting">
                            <span>جاري الإرسال...</span>
                        </template>
                        <iconify-icon icon="solar:arrow-left-linear" class="text-xl"></iconify-icon>
                    </button>

                    <!-- Success Message -->
                    <div x-show="success"
                         x-transition
                         class="p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl flex items-center gap-3">
                        <iconify-icon icon="solar:check-circle-bold" class="text-2xl text-green-600"></iconify-icon>
                        <p class="text-green-800 dark:text-green-200 font-medium">تم إرسال رسالتك بنجاح! سنتواصل معك قريباً.</p>
                    </div>

                    <!-- Error Message -->
                    <div x-show="error"
                         x-transition
                         class="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl flex items-center gap-3">
                        <iconify-icon icon="solar:danger-circle-bold" class="text-2xl text-red-600"></iconify-icon>
                        <p class="text-red-800 dark:text-red-200 font-medium">حدث خطأ أثناء الإرسال. يرجى المحاولة مرة أخرى.</p>
                    </div>
                </form>
            </div>
        </div>

        <!-- FAQ Link -->
        <div class="mt-12 text-center">
            <p class="text-slate-600 dark:text-slate-400 mb-4">
                هل تبحث عن إجابة سريعة؟
            </p>
            <a href="{{ url('/faq') }}" class="inline-flex items-center gap-2 px-6 py-3 bg-white dark:bg-slate-800 rounded-xl border border-slate-200 dark:border-slate-700 hover:border-primary transition-all font-bold text-slate-900 dark:text-white">
                <iconify-icon icon="solar:question-circle-bold-duotone" class="text-2xl text-primary"></iconify-icon>
                <span>تصفح الأسئلة الشائعة</span>
                <iconify-icon icon="solar:arrow-left-linear" class="text-lg"></iconify-icon>
            </a>
        </div>
    </div>
</div>

<script>
function contactApp() {
    return {
        ...i18n(),
        form: {
            name: '',
            email: '',
            subject: '',
            message: ''
        },
        submitting: false,
        success: false,
        error: false,

        async submitForm() {
            this.submitting = true;
            this.success = false;
            this.error = false;

            // Simulate form submission (replace with actual API call)
            try {
                await new Promise(resolve => setTimeout(resolve, 1500));

                // Success
                this.success = true;
                this.form = {
                    name: '',
                    email: '',
                    subject: '',
                    message: ''
                };

                // Hide success message after 5 seconds
                setTimeout(() => {
                    this.success = false;
                }, 5000);
            } catch (err) {
                this.error = true;

                // Hide error message after 5 seconds
                setTimeout(() => {
                    this.error = false;
                }, 5000);
            } finally {
                this.submitting = false;
            }
        }
    }
}
</script>
@endsection
