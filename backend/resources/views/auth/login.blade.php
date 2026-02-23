<!DOCTYPE html>
<html lang="ar" dir="rtl" class="scroll-smooth">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="robots" content="noindex,nofollow">
    <title>تسجيل الدخول | أنا مسلم</title>

    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script src="https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&display=swap"
        rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'IBM Plex Sans Arabic', sans-serif;
            background-color: #020202;
        }

        .font-english {
            font-family: 'Outfit', sans-serif;
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.55);
        }

        .btn-gradient {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            transition: all 0.25s ease;
        }

        .btn-gradient:hover {
            background: linear-gradient(135deg, #34d399 0%, #047857 100%);
            transform: translateY(-1px);
            box-shadow: 0 12px 24px -12px rgba(16, 185, 129, 0.55);
        }
    </style>
</head>

<body class="text-slate-200 antialiased">
    <main class="min-h-screen flex items-center justify-center p-6">
        <div class="w-full max-w-md">
            <div class="flex items-center justify-center gap-3 mb-8 group">
                <div class="w-12 h-12 rounded-2xl bg-emerald-500 flex items-center justify-center shadow-lg shadow-emerald-500/20 ring-1 ring-white/10 group-hover:scale-105 transition-transform duration-300">
                    <i class="fa-solid fa-moon text-white text-2xl"></i>
                </div>
                <span class="text-3xl font-bold tracking-tight text-white transition-colors duration-300">أنا مسلم</span>
            </div>

            <div class="glass-panel rounded-3xl p-8">
                <h1 class="text-2xl font-black text-white mb-2 text-center">تسجيل الدخول</h1>
                <p class="text-sm text-slate-400 text-center mb-8">أدخل بياناتك للوصول إلى لوحة التحكم.</p>

                @if ($errors->any())
                    <div class="mb-4 rounded-2xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-200">
                        @foreach ($errors->all() as $error)
                            <p>{{ $error }}</p>
                        @endforeach
                    </div>
                @endif

                <form method="POST" action="{{ route('login') }}" class="space-y-4">
                    @csrf
                    <div>
                        <label class="block text-sm font-bold text-slate-300 mb-2">البريد الإلكتروني</label>
                        <input type="email" name="email" value="{{ old('email') }}" required autocomplete="email" autofocus
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-4 py-3.5 text-white placeholder-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 focus:outline-none transition-all">
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-slate-300 mb-2">كلمة المرور</label>
                        <input type="password" name="password" required autocomplete="current-password"
                            class="w-full bg-white/5 border border-white/10 rounded-2xl px-4 py-3.5 text-white placeholder-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 focus:outline-none transition-all">
                        <div class="mt-3 flex items-center justify-between gap-3">
                            <label class="flex items-center gap-2 text-xs text-slate-400 select-none">
                                <input type="checkbox" name="remember" id="remember" {{ old('remember') ? 'checked' : '' }}
                                    class="h-4 w-4 rounded border-white/20 bg-white/10 text-emerald-500 focus:ring-emerald-500">
                                تذكرني
                            </label>
                            @if (Route::has('password.request'))
                                <a href="{{ route('password.request') }}"
                                    class="text-xs font-bold text-emerald-400 hover:text-emerald-300 underline underline-offset-4">نسيت كلمة المرور؟</a>
                            @endif
                        </div>
                    </div>

                    <button type="submit"
                        class="btn-gradient w-full rounded-2xl py-3.5 text-black font-black flex items-center justify-center gap-2">
                        <span>دخول</span>
                        <iconify-icon icon="solar:login-2-bold-duotone" class="text-xl"></iconify-icon>
                    </button>
                </form>
            </div>
        </div>
    </main>
</body>

</html>
