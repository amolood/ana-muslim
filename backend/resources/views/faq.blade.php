@extends('layouts.web', ['title' => 'الأسئلة الشائعة - أنا المسلم', 'description' => 'الأسئلة الشائعة حول تطبيق أنا المسلم'])

@push('styles')
<style>
    .faq-item {
        transition: all 0.3s ease;
    }
</style>
@endpush

@section('content')
<div x-data="faqApp()">
    <!-- Ambient Background Gradients -->
    <div class="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div class="absolute -top-[20%] -right-[10%] w-[60vw] h-[60vw] rounded-full bg-primary/10 dark:bg-primary/10 blur-[120px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
        <div class="absolute top-[40%] -left-[20%] w-[50vw] h-[50vw] rounded-full bg-blue-400/10 dark:bg-blue-900/10 blur-[100px] mix-blend-multiply dark:mix-blend-screen transition-all duration-1000"></div>
    </div>

    <div class="max-w-4xl mx-auto px-4 pt-32 pb-24 relative z-10">
        <!-- Header -->
        <div class="text-center mb-16">
            <div class="inline-flex items-center justify-center w-20 h-20 mb-6 rounded-2xl bg-gradient-to-br from-primary to-emerald-500 shadow-lg">
                <iconify-icon icon="solar:question-circle-bold-duotone" class="text-5xl text-white"></iconify-icon>
            </div>
            <h1 class="text-4xl md:text-5xl font-bold mb-4 text-slate-900 dark:text-white">الأسئلة الشائعة</h1>
            <p class="text-lg text-slate-600 dark:text-slate-400 max-w-2xl mx-auto">
                إجابات سريعة على الأسئلة الأكثر شيوعاً حول تطبيق أنا المسلم
            </p>
        </div>

        <!-- Search Box -->
        <div class="mb-12">
            <div class="relative">
                <iconify-icon icon="solar:magnifer-linear" class="absolute right-4 top-1/2 -translate-y-1/2 text-xl text-slate-400"></iconify-icon>
                <input type="text"
                       x-model="searchQuery"
                       placeholder="ابحث في الأسئلة الشائعة..."
                       class="w-full px-4 pr-12 py-4 rounded-2xl bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-slate-900 dark:text-white">
            </div>
        </div>

        <!-- Categories -->
        <div class="flex flex-wrap gap-3 mb-12 justify-center">
            <button @click="selectedCategory = 'all'"
                    :class="selectedCategory === 'all' ? 'bg-primary text-white' : 'bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300'"
                    class="px-6 py-2 rounded-full font-bold border border-slate-200 dark:border-slate-700 hover:border-primary transition-all">
                الكل
            </button>
            <button @click="selectedCategory = 'app'"
                    :class="selectedCategory === 'app' ? 'bg-primary text-white' : 'bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300'"
                    class="px-6 py-2 rounded-full font-bold border border-slate-200 dark:border-slate-700 hover:border-primary transition-all">
                التطبيق
            </button>
            <button @click="selectedCategory = 'features'"
                    :class="selectedCategory === 'features' ? 'bg-primary text-white' : 'bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300'"
                    class="px-6 py-2 rounded-full font-bold border border-slate-200 dark:border-slate-700 hover:border-primary transition-all">
                الميزات
            </button>
            <button @click="selectedCategory = 'technical'"
                    :class="selectedCategory === 'technical' ? 'bg-primary text-white' : 'bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-300'"
                    class="px-6 py-2 rounded-full font-bold border border-slate-200 dark:border-slate-700 hover:border-primary transition-all">
                الدعم الفني
            </button>
        </div>

        <!-- FAQ Items -->
        <div class="space-y-4">
            <template x-for="(faq, index) in filteredFaqs" :key="index">
                <div class="faq-item glass-panel rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-700 hover:border-primary/30 transition-all">
                    <button @click="toggleFaq(index)"
                            class="w-full px-6 py-5 flex items-center justify-between text-right hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                        <div class="flex items-start gap-4 flex-1">
                            <div class="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                                 :class="openFaq === index ? 'bg-primary/10' : 'bg-slate-100 dark:bg-slate-800'">
                                <iconify-icon icon="solar:question-circle-bold"
                                              :class="openFaq === index ? 'text-primary' : 'text-slate-400'"
                                              class="text-xl"></iconify-icon>
                            </div>
                            <h3 class="text-lg font-bold text-slate-900 dark:text-white text-right flex-1"
                                x-text="faq.question"></h3>
                        </div>
                        <iconify-icon icon="solar:alt-arrow-down-bold"
                                      :class="openFaq === index ? 'rotate-180' : ''"
                                      class="text-2xl text-slate-400 transition-transform shrink-0"></iconify-icon>
                    </button>

                    <div x-show="openFaq === index"
                         x-collapse
                         class="px-6 pb-6">
                        <div class="pr-14 text-slate-700 dark:text-slate-300 leading-relaxed"
                             x-html="faq.answer"></div>
                    </div>
                </div>
            </template>
        </div>

        <!-- Empty State -->
        <div x-show="filteredFaqs.length === 0" class="text-center py-16">
            <iconify-icon icon="solar:magnifer-bug-linear" class="text-7xl text-slate-300 dark:text-slate-700 mb-4"></iconify-icon>
            <p class="text-xl font-bold text-slate-700 dark:text-slate-300 mb-2">لم نجد نتائج</p>
            <p class="text-slate-500 dark:text-slate-400">جرب البحث بكلمات مختلفة</p>
        </div>

        <!-- Contact CTA -->
        <div class="mt-16 text-center glass-panel rounded-2xl p-8">
            <iconify-icon icon="solar:chat-round-dots-bold-duotone" class="text-5xl text-primary mb-4"></iconify-icon>
            <h3 class="text-2xl font-bold text-slate-900 dark:text-white mb-3">لم تجد إجابة لسؤالك؟</h3>
            <p class="text-slate-600 dark:text-slate-400 mb-6">فريقنا مستعد لمساعدتك في أي استفسار</p>
            <a href="{{ url('/contact') }}"
               class="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-primary to-emerald-500 text-white font-bold rounded-xl hover:shadow-lg hover:shadow-primary/20 transition-all">
                <span>تواصل معنا</span>
                <iconify-icon icon="solar:arrow-left-linear" class="text-xl"></iconify-icon>
            </a>
        </div>
    </div>
</div>

<script>
function faqApp() {
    return {
        ...i18n(),
        searchQuery: '',
        selectedCategory: 'all',
        openFaq: null,
        faqs: [
            {
                category: 'app',
                question: 'ما هو تطبيق أنا المسلم؟',
                answer: 'تطبيق أنا المسلم هو تطبيق إسلامي شامل يجمع بين القرآن الكريم، الأذكار، الأحاديث النبوية، مواقيت الصلاة، اتجاه القبلة، والتقويم الهجري في مكان واحد. تم تصميمه بواجهة عصرية وسهلة الاستخدام لمساعدة المسلمين في أداء عباداتهم اليومية.'
            },
            {
                category: 'app',
                question: 'هل التطبيق مجاني؟',
                answer: 'نعم، تطبيق أنا المسلم مجاني بالكامل ولا يحتوي على أي إعلانات. نؤمن بأن الوصول إلى المحتوى الإسلامي يجب أن يكون متاحاً للجميع دون أي تكلفة.'
            },
            {
                category: 'app',
                question: 'على أي منصات يتوفر التطبيق؟',
                answer: 'التطبيق متوفر حالياً على:<br>• <strong>أندرويد</strong> - متوفر على Google Play<br>• <strong>iOS</strong> - قريباً على App Store<br>• <strong>الويب</strong> - يمكن الوصول إليه عبر المتصفح على <a href="https://anaalmuslim.com" class="text-primary hover:underline">anaalmuslim.com</a>'
            },
            {
                category: 'features',
                question: 'ما هي الميزات الرئيسية للتطبيق؟',
                answer: 'التطبيق يوفر:<br>• <strong>القرآن الكريم</strong> - قراءة واستماع مع تلاوات متعددة<br>• <strong>مواقيت الصلاة</strong> - حساب دقيق حسب موقعك<br>• <strong>حصن المسلم</strong> - أذكار وأدعية يومية<br>• <strong>القبلة</strong> - تحديد دقيق لاتجاه الكعبة<br>• <strong>التقويم الهجري</strong> - متابعة الأيام والمناسبات الإسلامية'
            },
            {
                category: 'features',
                question: 'هل يمكنني استخدام التطبيق بدون إنترنت؟',
                answer: 'معظم الميزات تتطلب اتصال بالإنترنت للمرة الأولى لتحميل المحتوى. بعد التحميل، يمكن استخدام بعض الميزات مثل قراءة القرآن والأذكار بدون إنترنت. ننصح بتحميل المحتوى الذي تحتاجه مسبقاً.'
            },
            {
                category: 'features',
                question: 'كيف أغير القارئ في تلاوة القرآن؟',
                answer: 'يمكنك تغيير القارئ من خلال:<br>١. افتح صفحة القرآن<br>٢. اضغط على أيقونة الإعدادات أو القارئ الحالي<br>٣. اختر القارئ المفضل من القائمة<br>٤. يتم حفظ اختيارك تلقائياً للمرات القادمة'
            },
            {
                category: 'technical',
                question: 'أوقات الصلاة غير دقيقة في منطقتي، ماذا أفعل؟',
                answer: 'يمكنك تحسين دقة أوقات الصلاة من خلال:<br>• تفعيل <strong>GPS</strong> للحصول على موقع دقيق<br>• اختيار المدينة يدوياً من الإعدادات<br>• التحقق من <strong>طريقة الحساب</strong> المستخدمة (يمكن تغييرها من الإعدادات)<br>• الرجوع إلى المسجد المحلي للتأكد من الأوقات الدقيقة في منطقتك'
            },
            {
                category: 'technical',
                question: 'التطبيق لا يعمل بشكل صحيح، كيف أحل المشكلة؟',
                answer: 'جرب الخطوات التالية:<br>١. تأكد من تحديث التطبيق لآخر إصدار<br>٢. أعد تشغيل التطبيق<br>٣. امسح الذاكرة المؤقتة (Cache)<br>٤. تحقق من اتصال الإنترنت<br>٥. إذا استمرت المشكلة، <a href="/contact" class="text-primary hover:underline">تواصل معنا</a> وصف المشكلة بالتفصيل'
            },
            {
                category: 'technical',
                question: 'كيف أفعّل الإشعارات لأوقات الصلاة؟',
                answer: 'لتفعيل إشعارات الصلاة:<br>١. افتح إعدادات التطبيق<br>٢. اذهب إلى قسم "الإشعارات"<br>٣. فعّل "إشعارات الصلاة"<br>٤. اختر نوع الصوت المفضل للأذان<br>٥. تأكد من السماح للتطبيق بإرسال الإشعارات من إعدادات الجهاز'
            },
            {
                category: 'features',
                question: 'هل يمكنني حفظ آيات معينة كمفضلة؟',
                answer: 'نعم! يمكنك إضافة علامات مرجعية للآيات من خلال:<br>١. افتح السورة التي تريدها<br>٢. اضغط على أيقونة المفضلة (⭐) بجانب الآية<br>٣. يمكنك الوصول لجميع المفضلات من قائمة "العلامات المرجعية"<br>٤. يتم حفظ المفضلات على جهازك ولا تُحذف عند إغلاق التطبيق'
            },
            {
                category: 'app',
                question: 'هل البيانات الشخصية آمنة؟',
                answer: 'نعم، خصوصيتك مهمة جداً لنا:<br>• لا نجمع أي بيانات شخصية<br>• بيانات الموقع تُستخدم فقط لحساب أوقات الصلاة ولا تُخزّن<br>• جميع الإعدادات والمفضلات تُحفظ محلياً على جهازك<br>• لا نشارك أي معلومات مع أطراف ثالثة<br>للمزيد، راجع <a href="/privacy" class="text-primary hover:underline">سياسة الخصوصية</a>'
            },
            {
                category: 'technical',
                question: 'كيف أبلغ عن مشكلة أو أقترح ميزة جديدة؟',
                answer: 'نحب أن نسمع منك! يمكنك:<br>• زيارة <a href="/contact" class="text-primary hover:underline">صفحة التواصل</a> وملء النموذج<br>• إرسال بريد إلكتروني على support@anaalmuslim.com<br>• فتح Issue على <a href="https://github.com/molood/im-muslim" target="_blank" class="text-primary hover:underline">GitHub</a><br>نقرأ جميع الاقتراحات والملاحظات ونعمل على تحسين التطبيق باستمرار'
            },
            {
                category: 'features',
                question: 'هل يدعم التطبيق اللغة الإنجليزية؟',
                answer: 'نعم، التطبيق يدعم اللغتين العربية والإنجليزية. يمكنك تغيير اللغة من:<br>• أيقونة اللغة في أعلى الصفحة (AR/EN)<br>• يتم تطبيق اللغة المختارة على جميع الصفحات<br>• يتم حفظ اختيارك تلقائياً'
            }
        ],

        get filteredFaqs() {
            let filtered = this.faqs;

            // Filter by category
            if (this.selectedCategory !== 'all') {
                filtered = filtered.filter(faq => faq.category === this.selectedCategory);
            }

            // Filter by search query
            if (this.searchQuery.trim()) {
                const query = this.searchQuery.toLowerCase();
                filtered = filtered.filter(faq =>
                    faq.question.toLowerCase().includes(query) ||
                    faq.answer.toLowerCase().includes(query)
                );
            }

            return filtered;
        },

        toggleFaq(index) {
            this.openFaq = this.openFaq === index ? null : index;
        }
    }
}
</script>
@endsection
