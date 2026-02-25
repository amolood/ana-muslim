<script>
    // Theme & Locale initialization script - run mid-head
    (function () {
        // Theme
        const theme = localStorage.getItem('theme') || 'system';
        const isDark = theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
        
        if (isDark) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }

        // Locale
        const locale = localStorage.getItem('locale') || 'ar';
        document.documentElement.lang = locale;
        document.documentElement.dir = locale === 'ar' ? 'rtl' : 'ltr';
    })();
</script>
