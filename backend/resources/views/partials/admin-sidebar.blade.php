<aside
    class="fixed right-0 top-0 z-50 flex h-screen flex-col bg-white dark:bg-[#12141c] border-l border-gray-100/80 dark:border-gray-800/50 transition-all duration-300 lg:static lg:z-auto lg:translate-x-0"
    :class="[
        sidebar.open ? 'translate-x-0' : 'translate-x-full lg:translate-x-0',
        sidebar.collapsed ? 'w-[72px]' : 'w-[260px]'
    ]" id="admin-sidebar">

    <!-- Logo -->
    <div class="flex h-16 items-center justify-between border-b border-gray-100/80 dark:border-gray-800/50 px-5">
        <div class="flex items-center gap-3">
            <div class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-emerald-600 shadow-lg shadow-emerald-500/20">
                <i class="fa-solid fa-moon text-sm text-white"></i>
            </div>
            <span class="text-base font-bold text-gray-900 dark:text-white" x-show="!sidebar.collapsed" x-transition>
                أنا مسلم
            </span>
        </div>
        <button @click="sidebar.open = false" class="lg:hidden flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
            <i class="fas fa-times"></i>
        </button>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 overflow-y-auto px-3 py-4 custom-scrollbar">
        <div class="space-y-0.5">
            {{-- Dashboard Link (always visible) --}}
            <a href="{{ route('admin.dashboard') }}"
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium transition-colors
                {{ request()->routeIs('admin.dashboard')
                    ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                    : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800/50' }}">
                <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg {{ request()->routeIs('admin.dashboard') ? 'bg-emerald-500/10 dark:bg-emerald-500/15' : 'bg-gray-100 dark:bg-gray-800' }}">
                    <i class="fas fa-home text-xs {{ request()->routeIs('admin.dashboard') ? 'text-emerald-600 dark:text-emerald-400' : 'text-gray-400' }}"></i>
                </div>
                <span x-show="!sidebar.collapsed" x-transition>لوحة التحكم</span>
            </a>

            {{-- Content Section Label --}}
            <div class="px-3 pb-1 pt-5" x-show="!sidebar.collapsed">
                <span class="text-[10px] font-bold uppercase tracking-widest text-gray-300 dark:text-gray-600">المحتوى</span>
            </div>
            <div class="mx-3 mb-2 border-b border-gray-100 dark:border-gray-800/50" x-show="sidebar.collapsed"></div>

            @php
                $contentLinks = [
                    ['route' => 'admin.categories.*', 'href' => route('admin.categories.index'), 'icon' => 'fa-tags', 'label' => 'التصنيفات'],
                    ['route' => 'admin.authors.*', 'href' => route('admin.authors.index'), 'icon' => 'fa-users', 'label' => 'المؤلفون'],
                    ['route' => 'admin.items.*', 'href' => route('admin.items.index'), 'icon' => 'fa-layer-group', 'label' => 'المواد'],
                    ['route' => 'admin.hadith.*', 'href' => route('admin.hadith.index'), 'icon' => 'fa-book-quran', 'label' => 'الحديث الشريف'],
                    ['route' => 'admin.reciters.*', 'href' => route('admin.reciters.index'), 'icon' => 'fa-microphone-lines', 'label' => 'القراء'],
                ];
            @endphp

            @foreach($contentLinks as $link)
                <a href="{{ $link['href'] }}"
                    class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium transition-colors
                    {{ request()->routeIs($link['route'])
                        ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                        : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800/50' }}">
                    <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg {{ request()->routeIs($link['route']) ? 'bg-emerald-500/10 dark:bg-emerald-500/15' : 'bg-gray-100 dark:bg-gray-800' }}">
                        <i class="fa-solid {{ $link['icon'] }} text-xs {{ request()->routeIs($link['route']) ? 'text-emerald-600 dark:text-emerald-400' : 'text-gray-400' }}"></i>
                    </div>
                    <span x-show="!sidebar.collapsed" x-transition>{{ $link['label'] }}</span>
                </a>
            @endforeach

            {{-- System Section Label --}}
            <div class="px-3 pb-1 pt-5" x-show="!sidebar.collapsed">
                <span class="text-[10px] font-bold uppercase tracking-widest text-gray-300 dark:text-gray-600">النظام</span>
            </div>
            <div class="mx-3 mb-2 border-b border-gray-100 dark:border-gray-800/50" x-show="sidebar.collapsed"></div>

            @php
                $unreadMessagesCount = \App\Models\ContactMessage::unread()->count();
                $systemLinks = [
                    ['route' => 'admin.messages.*', 'href' => route('admin.messages.index'), 'icon' => 'fa-envelope', 'label' => 'الرسائل', 'badge' => $unreadMessagesCount],
                    ['route' => 'admin.notifications.*', 'href' => route('admin.notifications.index'), 'icon' => 'fa-bell', 'label' => 'التنبيهات'],
                    ['route' => 'admin.settings.*', 'href' => route('admin.settings.index'), 'icon' => 'fa-cog', 'label' => 'الإعدادات'],
                ];
            @endphp

            @foreach($systemLinks as $link)
                <a href="{{ $link['href'] }}"
                    class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium transition-colors
                    {{ request()->routeIs($link['route'])
                        ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-500/10 dark:text-emerald-400'
                        : 'text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800/50' }}">
                    <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg {{ request()->routeIs($link['route']) ? 'bg-emerald-500/10 dark:bg-emerald-500/15' : 'bg-gray-100 dark:bg-gray-800' }}">
                        <i class="fas {{ $link['icon'] }} text-xs {{ request()->routeIs($link['route']) ? 'text-emerald-600 dark:text-emerald-400' : 'text-gray-400' }}"></i>
                    </div>
                    <span x-show="!sidebar.collapsed" x-transition class="flex-1">{{ $link['label'] }}</span>
                    @if(! empty($link['badge']))
                        <span x-show="!sidebar.collapsed" x-transition class="inline-flex items-center justify-center min-w-[20px] h-5 px-1.5 text-[10px] font-bold text-white bg-rose-500 rounded-full">{{ $link['badge'] }}</span>
                    @endif
                </a>
            @endforeach
        </div>
    </nav>

    <!-- User Section -->
    <div class="border-t border-gray-100/80 dark:border-gray-800/50 p-3">
        <div class="flex items-center gap-3 rounded-xl bg-gray-50/80 dark:bg-gray-800/30 p-2.5">
            <div class="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-emerald-500 text-white text-xs font-bold">
                {{ mb_substr(Auth::user()->name ?? 'م', 0, 1) }}
            </div>
            <div class="flex-1 min-w-0" x-show="!sidebar.collapsed" x-transition>
                <p class="text-[13px] font-bold text-gray-900 dark:text-white truncate">{{ Auth::user()->name ?? 'المدير' }}</p>
                <p class="text-[10px] text-gray-400 truncate">مدير النظام</p>
            </div>
        </div>

        <form method="POST" action="{{ route('logout') }}" class="mt-1.5">
            @csrf
            <button type="submit"
                class="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium text-red-500 transition-colors hover:bg-red-50 dark:hover:bg-red-500/5">
                <div class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-lg">
                    <i class="fas fa-sign-out-alt text-xs"></i>
                </div>
                <span x-show="!sidebar.collapsed" x-transition>تسجيل الخروج</span>
            </button>
        </form>
    </div>
</aside>
