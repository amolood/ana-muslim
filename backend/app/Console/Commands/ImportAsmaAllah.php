<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;

class ImportAsmaAllah extends Command
{
    protected $signature = 'import:asma-allah
                            {--key= : islamicapi.com API key (defaults to env ISLAMIC_API_KEY)}
                            {--force : Re-fetch even if local file already exists}';

    protected $description = 'Fetch the 99 Names of Allah from islamicapi.com and store as data/asma_allah.json';

    private const API_BASE = 'https://islamicapi.com/api/v1/asma-ul-husna/';

    private const OUTPUT_PATH_CANDIDATES = [
        'data/asma_allah.json',
        'data/asma-allah.json',
    ];

    public function handle(): int
    {
        $apiKey = $this->option('key') ?: env('ISLAMIC_API_KEY');

        if (! $apiKey) {
            $this->error('No API key provided. Set ISLAMIC_API_KEY in .env or pass --key=...');
            return 1;
        }

        $outputPath = base_path(self::OUTPUT_PATH_CANDIDATES[0]);

        if (! $this->option('force') && File::exists($outputPath)) {
            $existing = json_decode(File::get($outputPath), true);
            // Check if the existing file already has transliteration
            if (is_array($existing) && isset($existing[0]['transliteration'])) {
                $this->info('File already enriched with transliterations. Use --force to re-fetch.');
                return 0;
            }
        }

        $this->info('Fetching Arabic names...');
        $arData = $this->fetchLanguage($apiKey, 'ar');

        $this->info('Fetching English transliterations...');
        $enData = $this->fetchLanguage($apiKey, 'en');

        if (empty($arData) && empty($enData)) {
            $this->error('Failed to fetch data from islamicapi.com.');
            return 1;
        }

        // Index English data by number for merging
        $enByNumber = [];
        foreach ($enData as $entry) {
            $num = (int) ($entry['number'] ?? 0);
            if ($num > 0) {
                $enByNumber[$num] = $entry;
            }
        }

        // Use whichever dataset has items as source for Arabic
        $source = $arData ?: $enData;

        $merged = [];
        foreach ($source as $entry) {
            $num = (int) ($entry['number'] ?? 0);
            $enEntry = $enByNumber[$num] ?? [];

            $merged[] = [
                'id'               => $num > 0 ? $num : (count($merged) + 1),
                'number'           => $num,
                'name'             => $entry['name'] ?? ($enEntry['name'] ?? ''),
                'transliteration'  => $enEntry['transliteration'] ?? ($entry['transliteration'] ?? ''),
                'translation'      => $enEntry['translation'] ?? ($entry['translation'] ?? ''),
                'meaning'          => $enEntry['meaning'] ?? ($entry['meaning'] ?? ''),
            ];
        }

        if (empty($merged)) {
            $this->error('No entries found after merge. Aborting.');
            return 1;
        }

        // Sort by number
        usort($merged, fn ($a, $b) => $a['number'] <=> $b['number']);

        // Ensure data directory exists
        File::ensureDirectoryExists(dirname($outputPath));

        $json = json_encode($merged, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        File::put($outputPath, $json);

        // Also write to the alt path for compatibility
        $altPath = base_path(self::OUTPUT_PATH_CANDIDATES[1]);
        File::put($altPath, $json);

        $this->info('Saved ' . count($merged) . ' Asma Allah entries to ' . $outputPath);

        // Clear the API cache so fresh data is served immediately
        \Illuminate\Support\Facades\Cache::forget('ana_muslim_asma_allah_v1');

        return 0;
    }

    private function fetchLanguage(string $apiKey, string $language): array
    {
        try {
            $response = Http::timeout(30)
                ->retry(3, 2000)
                ->get(self::API_BASE, [
                    'language' => $language,
                    'api_key'  => $apiKey,
                ]);

            if (! $response->successful()) {
                $this->warn("HTTP {$response->status()} for language={$language}");
                return [];
            }

            $json = $response->json();

            if (is_array($json) && array_is_list($json)) {
                return $json;
            }

            if (isset($json['data']['names']) && is_array($json['data']['names'])) {
                return $json['data']['names'];
            }

            if (isset($json['data']) && is_array($json['data'])) {
                if (array_is_list($json['data'])) {
                    return $json['data'];
                }
            }

            $this->warn("Unexpected response structure for language={$language}");
            return [];
        } catch (\Throwable $e) {
            $this->warn("Failed fetching language={$language}: " . $e->getMessage());
            Log::warning('ImportAsmaAllah: ' . $e->getMessage());
            return [];
        }
    }
}
