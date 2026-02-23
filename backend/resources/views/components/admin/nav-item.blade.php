@props(['href', 'active' => false, 'icon' => null])

@php
    $classes = $active
        ? 'flex items-center gap-3 px-4 py-3 rounded-xl bg-emerald-50 text-emerald-600 font-bold border-r-4 border-emerald-500 transition-all duration-300 relative group'
        : 'flex items-center gap-3 px-4 py-3 rounded-xl text-gray-600 hover:bg-gray-50 hover:text-gray-800 font-medium transition-all duration-300 relative group';
@endphp

<a {{ $attributes->merge(['href' => $href, 'class' => $classes]) }}>
    @if (isset($icon))
        <i class="{{ $icon }} w-5 text-center text-xl transition-colors {{ $active ?? false ? 'text-emerald-500' : 'text-gray-400 group-hover:text-emerald-500' }}"></i>
    @endif

    <span x-show="!sidebarCollapsed" x-transition.opacity.duration.300ms class="text-sm whitespace-nowrap">{{ $slot }}</span>

    @if ($active ?? false)
        <span x-show="sidebarCollapsed" class="absolute left-2 top-1/2 -translate-y-1/2 w-1 h-3 rounded-full bg-emerald-500 animate-pulse"></span>
    @endif
</a>
