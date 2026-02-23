<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;

class AzkarApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $dataset = $this->loadAzkarDataset();
        $categories = $dataset['categories'];
        $items = $dataset['items'];

        $chapterId = (int) $request->query('chapter_id', 0);
        if ($chapterId > 0) {
            $items = array_values(array_filter(
                $items,
                static fn (array $item): bool => (int) ($item['chapter_id'] ?? 0) === $chapterId
            ));
        }

        $category = trim((string) $request->query('category', ''));
        if ($category !== '') {
            $items = array_values(array_filter(
                $items,
                static fn (array $item): bool => mb_strtolower((string) ($item['category'] ?? '')) === mb_strtolower($category)
            ));
        }

        $query = trim((string) $request->query('q', ''));
        if ($query !== '') {
            $needle = mb_strtolower($query);
            $items = array_values(array_filter($items, static function (array $item) use ($needle): bool {
                $haystack = implode(' ', [
                    mb_strtolower((string) ($item['category'] ?? '')),
                    mb_strtolower((string) ($item['zekr'] ?? '')),
                    mb_strtolower((string) ($item['description'] ?? '')),
                    mb_strtolower((string) ($item['reference'] ?? '')),
                    mb_strtolower((string) ($item['search'] ?? '')),
                ]);

                return str_contains($haystack, $needle);
            }));
        }

        $limit = min(5000, max(1, (int) $request->query('limit', 5000)));
        $page = max(1, (int) $request->query('page', 1));
        $total = count($items);
        $totalPages = max(1, (int) ceil($total / $limit));
        $offset = ($page - 1) * $limit;
        $pagedItems = array_slice($items, $offset, $limit);

        return response()->json([
            'categories' => $categories,
            'items' => array_values($pagedItems),
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => $totalPages,
                'has_more' => $page < $totalPages,
            ],
        ]);
    }

    public function categories(): JsonResponse
    {
        $dataset = $this->loadAzkarDataset();

        return response()->json([
            'categories' => $dataset['categories'],
        ]);
    }

    public function items(Request $request): JsonResponse
    {
        $payload = $this->index($request)->getData(true);

        return response()->json([
            'items' => $payload['items'] ?? [],
            'pagination' => $payload['pagination'] ?? [
                'page' => 1,
                'limit' => 0,
                'total' => 0,
                'total_pages' => 1,
                'has_more' => false,
            ],
        ]);
    }

    public function asmaAllah(): JsonResponse
    {
        $asma = $this->loadAsmaEntries();

        return response()->json([
            'asma_allah' => $asma,
            'data' => $asma,
        ]);
    }

    /**
     * @return array{categories: array<int, array<string, mixed>>, items: array<int, array<string, mixed>>}
     */
    private function loadAzkarDataset(): array
    {
        /** @var array{categories: array<int, array<string, mixed>>, items: array<int, array<string, mixed>>} $dataset */
        $dataset = Cache::remember('ana_muslim_azkar_dataset_v2', now()->addHours(12), function (): array {
            $raw = $this->readJsonFromCandidates([
                base_path('data/azkar.json'),
                base_path('data/azkar/azkar.json'),
                base_path('../assets/azkar.json'),
                public_path('data/azkar.json'),
                storage_path('app/azkar.json'),
            ]);

            if ($raw === null) {
                return [
                    'categories' => [],
                    'items' => [],
                ];
            }

            return $this->parseAzkarDataset($raw);
        });

        return $dataset;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadAsmaEntries(): array
    {
        /** @var array<int, array<string, mixed>> $entries */
        $entries = Cache::remember('ana_muslim_asma_allah_v1', now()->addDays(2), function (): array {
            $raw = $this->readJsonFromCandidates([
                base_path('data/asma_allah.json'),
                base_path('data/asma-allah.json'),
                base_path('../docs/backend/data/asma_allah.json'),
                public_path('data/asma_allah.json'),
                storage_path('app/asma_allah.json'),
            ]);

            if ($raw === null) {
                return [];
            }

            return $this->parseAsmaEntries($raw);
        });

        return $entries;
    }

    /**
     * @return array{categories: array<int, array<string, mixed>>, items: array<int, array<string, mixed>>}
     */
    private function parseAzkarDataset(mixed $raw): array
    {
        $rows = $this->extractAzkarRows($raw);
        $items = [];
        $categoryToId = [];
        $nextCategoryId = 1;
        $nextItemId = 1;

        foreach ($rows as $row) {
            $normalized = $this->normalizeAzkarRow($row, $nextItemId);
            if ($normalized === null) {
                continue;
            }

            $categoryName = (string) $normalized['category'];
            if (!array_key_exists($categoryName, $categoryToId)) {
                $categoryToId[$categoryName] = $nextCategoryId;
                $nextCategoryId++;
            }

            $normalized['chapter_id'] = $categoryToId[$categoryName];
            $items[] = $normalized;
            $nextItemId++;
        }

        $categories = [];
        foreach ($categoryToId as $name => $id) {
            $categories[] = [
                'id' => $id,
                'name' => $name,
            ];
        }

        return [
            'categories' => $categories,
            'items' => $items,
        ];
    }

    /**
     * @return array<int, mixed>
     */
    private function extractAzkarRows(mixed $raw): array
    {
        if (is_array($raw) && $this->isListArray($raw)) {
            return $raw;
        }

        if (!is_array($raw)) {
            return [];
        }

        if (isset($raw['rows']) && is_array($raw['rows'])) {
            return $raw['rows'];
        }
        if (isset($raw['items']) && is_array($raw['items'])) {
            return $raw['items'];
        }
        if (isset($raw['data']) && is_array($raw['data'])) {
            if ($this->isListArray($raw['data'])) {
                return $raw['data'];
            }
            if (isset($raw['data']['rows']) && is_array($raw['data']['rows'])) {
                return $raw['data']['rows'];
            }
            if (isset($raw['data']['items']) && is_array($raw['data']['items'])) {
                return $raw['data']['items'];
            }
        }

        return [];
    }

    /**
     * @return array<string, mixed>|null
     */
    private function normalizeAzkarRow(mixed $row, int $fallbackId): ?array
    {
        if (is_array($row) && $this->isListArray($row)) {
            if (count($row) < 6) {
                return null;
            }

            $category = trim((string) ($row[0] ?? ''));
            $zekr = trim((string) ($row[1] ?? ''));
            if ($category === '' || $zekr === '') {
                return null;
            }

            return [
                'id' => $fallbackId,
                'category' => $category,
                'zekr' => $zekr,
                'description' => (string) ($row[2] ?? ''),
                'count' => max(1, (int) ($row[3] ?? 1)),
                'reference' => (string) ($row[4] ?? ''),
                'search' => (string) ($row[5] ?? ''),
            ];
        }

        if (!is_array($row)) {
            return null;
        }

        $category = trim((string) ($row['category'] ?? ''));
        $zekr = trim((string) ($row['zekr'] ?? $row['text'] ?? ''));
        if ($category === '' || $zekr === '') {
            return null;
        }

        $countRaw = $row['count'] ?? 1;
        $count = (int) (is_numeric($countRaw) ? $countRaw : 1);

        return [
            'id' => (int) ($row['id'] ?? $fallbackId),
            'category' => $category,
            'zekr' => $zekr,
            'description' => (string) ($row['description'] ?? ''),
            'count' => max(1, $count),
            'reference' => (string) ($row['reference'] ?? ''),
            'search' => (string) ($row['search'] ?? $row['search_text'] ?? $row['keywords'] ?? ''),
        ];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function parseAsmaEntries(mixed $raw): array
    {
        $rows = [];
        if (is_array($raw) && $this->isListArray($raw)) {
            $rows = $raw;
        } elseif (is_array($raw)) {
            if (isset($raw['asma_allah']) && is_array($raw['asma_allah'])) {
                $rows = $raw['asma_allah'];
            } elseif (isset($raw['data']) && is_array($raw['data'])) {
                if ($this->isListArray($raw['data'])) {
                    $rows = $raw['data'];
                } elseif (isset($raw['data']['asma_allah']) && is_array($raw['data']['asma_allah'])) {
                    $rows = $raw['data']['asma_allah'];
                }
            }
        }

        $entries = [];
        $nextId = 1;
        foreach ($rows as $row) {
            if (!is_array($row)) {
                continue;
            }
            $name = trim((string) ($row['name'] ?? ''));
            if ($name === '') {
                continue;
            }
            $entries[] = [
                'id'              => (int) ($row['id'] ?? $nextId),
                'number'          => (int) ($row['number'] ?? $row['id'] ?? $nextId),
                'name'            => $name,
                'transliteration' => (string) ($row['transliteration'] ?? ''),
                'meaning'         => (string) ($row['meaning'] ?? $row['description'] ?? $row['explain'] ?? ''),
            ];
            $nextId++;
        }

        return $entries;
    }

    private function readJsonFromCandidates(array $candidates): mixed
    {
        foreach ($candidates as $path) {
            if (!is_string($path) || $path === '') {
                continue;
            }
            if (!File::exists($path)) {
                continue;
            }
            $raw = File::get($path);
            if ($raw === '') {
                continue;
            }
            try {
                return json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
            } catch (\Throwable) {
                continue;
            }
        }

        return null;
    }

    private function isListArray(array $value): bool
    {
        return array_is_list($value);
    }
}
