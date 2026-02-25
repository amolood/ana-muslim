<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\HisnmuslimChapter;
use App\Models\HisnmuslimDua;
use Illuminate\Support\Facades\Http;

class ImportHisnmuslim extends Command
{
    protected $signature = 'hisnmuslim:import';
    protected $description = 'Import Hisnmuslim data from API';

    public function handle()
    {
        $this->info('Starting Hisnmuslim data import...');

        // Clear existing data
        $this->info('Clearing existing data...');
        \DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        HisnmuslimDua::truncate();
        HisnmuslimChapter::truncate();
        \DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Fetch main API to get language URLs
        $this->info('Fetching API index...');
        $mainResponse = Http::get('https://hisnmuslim.com/api/husn.json');

        if (!$mainResponse->successful()) {
            $this->error('Failed to fetch main API');
            return 1;
        }

        $mainData = json_decode(trim($mainResponse->body(), "\xEF\xBB\xBF"), true);

        // Get Arabic URL
        $arabicUrl = collect($mainData['MAIN'] ?? [])->firstWhere('LANGUAGE', 'العربية')['LANGUAGE_URL'] ?? null;

        if (!$arabicUrl) {
            $this->error('Could not find Arabic API URL');
            return 1;
        }

        // Fetch Arabic chapters
        $this->info('Fetching Arabic chapters from: ' . $arabicUrl);
        $response = Http::get($arabicUrl);

        if (!$response->successful()) {
            $this->error('Failed to fetch Arabic data');
            return 1;
        }

        $responseData = json_decode(trim($response->body(), "\xEF\xBB\xBF"), true);
        $data = $responseData['العربية'] ?? [];

        if (!is_array($data)) {
            $this->error('Invalid data format');
            return 1;
        }

        $order = 0;
        $bar = $this->output->createProgressBar(count($data));
        $bar->start();

        foreach ($data as $chapterData) {
            // Convert HTTP to HTTPS to avoid mixed content warnings
            $audioUrl = $chapterData['AUDIO_URL'] ?? null;
            if ($audioUrl && str_starts_with($audioUrl, 'http://')) {
                $audioUrl = str_replace('http://', 'https://', $audioUrl);
            }

            if (!isset($chapterData['ID'])) continue;

            $chapter = HisnmuslimChapter::create([
                'chapter_id' => $chapterData['ID'],
                'title_ar' => $chapterData['TITLE'] ?? null,
                'title_en' => null,
                'audio_url' => $audioUrl,
                'order' => $order++,
            ]);

            // Fetch duas for this chapter
            $duasResponse = Http::get("https://hisnmuslim.com/api/ar/{$chapterData['ID']}.json");

            if ($duasResponse->successful()) {
                $duasResponseData = json_decode(trim($duasResponse->body(), "\xEF\xBB\xBF"), true);

                // The API returns data with the chapter title as the key
                // Get the first (and only) value from the response
                $duasData = is_array($duasResponseData) ? reset($duasResponseData) : [];

                if (is_array($duasData)) {
                    $duaOrder = 0;
                    foreach ($duasData as $duaData) {
                        HisnmuslimDua::create([
                            'chapter_id' => $chapter->id,
                            'text_ar' => $duaData['ARABIC_TEXT'] ?? '',
                            'text_en' => null,
                            'translation_ar' => $duaData['TRANSLATED_TEXT'] ?? null,
                            'translation_en' => null,
                            'reference' => $duaData['REFERENCE'] ?? null,
                            'count' => $duaData['REPEAT'] ?? null,
                            'order' => $duaOrder++,
                        ]);
                    }
                }
            }

            $bar->advance();
            usleep(100000); // Small delay to avoid overwhelming the API
        }

        $bar->finish();
        $this->newLine();
        $this->info('Import completed successfully!');
        $this->info('Chapters: ' . HisnmuslimChapter::count());
        $this->info('Duas: ' . HisnmuslimDua::count());

        return 0;
    }
}
