<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use App\Models\AnaMuslimCategory;
use App\Jobs\ProcessCategoryItemsJob;
use App\Support\IslamhouseApi;

class ImportAnaMuslimCategories extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'import:ana-muslim-categories {language=ar} {sourceLanguage=ar}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Imports Islamhouse categories and dispatches jobs to fetch their items.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $language = $this->argument('language');
        // Kept for compatibility with current command signature.
        $this->argument('sourceLanguage');

        $url = IslamhouseApi::url("main/get-object-category-tree/{$language}/json");

        $this->info("Fetching category tree from: {$url}");

        $response = Http::timeout(120)->get($url);

        if ($response->successful()) {
            $data = $response->json();

            if (isset($data['sub_categories']) && is_array($data['sub_categories'])) {
                $rootId = $this->saveCategory($data, null, $language);
                $this->saveCategories($data['sub_categories'], $rootId, $language);
            } else {
                $this->error("No categories found in response.");
            }
        } else {
            $this->error("Failed to fetch category tree. HTTP Status: " . $response->status());
        }

        $this->info("Category import finished. Jobs dispatched to queue.");
    }

    protected function saveCategories(array $categories, $parentId = null, $language = 'ar')
    {
        foreach ($categories as $catData) {
            $categoryId = $this->saveCategory($catData, $parentId, $language);
            if ($categoryId === null) {
                continue;
            }

            if (!empty($catData['sub_categories']) && is_array($catData['sub_categories'])) {
                $this->saveCategories($catData['sub_categories'], $categoryId, $language);
            } else {
                // It's a leaf category, dispatch job to fetch items
                $this->info("Dispatching items job for leaf category ID: {$categoryId}");
                ProcessCategoryItemsJob::dispatch((string)$categoryId, 1, $language);
            }
        }
    }

    protected function saveCategory(array $catData, $parentId = null, $language = 'ar'): ?int
    {
        $categoryId = $this->resolveCategoryId($catData);
        if ($categoryId === null) {
            return null;
        }

        $category = AnaMuslimCategory::unguarded(function () use ($categoryId, $catData, $parentId, $language) {
            return AnaMuslimCategory::updateOrCreate(
                ['id' => $categoryId],
                [
                    'title' => $catData['title'] ?? 'Untitled',
                    'block_name' => $catData['block_name'] ?? null,
                    'items_count' => (int)($catData['items_count'] ?? 0),
                    'language' => $language,
                    'parent_id' => $parentId,
                ]
            );
        });

        $this->info("Saved Category: {$category->title} (ID: {$category->id}, Parent: " . ($parentId ?? 'null') . ")");

        return $category->id;
    }

    protected function resolveCategoryId(array $catData): ?int
    {
        $id = $catData['source_id'] ?? $catData['id'] ?? null;

        if (is_numeric($id) && (int)$id > 0) {
            return (int)$id;
        }

        return null;
    }
}
