<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimRamadanSchedule;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\View\View;

class RamadanController extends Controller
{
    public function index(): View
    {
        $cities = AnaMuslimRamadanSchedule::query()
            ->select('city_key')
            ->selectRaw('COUNT(*) as days_count')
            ->selectRaw('MIN(date) as start_date')
            ->selectRaw('MAX(date) as end_date')
            ->selectRaw('SUM(CASE WHEN is_white_day = 1 THEN 1 ELSE 0 END) as white_days_count')
            ->groupBy('city_key')
            ->orderBy('city_key')
            ->get();

        $totalRows = AnaMuslimRamadanSchedule::count();

        return view('admin.ramadan.index', compact('cities', 'totalRows'));
    }

    public function show(string $cityKey): View
    {
        $days = AnaMuslimRamadanSchedule::where('city_key', $cityKey)
            ->orderBy('date')
            ->paginate(30);

        abort_if($days->isEmpty(), 404);

        return view('admin.ramadan.show', compact('days', 'cityKey'));
    }

    public function create(Request $request): View
    {
        // Pre-fill city_key when adding a day to an existing city.
        $cityKey = $request->query('city_key', '');
        $existingCities = AnaMuslimRamadanSchedule::select('city_key', 'lat', 'lon')
            ->groupBy('city_key', 'lat', 'lon')
            ->orderBy('city_key')
            ->get();

        return view('admin.ramadan.create', compact('cityKey', 'existingCities'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'city_key' => 'required|string|max:100',
            'lat' => 'required|numeric|between:-90,90',
            'lon' => 'required|numeric|between:-180,180',
            'date' => 'required|date',
            'day_name' => 'nullable|string|max:20',
            'day_name_ar' => 'nullable|string|max:20',
            'hijri_date' => 'nullable|string|max:30',
            'hijri_readable' => 'nullable|string|max:100',
            'hijri_readable_ar' => 'nullable|string|max:100',
            'sahur_time' => 'required|string|max:10',
            'iftar_time' => 'required|string|max:10',
            'fasting_duration' => 'nullable|string|max:20',
            'fasting_duration_ar' => 'nullable|string|max:20',
            'is_white_day' => 'nullable|boolean',
            'dua_title' => 'nullable|string|max:255',
            'dua_title_ar' => 'nullable|string|max:255',
            'dua_arabic' => 'nullable|string',
            'dua_translation' => 'nullable|string',
            'dua_reference' => 'nullable|string|max:255',
            'hadith_arabic' => 'nullable|string',
            'hadith_english' => 'nullable|string',
            'hadith_source' => 'nullable|string|max:255',
            'hadith_grade' => 'nullable|string|max:100',
        ]);

        $validated['is_white_day'] = $request->boolean('is_white_day');

        AnaMuslimRamadanSchedule::create($validated);

        Cache::flush();

        return redirect()
            ->route('admin.ramadan.show', $validated['city_key'])
            ->with('success', 'تمت إضافة اليوم بنجاح');
    }

    public function edit(int $id): View
    {
        $day = AnaMuslimRamadanSchedule::findOrFail($id);

        return view('admin.ramadan.edit', compact('day'));
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $day = AnaMuslimRamadanSchedule::findOrFail($id);

        $validated = $request->validate([
            'sahur_time' => 'required|string|max:10',
            'iftar_time' => 'required|string|max:10',
            'fasting_duration' => 'nullable|string|max:20',
            'fasting_duration_ar' => 'nullable|string|max:20',
            'is_white_day' => 'nullable|boolean',
            'dua_title' => 'nullable|string|max:255',
            'dua_title_ar' => 'nullable|string|max:255',
            'dua_arabic' => 'nullable|string',
            'dua_translation' => 'nullable|string',
            'dua_reference' => 'nullable|string|max:255',
            'hadith_arabic' => 'nullable|string',
            'hadith_english' => 'nullable|string',
            'hadith_source' => 'nullable|string|max:255',
            'hadith_grade' => 'nullable|string|max:100',
        ]);

        $validated['is_white_day'] = $request->boolean('is_white_day');

        $day->update($validated);

        Cache::flush();

        return redirect()
            ->route('admin.ramadan.show', $day->city_key)
            ->with('success', 'تم تحديث بيانات اليوم بنجاح');
    }

    public function destroy(int $id): RedirectResponse
    {
        $day = AnaMuslimRamadanSchedule::findOrFail($id);
        $cityKey = $day->city_key;
        $day->delete();

        Cache::flush();

        return redirect()
            ->route('admin.ramadan.show', $cityKey)
            ->with('success', 'تم حذف اليوم بنجاح');
    }

    public function destroyCity(string $cityKey): RedirectResponse
    {
        AnaMuslimRamadanSchedule::where('city_key', $cityKey)->delete();

        Cache::flush();

        return redirect()
            ->route('admin.ramadan.index')
            ->with('success', "تم حذف جدول مدينة «{$cityKey}» بالكامل");
    }
}
