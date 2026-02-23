<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\AnaMuslimItem;
use App\Models\AnaMuslimAuthor;
use App\Models\AnaMuslimAttachment;
use App\Models\AnaMuslimLocale;
use App\Support\IslamhouseApi;

class ProcessItemDetailsJob implements ShouldQueue
{
    use Queueable;

    public $itemId;
    public $type;
    public $language;

    /**
     * Create a new job instance.
     */
    public function __construct(int $itemId, string $type, string $language = 'ar')
    {
        $this->itemId = $itemId;
        $this->type = $type;
        $this->language = $language;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $url = IslamhouseApi::url("main/get-item/{$this->itemId}/{$this->language}/json");
        
        Log::info("Fetching item details for ID {$this->itemId}");

        try {
            $response = Http::timeout(60)->get($url);
            
            if ($response->successful()) {
                $itemData = $response->json();
                if (!is_array($itemData) || !isset($itemData['id'])) {
                    Log::warning("Malformed item details payload for {$this->itemId}");
                    return;
                }

                // Save or update the item
                $item = AnaMuslimItem::updateOrCreate(
                    ['source_id' => $itemData['id']],
                    [
                        'title' => $itemData['title'] ?? null,
                        'type' => $itemData['type'] ?? $this->type,
                        'description' => $itemData['description'] ?? null,
                        'full_description' => $itemData['full_description'] ?? null,
                        'source_language' => $itemData['source_language'] ?? null,
                        'translated_language' => $itemData['translated_language'] ?? null,
                        'importance_level' => $itemData['importance_level'] ?? null,
                        'add_date' => $itemData['add_date'] ?? null,
                        'update_date' => $itemData['update_date'] ?? null,
                        'image' => $itemData['image'] ?? null,
                        'api_url' => $itemData['api_url'] ?? null,
                    ]
                );

                // Save Authors and Attach them
                if (isset($itemData['prepared_by']) && is_array($itemData['prepared_by'])) {
                    $authorIds = [];
                    foreach ($itemData['prepared_by'] as $authorData) {
                        $author = AnaMuslimAuthor::updateOrCreate(
                            ['source_id' => $authorData['id']],
                            [
                                'title' => $authorData['title'] ?? '',
                                'type' => $authorData['type'] ?? null,
                                'kind' => $authorData['kind'] ?? null,
                                'description' => $authorData['description'] ?? null,
                                'api_url' => $authorData['api_url'] ?? null,
                            ]
                        );
                        $authorIds[] = $author->id;
                    }
                    $item->authors()->sync($authorIds); // Sync pivot
                }

                // Save Attachments
                if (isset($itemData['attachments']) && is_array($itemData['attachments'])) {
                    foreach ($itemData['attachments'] as $attachmentData) {
                        AnaMuslimAttachment::updateOrCreate(
                            [
                                'item_id' => $item->id,
                                'url' => $attachmentData['url'] ?? ''
                            ],
                            [
                                'order' => $attachmentData['order'] ?? 0,
                                'size' => $attachmentData['size'] ?? null,
                                'extension_type' => $attachmentData['extension_type'] ?? null,
                                'description' => $attachmentData['description'] ?? null,
                            ]
                        );
                    }
                }

                // Sync Categories
                if (isset($itemData['categories']) && is_array($itemData['categories'])) {
                    $categoryIds = [];
                    foreach ($itemData['categories'] as $catData) {
                        if (isset($catData['id'])) {
                            // Ensure the category exists locally before assigning
                            $exists = \App\Models\AnaMuslimCategory::where('id', $catData['id'])->exists();
                            if ($exists) {
                                $categoryIds[] = $catData['id'];
                            }
                        }
                    }
                    if (!empty($categoryIds)) {
                        $item->categories()->syncWithoutDetaching($categoryIds);
                    }
                }

                // Save Locales
                if (isset($itemData['locales']) && is_array($itemData['locales'])) {
                    foreach ($itemData['locales'] as $localeData) {
                        AnaMuslimLocale::updateOrCreate(
                            [
                                'item_id' => $item->id,
                                'language' => $localeData['language'] ?? ''
                            ],
                            [
                                'url' => $localeData['url'] ?? '',
                            ]
                        );
                    }
                }

            } else {
                Log::error("Failed to fetch details for {$this->itemId}. Status: " . $response->status());
            }
        } catch (\Exception $e) {
            Log::error("Error fetching details for {$this->itemId}: " . $e->getMessage());
        }
    }
}
