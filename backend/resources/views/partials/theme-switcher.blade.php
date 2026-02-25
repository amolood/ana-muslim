<div x-data="{
    theme: localStorage.getItem('theme') || 'system',
    open: false,
    setTheme(val) {
        this.theme = val;
        localStorage.setItem('theme', val);
        this.applyTheme();
        this.open = false;
    },
    applyTheme() {
        if (this.theme === 'dark' || (this.theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }
}" x-init="applyTheme(); window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => theme === 'system' && applyTheme())" class="relative" @click.outside="open = false">
    
    <!-- Trigger Button -->
    <button @click="open = !open" 
            class="w-11 h-11 flex items-center justify-center rounded-2xl glass-button hover:bg-primary/20 transition-all shadow-sm relative z-50">
        <template x-if="theme === 'light'">
            <iconify-icon icon="solar:sun-2-bold" class="text-xl text-amber-500"></iconify-icon>
        </template>
        <template x-if="theme === 'dark'">
            <iconify-icon icon="solar:moon-bold" class="text-xl text-indigo-400"></iconify-icon>
        </template>
        <template x-if="theme === 'system'">
            <iconify-icon icon="solar:monitor-bold" class="text-xl text-slate-400"></iconify-icon>
        </template>
    </button>

    <!-- Dropdown Menu -->
    <div x-show="open" 
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0 translate-y-2 scale-95"
         x-transition:enter-end="opacity-100 translate-y-0 scale-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100 translate-y-0 scale-100"
         x-transition:leave-end="opacity-0 translate-y-2 scale-95"
         class="absolute top-full left-0 md:left-auto md:right-0 mt-4 p-2 rounded-[1.5rem] bg-white dark:bg-slate-900 border border-slate-200 dark:border-white/10 shadow-[0_20px_50px_-12px_rgba(0,0,0,0.25)] z-[100] min-w-[160px] overflow-hidden"
         style="display: none;">
        
        <div class="flex flex-col gap-1">
            <button @click="setTheme('light')" 
                    :class="theme === 'light' ? 'bg-amber-500/10 text-amber-600' : 'text-slate-700 dark:text-slate-300'"
                    class="w-full flex items-center justify-between px-4 py-3 rounded-xl hover:bg-slate-100 dark:hover:bg-white/5 transition-all group">
                <div class="flex items-center gap-3">
                    <iconify-icon icon="solar:sun-2-bold" class="text-xl" :class="theme === 'light' ? 'text-amber-500' : 'text-slate-400'"></iconify-icon>
                    <span class="text-sm font-bold">نهاري</span>
                </div>
                <iconify-icon x-show="theme === 'light'" icon="solar:check-read-bold" class="text-lg text-amber-500"></iconify-icon>
            </button>

            <button @click="setTheme('dark')" 
                    :class="theme === 'dark' ? 'bg-indigo-500/10 text-indigo-400' : 'text-slate-700 dark:text-slate-300'"
                    class="w-full flex items-center justify-between px-4 py-3 rounded-xl hover:bg-slate-100 dark:hover:bg-white/5 transition-all group">
                <div class="flex items-center gap-3">
                    <iconify-icon icon="solar:moon-bold" class="text-xl" :class="theme === 'dark' ? 'text-indigo-400' : 'text-slate-400'"></iconify-icon>
                    <span class="text-sm font-bold">ليلي</span>
                </div>
                <iconify-icon x-show="theme === 'dark'" icon="solar:check-read-bold" class="text-lg text-indigo-400"></iconify-icon>
            </button>

            <button @click="setTheme('system')" 
                    :class="theme === 'system' ? 'bg-primary/10 text-primary' : 'text-slate-700 dark:text-slate-300'"
                    class="w-full flex items-center justify-between px-4 py-3 rounded-xl hover:bg-slate-100 dark:hover:bg-white/5 transition-all group">
                <div class="flex items-center gap-3">
                    <iconify-icon icon="solar:monitor-bold" class="text-xl" :class="theme === 'system' ? 'text-primary' : 'text-slate-400'"></iconify-icon>
                    <span class="text-sm font-bold">تلقائي</span>
                </div>
                <iconify-icon x-show="theme === 'system'" icon="solar:check-read-bold" class="text-lg text-primary"></iconify-icon>
            </button>
        </div>
    </div>
</div>
