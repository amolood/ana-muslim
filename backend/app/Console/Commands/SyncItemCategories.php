<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\AnaMuslimItem;
use App\Models\AnaMuslimCategory;
use App\Support\IslamhouseApi;

class SyncItemCategories extends Command
{
    protected $signature = 'sync:missing-categories
        {--language=ar : Translated language for category items endpoint}
        {--source-language=ar : Source language for category items endpoint}
        {--per-page= : Items per page while syncing category links}
        {--memory-limit= : Runtime PHP memory_limit override (e.g. 1024M)}';

    protected $description = 'Populate ana_muslim_item_category by fetching each category\'s items from the Islamhouse API.';

    public function handle(): int
    {
        $memoryLimit = trim((string) ($this->option('memory-limit') ?: config('islamhouse.sync_memory_limit', '1024M')));
        $this->applyMemoryLimit($memoryLimit);

        $language = (string) $this->option('language');
        $sourceLanguage = (string) $this->option('source-language');
        $perPageRaw = $this->option('per-page');
        $perPage = is_numeric($perPageRaw)
            ? (int) $perPageRaw
            : (int) config('islamhouse.sync_per_page', 100);
        $perPage = max(1, min(200, $perPage));

        $this->info("Starting Item-Category pivot sync...");

        $totalCats = (int) AnaMuslimCategory::count();

        if ($totalCats === 0) {
            $this->info("No categories found locally.");
            return self::SUCCESS;
        }

        $this->info("Found {$totalCats} categories. Syncing item associations...\n");
        $bar = $this->output->createProgressBar($totalCats);
        $bar->start();

        $inserted = 0;

        foreach (AnaMuslimCategory::query()->select('id')->orderBy('id')->cursor() as $category) {
            $categoryApiId = (int) $category->id; // local id == Islamhouse API category id
            $page = 1;

            do {
                $url = IslamhouseApi::url(
                    "main/get-category-items/{$categoryApiId}/showall/{$sourceLanguage}/{$language}/{$page}/{$perPage}/json"
                );
                $hasNextPage = false;

                try {
                    $response = Http::timeout((int) config('islamhouse.timeout', 90))
                        ->retry(
                            (int) config('islamhouse.retry_times', 2),
                            (int) config('islamhouse.retry_sleep_ms', 500)
                        )
                        ->get($url);

                    if ($response->successful()) {
                        $data = $response->json();

                        if (isset($data['data']) && is_array($data['data'])) {
                            $apiItemIds = [];
                            foreach ($data['data'] as $itemData) {
                                if (isset($itemData['id']) && is_numeric($itemData['id'])) {
                                    $apiItemIds[] = (int) $itemData['id'];
                                }
                            }

                            if (!empty($apiItemIds)) {
                                // Match API item IDs to local DB items via source_id
                                $localItems = AnaMuslimItem::query()
                                    ->whereIn('source_id', $apiItemIds)
                                    ->pluck('id', 'source_id')
                                    ->toArray();

                                $pivotRows = [];
                                $seen = [];
                                foreach ($apiItemIds as $apiItemId) {
                                    if (isset($localItems[$apiItemId])) {
                                        $itemId = (int) $localItems[$apiItemId];
                                        $dedupeKey = "{$itemId}:{$category->id}";
                                        if (isset($seen[$dedupeKey])) {
                                            continue;
                                        }
                                        $seen[$dedupeKey] = true;

                                        $pivotRows[] = [
                                            'item_id'     => $itemId,
                                            'category_id' => (int) $category->id,
                                            'created_at'  => now(),
                                            'updated_at'  => now(),
                                        ];
                                    }
                                }

                                if (!empty($pivotRows)) {
                                    $inserted += DB::table('ana_muslim_item_category')->insertOrIgnore($pivotRows);
                                }
                            }
                        }

                        // Follow pagination
                        if (!empty($data['links']['next'])) {
                            $page++;
                            $hasNextPage = true;
                        }
                    }
                } catch (\Exception $e) {
                    Log::warning("SyncItemCategories: category {$categoryApiId} page {$page} error: " . $e->getMessage());
                }

                unset($response, $data, $apiItemIds, $localItems, $pivotRows, $seen);
                gc_collect_cycles();

            } while ($hasNextPage);

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();
        $this->info("Sync complete! Inserted {$inserted} item-category associations.");

        return self::SUCCESS;
    }

    private function applyMemoryLimit(string $memoryLimit): void
    {
        if ($memoryLimit === '') {
            return;
        }

        $current = ini_get('memory_limit') ?: 'unknown';
        @ini_set('memory_limit', $memoryLimit);
        $this->line("Memory limit: {$current} -> " . (ini_get('memory_limit') ?: $memoryLimit));
    }
}
