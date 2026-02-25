<?php

namespace App\Http\Controllers\Api;

use App\Models\AnaMuslimRamadanSchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use App\Http\Controllers\Controller;

class RamadanApiController extends Controller
{
    /**
     * Haversine distance between two lat/lon pairs in km.
     */
    private function haversine(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a    = sin($dLat / 2) ** 2
              + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) ** 2;
        return $earthRadius * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }

    /**
     * Find the closest stored city key to the given coordinates.
     */
    private function closestCityKey(float $lat, float $lon): string
    {
        // Get distinct city keys with any one row's lat/lon
        $cities = AnaMuslimRamadanSchedule::select('city_key', 'lat', 'lon')
            ->groupBy('city_key', 'lat', 'lon')
            ->get();

        if ($cities->isEmpty()) {
            return 'mecca'; // fallback
        }

        $closest  = null;
        $minDist  = PHP_FLOAT_MAX;

        foreach ($cities as $city) {
            $dist = $this->haversine($lat, $lon, (float) $city->lat, (float) $city->lon);
            if ($dist < $minDist) {
                $minDist = $dist;
                $closest = $city->city_key;
            }
        }

        return $closest ?? 'mecca';
    }

    /**
     * GET /api/ramadan?lat={lat}&lon={lon}
     * Returns the full 30-day fasting schedule for the nearest stored city.
     */
    public function schedule(Request $request): JsonResponse
    {
        $lat = (float) $request->query('lat', 21.3891);
        $lon = (float) $request->query('lon', 39.8579);
        $lang = $request->query('lang', 'ar');

        $cacheKey = 'ramadan_schedule_' . round($lat, 2) . '_' . round($lon, 2) . '_' . $lang;

        $data = Cache::remember($cacheKey, now()->addHours(12), function () use ($lat, $lon, $lang) {
            $cityKey = $this->closestCityKey($lat, $lon);
            $isAr = ($lang === 'ar');

            $rows = AnaMuslimRamadanSchedule::where('city_key', $cityKey)
                ->orderBy('date')
                ->get();

            $whiteDays = $rows->where('is_white_day', true)->pluck('date')->map(
                fn ($d) => $d instanceof \Carbon\Carbon ? $d->toDateString() : (string) $d
            )->values();

            $days = $rows->map(fn ($r) => [
                'date'             => $r->date instanceof \Carbon\Carbon ? $r->date->toDateString() : (string) $r->date,
                'day_name'         => ($isAr && $r->day_name_ar) ? $r->day_name_ar : $r->day_name,
                'hijri'            => $r->hijri_date,
                'hijri_readable'   => ($isAr && $r->hijri_readable_ar) ? $r->hijri_readable_ar : $r->hijri_readable,
                'is_white_day'     => (bool) $r->is_white_day,
                'sahur_time'       => $r->sahur_time,
                'iftar_time'       => $r->iftar_time,
                'fasting_duration' => ($isAr && $r->fasting_duration_ar) ? $r->fasting_duration_ar : $r->fasting_duration,
                'dua' => $r->dua_arabic ? [
                    'title'          => ($isAr && $r->dua_title_ar) ? $r->dua_title_ar : $r->dua_title,
                    'arabic'         => $r->dua_arabic,
                    'translation'    => $r->dua_translation,
                    'transliteration'=> $r->dua_transliteration,
                    'reference'      => $r->dua_reference,
                ] : null,
                'hadith' => $r->hadith_arabic ? [
                    'arabic'  => $r->hadith_arabic,
                    'english' => $r->hadith_english,
                    'source'  => $r->hadith_source,
                    'grade'   => $r->hadith_grade,
                ] : null,
            ])->values()->toArray();

            return [
                'city_key'   => $cityKey,
                'total_days' => count($days),
                'days'       => $days,
                'white_days' => $whiteDays,
            ];
        });

        return response()->json([
            'code'   => 200,
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /**
     * GET /api/ramadan/today?lat={lat}&lon={lon}
     * Returns only today's fasting entry.
     */
    public function today(Request $request): JsonResponse
    {
        $lat  = (float) $request->query('lat', 21.3891);
        $lon  = (float) $request->query('lon', 39.8579);
        $lang = $request->query('lang', 'ar');
        $today = now()->toDateString();

        $cacheKey = 'ramadan_today_' . round($lat, 2) . '_' . round($lon, 2) . '_' . $today . '_' . $lang;

        $data = Cache::remember($cacheKey, now()->addHours(6), function () use ($lat, $lon, $today, $lang) {
            $cityKey = $this->closestCityKey($lat, $lon);
            $isAr = ($lang === 'ar');

            $row = AnaMuslimRamadanSchedule::where('city_key', $cityKey)
                ->where('date', $today)
                ->first();

            if (! $row) {
                return null;
            }

            return [
                'city_key'         => $cityKey,
                'date'             => $today,
                'day_name'         => ($isAr && $row->day_name_ar) ? $row->day_name_ar : $row->day_name,
                'hijri_readable'   => ($isAr && $row->hijri_readable_ar) ? $row->hijri_readable_ar : $row->hijri_readable,
                'is_white_day'     => (bool) $row->is_white_day,
                'sahur_time'       => $row->sahur_time,
                'iftar_time'       => $row->iftar_time,
                'fasting_duration' => ($isAr && $row->fasting_duration_ar) ? $row->fasting_duration_ar : $row->fasting_duration,
                'dua' => $row->dua_arabic ? [
                    'title'          => ($isAr && $row->dua_title_ar) ? $row->dua_title_ar : $row->dua_title,
                    'arabic'         => $row->dua_arabic,
                    'translation'    => $row->dua_translation,
                    'transliteration'=> $row->dua_transliteration,
                    'reference'      => $row->dua_reference,
                ] : null,
                'hadith' => $row->hadith_arabic ? [
                    'arabic'  => $row->hadith_arabic,
                    'english' => $row->hadith_english,
                    'source'  => $row->hadith_source,
                    'grade'   => $row->hadith_grade,
                ] : null,
            ];
        });

        if ($data === null) {
            return response()->json([
                'code'    => 404,
                'status'  => 'not_found',
                'message' => 'No fasting data for today. Run import:ramadan-schedule to populate.',
            ], 404);
        }

        return response()->json([
            'code'   => 200,
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /**
     * GET /api/ramadan/cities
     * Returns the list of cities available in the database.
     */
    public function cities(): JsonResponse
    {
        $cities = Cache::remember('ramadan_cities_list', now()->addDay(), function () {
            return AnaMuslimRamadanSchedule::select('city_key', 'lat', 'lon')
                ->groupBy('city_key', 'lat', 'lon')
                ->orderBy('city_key')
                ->get()
                ->map(fn ($c) => [
                    'key' => $c->city_key,
                    'lat' => (float) $c->lat,
                    'lon' => (float) $c->lon,
                ])
                ->values();
        });

        return response()->json([
            'code'   => 200,
            'status' => 'success',
            'data'   => $cities,
        ]);
    }
}
