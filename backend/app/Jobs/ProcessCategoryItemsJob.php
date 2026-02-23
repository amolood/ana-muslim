<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\AnaMuslimItem;
use App\Support\IslamhouseApi;

class ProcessCategoryItemsJob implements ShouldQueue
{
    use Queueable;

    public $type;
    public $page;
    public $language;

    /**
     * Create a new job instance.
     */
    public function __construct(string $type, int $page = 1, string $language = 'ar')
    {
        $this->type = $type;
        $this->page = $page;
        $this->language = $language;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $url = IslamhouseApi::url("main/get-category-items/{$this->type}/showall/{$this->language}/{$this->language}/{$this->page}/20/json");
        
        Log::info("Fetching {$this->type} page {$this->page} from {$url}");

        try {
            $response = Http::timeout(60)->get($url);
            
            if ($response->successful()) {
                $data = $response->json();

                if (isset($data['data']) && is_array($data['data'])) {
                    foreach ($data['data'] as $itemData) {
                        if (!is_array($itemData) || !isset($itemData['id']) || !is_numeric($itemData['id'])) {
                            continue;
                        }

                        $itemId = (int) $itemData['id'];

                        // We dispatch a job to fetch and save the full details of EACH item
                        ProcessItemDetailsJob::dispatch($itemId, $this->type, $this->language);
                        
                        // Also proactively save the basic item info just in case details fail
                        AnaMuslimItem::updateOrCreate(
                            ['source_id' => $itemId],
                            [
                                'title' => $itemData['title'] ?? null,
                                'type' => $itemData['type'] ?? null,
                                'description' => $itemData['description'] ?? null,
                                'source_language' => $itemData['source_language'] ?? null,
                                'translated_language' => $itemData['translated_language'] ?? null,
                                'importance_level' => $itemData['importance_level'] ?? null,
                                'add_date' => $itemData['add_date'] ?? null,
                                'update_date' => $itemData['update_date'] ?? null,
                                'image' => $itemData['image'] ?? null,
                                'api_url' => $itemData['api_url'] ?? null,
                            ]
                        );
                    }
                }

                // If there is a next page, dispatch another job for the next page
                if (isset($data['links']['next']) && !empty($data['links']['next'])) {
                    ProcessCategoryItemsJob::dispatch($this->type, $this->page + 1, $this->language)->delay(now()->addSeconds(2));
                }
            } else {
                Log::error("Failed to fetch {$this->type} page {$this->page}. Status: " . $response->status());
            }
        } catch (\Exception $e) {
            Log::error("Error fetching {$this->type} page {$this->page}: " . $e->getMessage());
        }
    }
}
