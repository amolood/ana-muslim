<?php

namespace App\Console\Commands;

use App\Models\AnaMuslimRamadanSchedule;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ImportRamadanSchedule extends Command
{
    protected $signature = 'import:ramadan-schedule
                            {--key= : islamicapi.com API key (defaults to env ISLAMIC_API_KEY)}
                            {--method=3 : Prayer calculation method (default: 3 = Muslim World League)}
                            {--shifting=0 : Hijri adjustment (-2 to +2)}
                            {--force : Overwrite existing records}';

    protected $description = 'Fetch and store Ramadan 2026 fasting schedule for major cities from islamicapi.com';

    private const API_URL = 'https://islamicapi.com/api/v1/ramadan/';

    /**
     * Major cities with their lat/lon coordinates.
     * City keys must be URL-slug-safe.
     */
    private const CITIES = [
        ['key' => 'mecca',    'name' => 'مكة المكرمة',      'lat' => 21.3891,   'lon' => 39.8579],
        ['key' => 'medina',   'name' => 'المدينة المنورة',   'lat' => 24.5247,   'lon' => 39.5692],
        ['key' => 'riyadh',   'name' => 'الرياض',            'lat' => 24.6877,   'lon' => 46.7219],
        ['key' => 'cairo',    'name' => 'القاهرة',            'lat' => 30.0444,   'lon' => 31.2357],
        ['key' => 'dubai',    'name' => 'دبي',                'lat' => 25.2048,   'lon' => 55.2708],
        ['key' => 'amman',    'name' => 'عمّان',              'lat' => 31.9539,   'lon' => 35.9106],
        ['key' => 'beirut',   'name' => 'بيروت',              'lat' => 33.8938,   'lon' => 35.5018],
        ['key' => 'istanbul', 'name' => 'إسطنبول',            'lat' => 41.0082,   'lon' => 28.9784],
        ['key' => 'london',   'name' => 'لندن',               'lat' => 51.5194,   'lon' => -0.1360],
        ['key' => 'paris',    'name' => 'باريس',              'lat' => 48.8566,   'lon' => 2.3522],
        ['key' => 'new_york', 'name' => 'نيويورك',            'lat' => 40.7128,   'lon' => -74.0060],
        ['key' => 'toronto',  'name' => 'تورونتو',            'lat' => 43.6511,   'lon' => -79.3470],
        ['key' => 'sydney',   'name' => 'سيدني',              'lat' => -33.8688,  'lon' => 151.2093],
        ['key' => 'jakarta',  'name' => 'جاكرتا',             'lat' => -6.2088,   'lon' => 106.8456],
        ['key' => 'karachi',  'name' => 'كراتشي',             'lat' => 24.8607,   'lon' => 67.0011],
        ['key' => 'khartoum', 'name' => 'الخرطوم',            'lat' => 15.5007,   'lon' => 32.5599],
    ];

    public function handle(): int
    {
        $apiKey = $this->option('key') ?: env('ISLAMIC_API_KEY');

        if (! $apiKey) {
            $this->error('No API key provided. Set ISLAMIC_API_KEY in .env or pass --key=...');
            return 1;
        }

        $force   = (bool) $this->option('force');
        $method  = (int) $this->option('method');
        $shifting = (int) $this->option('shifting');

        $this->info('Starting Ramadan 2026 schedule import for ' . count(self::CITIES) . ' cities...');
        $bar = $this->output->createProgressBar(count(self::CITIES));
        $bar->start();

        $totalSaved = 0;
        $failed = [];

        foreach (self::CITIES as $city) {
            // Skip if data already exists for this city (unless forced)
            if (! $force && AnaMuslimRamadanSchedule::where('city_key', $city['key'])->exists()) {
                $bar->advance();
                continue;
            }

            $data = $this->fetchCity($apiKey, $city, $method, $shifting);

            if ($data === null) {
                $failed[] = $city['key'];
                $bar->advance();
                continue;
            }

            $saved = $this->saveCity($city, $data);
            $totalSaved += $saved;
            $bar->advance();

            // Be polite to the API
            if (count(self::CITIES) > 1) {
                usleep(500_000); // 0.5s between requests
            }
        }

        $bar->finish();
        $this->newLine();
        $this->info("Saved {$totalSaved} schedule rows total.");

        if (! empty($failed)) {
            $this->warn('Failed cities: ' . implode(', ', $failed));
        }

        return empty($failed) ? 0 : 1;
    }

    private function fetchCity(string $apiKey, array $city, int $method, int $shifting): ?array
    {
        try {
            $params = [
                'lat'      => $city['lat'],
                'lon'      => $city['lon'],
                'api_key'  => $apiKey,
                'method'   => $method,
                'shifting' => $shifting,
            ];

            $response = Http::timeout(30)
                ->retry(3, 3000)
                ->get(self::API_URL, $params);

            if (! $response->successful()) {
                $this->newLine();
                $this->warn("HTTP {$response->status()} for city: {$city['key']}");
                return null;
            }

            $json = $response->json();

            if (($json['code'] ?? 0) !== 200) {
                $this->newLine();
                $this->warn("API error for {$city['key']}: " . ($json['message'] ?? 'unknown'));
                return null;
            }

            return $json;
        } catch (\Throwable $e) {
            $this->newLine();
            $this->warn("Exception fetching {$city['key']}: " . $e->getMessage());
            Log::warning('ImportRamadanSchedule: ' . $e->getMessage(), ['city' => $city['key']]);
            return null;
        }
    }

    private function saveCity(array $city, array $apiResponse): int
    {
        $fastingDays  = $apiResponse['data']['fasting']     ?? [];
        $whiteDaysRaw = $apiResponse['data']['white_days']  ?? [];
        $resource     = $apiResponse['resource']            ?? [];

        // Build set of white day dates
        $whiteDayDates = [];
        if (isset($whiteDaysRaw['days']) && is_array($whiteDaysRaw['days'])) {
            foreach ($whiteDaysRaw['days'] as $date) {
                $whiteDayDates[$date] = true;
            }
        }

        $saved = 0;
        foreach ($fastingDays as $day) {
            $date = $day['date'] ?? null;
            if (! $date) continue;

            $time = $day['time'] ?? [];

            $record = [
                'city_key'         => $city['key'],
                'lat'              => $city['lat'],
                'lon'              => $city['lon'],
                'date'             => $date,
                'day_name'         => $day['day'] ?? null,
                'hijri_date'       => $day['hijri'] ?? null,
                'hijri_readable'   => $day['hijri_readable'] ?? null,
                'sahur_time'       => $time['sahur'] ?? null,
                'iftar_time'       => $time['iftar'] ?? null,
                'fasting_duration' => $time['duration'] ?? null,
                'is_white_day'     => isset($whiteDayDates[$date]),
                // Daily dua from resource (same for all days in response)
                'dua_title'           => $resource['dua']['title'] ?? null,
                'dua_arabic'          => $resource['dua']['arabic'] ?? null,
                'dua_translation'     => $resource['dua']['translation'] ?? null,
                'dua_transliteration' => $resource['dua']['transliteration'] ?? null,
                'dua_reference'       => $resource['dua']['reference'] ?? null,
                // Daily hadith
                'hadith_arabic'  => $resource['hadith']['arabic'] ?? null,
                'hadith_english' => $resource['hadith']['english'] ?? null,
                'hadith_source'  => $resource['hadith']['source'] ?? null,
                'hadith_grade'   => $resource['hadith']['grade'] ?? null,
            ];

            AnaMuslimRamadanSchedule::updateOrCreate(
                ['city_key' => $city['key'], 'date' => $date],
                $record
            );
            $saved++;
        }

        return $saved;
    }
}
