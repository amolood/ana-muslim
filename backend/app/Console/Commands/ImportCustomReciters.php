<?php

namespace App\Console\Commands;

use App\Models\AnaMuslimAuthor;
use App\Models\AnaMuslimCategory;
use App\Models\AnaMuslimItem;
use App\Models\AnaMuslimAttachment;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ImportCustomReciters extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'import:custom-reciters';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import custom Quraan reciters from JSON files in the docs directory';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $mohamedOsmanFile = base_path('../docs/backend/mohamed_osman_links.json');
        $ahmedTaherFile = base_path('../docs/backend/ahmed_taher_islamway_links.json');

        if (!File::exists($mohamedOsmanFile) || !File::exists($ahmedTaherFile)) {
            $this->error('JSON files not found in the docs directory!');
            return;
        }

        $this->importReciter('محمد عثمان الحاج', $mohamedOsmanFile);
        $this->importReciter('أحمد طاهر', $ahmedTaherFile);

        $this->info('Custom reciters imported successfully!');
    }

    private function importReciter($reciterName, $filePath)
    {
        $this->info("Importing reciter: {$reciterName}...");

        $author = AnaMuslimAuthor::firstOrCreate(
            ['title' => $reciterName],
            [
                'description' => 'قارئ للقرآن الكريم',
                'source_id' => null,
            ]
        );

        $category = AnaMuslimCategory::firstOrCreate(
            ['title' => 'القرآن الكريم'],
            [
                'description' => 'تلاوات القرآن الكريم',
                'section_id' => 1,
                'source_id' => null,
            ]
        );

        $json = File::get($filePath);
        $data = json_decode($json, true);

        if (!$data) {
            $this->error("Failed to parse JSON for {$reciterName}");
            return;
        }

        $bar = $this->output->createProgressBar(count($data));
        $bar->start();

        foreach ($data as $surah) {
            $item = AnaMuslimItem::firstOrCreate(
                [
                    'source_id' => null, // set to null to avoid out-of-range issues on SQLite/MySQL
                    'title' => $surah['surah_name'],
                ],
                [
                    'description' => 'تلاوة ' . $surah['surah_name'] . ' للقارئ ' . $reciterName,
                    'type' => 'audio',
                    'image' => null,
                    'add_date' => now()->timestamp,
                    'update_date' => now()->timestamp,
                ]
            );

            // Attach author
            $item->authors()->syncWithoutDetaching([$author->id]);

            // Default attachment table schema check
            // The item logic should save properly now.

            // Add the attachment (audio link)
            AnaMuslimAttachment::firstOrCreate(
                [
                    'item_id' => $item->id,
                    'url' => $surah['direct_link'],
                ],
                [
                    'order' => 1,
                    'size' => null,
                    'extension' => 'mp3',
                    'type' => 'audio',
                ]
            );

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();
        $this->info("Finished importing {$reciterName}!");
    }
}
