{{-- Footer --}}
<footer class="relative mt-20 bg-slate-900 dark:bg-black text-white pt-16 pb-8 overflow-hidden">
    {{-- Background Pattern --}}
    <div class="absolute inset-0 opacity-5">
        <div class="absolute inset-0" style="background-image: radial-gradient(circle at 2px 2px, white 1px, transparent 0); background-size: 40px 40px;"></div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {{-- Main Footer Content --}}
        <div class="grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
            {{-- Brand Section --}}
            <div class="md:col-span-2">
                <div class="flex items-center gap-3 mb-4">
                    <img src="{{ asset('assets/logo.svg') }}" alt="I'm Muslim Logo" class="h-12 w-auto">
                    <span class="text-2xl font-bold tracking-tight" x-text="t('brand.name')"></span>
                </div>
                <p class="text-slate-400 text-sm leading-relaxed mb-6" x-text="t('footer.description')">
                </p>

                {{-- Social Links --}}
                <div class="flex items-center gap-3">
                    <a href="#" class="w-10 h-10 rounded-full bg-white/10 hover:bg-primary/20 flex items-center justify-center transition-all hover:scale-110">
                        <iconify-icon icon="ri:twitter-x-fill" class="text-lg"></iconify-icon>
                    </a>
                    <a href="#" class="w-10 h-10 rounded-full bg-white/10 hover:bg-primary/20 flex items-center justify-center transition-all hover:scale-110">
                        <iconify-icon icon="mdi:instagram" class="text-lg"></iconify-icon>
                    </a>
                    <a href="#" class="w-10 h-10 rounded-full bg-white/10 hover:bg-primary/20 flex items-center justify-center transition-all hover:scale-110">
                        <iconify-icon icon="mdi:facebook" class="text-lg"></iconify-icon>
                    </a>
                    <a href="#" class="w-10 h-10 rounded-full bg-white/10 hover:bg-primary/20 flex items-center justify-center transition-all hover:scale-110">
                        <iconify-icon icon="mdi:youtube" class="text-lg"></iconify-icon>
                    </a>
                </div>
            </div>

            {{-- Quick Links --}}
            <div>
                <h3 class="text-lg font-bold mb-4" x-text="t('footer.quickLinks')"></h3>
                <ul class="space-y-3 text-sm">
                    <li>
                        <a href="{{ url('/') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:home-2-bold" class="text-base"></iconify-icon>
                            <span x-text="t('nav.home')"></span>
                        </a>
                    </li>
                    <li>
                        <a href="{{ url('/quran-premium') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:book-2-bold" class="text-base"></iconify-icon>
                            <span x-text="t('nav.quranPremium')"></span>
                        </a>
                    </li>
                    <li>
                        <a href="{{ url('/hisnmuslim') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:shield-star-bold" class="text-base"></iconify-icon>
                            <span x-text="t('nav.hisnmuslim')"></span>
                        </a>
                    </li>
                </ul>
            </div>

            {{-- Legal & Support --}}
            <div>
                <h3 class="text-lg font-bold mb-4" x-text="t('footer.legalSupport')"></h3>
                <ul class="space-y-3 text-sm">
                    <li>
                        <a href="{{ url('/privacy') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:shield-check-bold" class="text-base"></iconify-icon>
                            <span x-text="t('footer.privacy')"></span>
                        </a>
                    </li>
                    <li>
                        <a href="{{ url('/terms') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:document-text-bold" class="text-base"></iconify-icon>
                            <span x-text="t('footer.terms')"></span>
                        </a>
                    </li>
                    <li>
                        <a href="{{ url('/contact') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:letter-bold" class="text-base"></iconify-icon>
                            <span x-text="t('footer.contact')"></span>
                        </a>
                    </li>
                    <li>
                        <a href="{{ url('/faq') }}" class="text-slate-400 hover:text-primary transition-colors flex items-center gap-2">
                            <iconify-icon icon="solar:question-circle-bold" class="text-base"></iconify-icon>
                            <span x-text="t('footer.faq')"></span>
                        </a>
                    </li>
                </ul>
            </div>
        </div>

        {{-- Download Section --}}
        <div class="border-t border-white/10 pt-8 pb-8">
            <div class="flex flex-col md:flex-row items-center justify-between gap-6">
                <div>
                    <h4 class="text-lg font-bold mb-2" x-text="t('footer.downloadApp')"></h4>
                    <p class="text-slate-400 text-sm" x-text="t('footer.availableOn')"></p>
                </div>
                <div class="flex flex-wrap gap-4">
                    <a href="#" class="flex items-center gap-3 bg-white/10 hover:bg-white/20 px-6 py-3 rounded-2xl transition-all hover:scale-105">
                        <iconify-icon icon="logos:google-play-icon" class="text-2xl"></iconify-icon>
                        <div :class="locale === 'ar' ? 'text-right' : 'text-left'">
                            <div class="text-xs text-slate-400" x-text="t('footer.availableOnStore')"></div>
                            <div class="text-sm font-bold">Google Play</div>
                        </div>
                    </a>
                    <a href="#" class="flex items-center gap-3 bg-white/10 hover:bg-white/20 px-6 py-3 rounded-2xl transition-all hover:scale-105">
                        <iconify-icon icon="logos:apple-app-store" class="text-2xl"></iconify-icon>
                        <div :class="locale === 'ar' ? 'text-right' : 'text-left'">
                            <div class="text-xs text-slate-400" x-text="t('footer.availableOnStore')"></div>
                            <div class="text-sm font-bold">App Store</div>
                        </div>
                    </a>
                </div>
            </div>
        </div>

        {{-- Bottom Footer --}}
        <div class="border-t border-white/10 pt-8">
            <div class="flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-slate-400">
                <p x-text="'© {{ date('Y') }} ' + t('brand.name') + '. ' + t('footer.rights')">
                </p>
                <p class="flex items-center gap-2">
                    <iconify-icon icon="solar:heart-bold" class="text-red-500"></iconify-icon>
                    <span x-text="t('footer.madeWithLove')"></span>
                </p>
            </div>
        </div>
    </div>
</footer>
