<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AnaMuslimItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class IslamicContentController extends Controller
{
    private const DEFAULT_LANGUAGE = 'ar';
    private const DEFAULT_PAGE_SIZE = 20;
    private const MAX_PAGE_SIZE = 50;
    private const DEFAULT_HIGHLIGHTS_LIMIT = 12;
    private const MAX_HIGHLIGHTS_LIMIT = 24;
    private const ORDERED_TYPE_KEYS = [
        'showall',
        'audios',
        'videos',
        'books',
        'fatwa',
        'khotab',
        'articles',
        'poster',
        'quran',
        'apps',
        'favorites',
    ];

    /**
     * Get browseable content types with item counts.
     */
    public function getTypes(Request $request): JsonResponse
    {
        $language = $this->sanitizeLanguage($request->query('language', self::DEFAULT_LANGUAGE));
        $sourceLanguage = $this->sanitizeLanguage($request->query('source_language', $language));

        $types = $this->loadTypesFromSiteMetadata($language, $sourceLanguage);
        if ($types === []) {
            $types = $this->loadTypesFromItems($language, $sourceLanguage);
        }

        $totalItems = $this->baseItemsQuery($sourceLanguage)->count();
        $showAll = [
            'block_name' => 'showall',
            'type' => 'showall',
            'items_count' => (int) $totalItems,
            'api_url' => $this->buildItemsApiUrl('showall', $language, $sourceLanguage),
        ];

        $typesByKey = [];
        foreach ($types as $row) {
            $key = $this->normalizeType($row['block_name'] ?? '');
            if ($key === '' || $key === 'showall') {
                continue;
            }
            $typesByKey[$key] = [
                'block_name' => $key,
                'type' => $key,
                'items_count' => (int) ($row['items_count'] ?? 0),
                'api_url' => (string) ($row['api_url'] ?? $this->buildItemsApiUrl($key, $language, $sourceLanguage)),
            ];
        }

        $orderedTypes = array_values($typesByKey);
        usort($orderedTypes, function (array $a, array $b): int {
            $orderA = array_search($a['block_name'], self::ORDERED_TYPE_KEYS, true);
            $orderB = array_search($b['block_name'], self::ORDERED_TYPE_KEYS, true);

            if ($orderA !== false && $orderB !== false) {
                return $orderA <=> $orderB;
            }
            if ($orderA !== false) {
                return -1;
            }
            if ($orderB !== false) {
                return 1;
            }

            return ($b['items_count'] <=> $a['items_count']);
        });

        array_unshift($orderedTypes, $showAll);

        return response()->json($orderedTypes);
    }

    /**
     * Get highlighted content items.
     */
    public function getHighlights(Request $request): JsonResponse
    {
        $language = $this->sanitizeLanguage($request->query('language', self::DEFAULT_LANGUAGE));
        $sourceLanguage = $this->sanitizeLanguage($request->query('source_language', $language));
        $limit = $this->boundInt(
            $request->query('limit', self::DEFAULT_HIGHLIGHTS_LIMIT),
            1,
            self::MAX_HIGHLIGHTS_LIMIT
        );

        $items = $this->baseItemsQuery($sourceLanguage)
            ->whereRaw("CAST(COALESCE(NULLIF(TRIM(importance_level), ''), '0') AS SIGNED) > 0")
            ->orderByRaw("CAST(COALESCE(NULLIF(TRIM(importance_level), ''), '0') AS SIGNED) DESC")
            ->orderByDesc('update_date')
            ->orderByDesc('add_date')
            ->limit($limit)
            ->get();

        // Fallback to latest items when no highlighted records exist.
        if ($items->isEmpty()) {
            $items = $this->baseItemsQuery($sourceLanguage)
                ->orderByDesc('add_date')
                ->limit($limit)
                ->get();
        }

        return response()->json(
            $items->map(fn (AnaMuslimItem $item): array => $this->transformItem($item, false))->values()
        );
    }

    /**
     * Get latest items in paginated payload.
     */
    public function getLatest(Request $request): JsonResponse
    {
        $language = $this->sanitizeLanguage($request->query('language', self::DEFAULT_LANGUAGE));
        $sourceLanguage = $this->sanitizeLanguage($request->query('source_language', $language));
        $perPage = $this->boundInt($request->query('limit', self::DEFAULT_PAGE_SIZE), 1, self::MAX_PAGE_SIZE);
        $page = $this->boundInt($request->query('page', 1), 1, 1000000);

        $paginator = $this->baseItemsQuery($sourceLanguage)
            ->orderByDesc('add_date')
            ->paginate($perPage, ['*'], 'page', $page);

        return response()->json($this->buildPagedPayload($paginator));
    }

    /**
     * Get paginated items by type (e.g., books, audios, showall).
     */
    public function getItems(Request $request, string $type): JsonResponse
    {
        $language = $this->sanitizeLanguage($request->query('language', self::DEFAULT_LANGUAGE));
        $sourceLanguage = $this->sanitizeLanguage($request->query('source_language', $language));
        $normalizedType = $this->normalizeType($type);
        $perPage = $this->boundInt($request->query('limit', self::DEFAULT_PAGE_SIZE), 1, self::MAX_PAGE_SIZE);
        $page = $this->boundInt($request->query('page', 1), 1, 1000000);

        $query = $this->baseItemsQuery($sourceLanguage);
        if ($normalizedType !== '' && $normalizedType !== 'showall') {
            $query->whereRaw('LOWER(TRIM(type)) = ?', [$normalizedType]);
        }

        $paginator = $query
            ->orderByDesc('add_date')
            ->paginate($perPage, ['*'], 'page', $page);

        return response()->json($this->buildPagedPayload($paginator));
    }

    /**
     * Get full details of a specific item, including authors, locales, and attachments.
     */
    public function getItemDetails(int|string $id): JsonResponse
    {
        $item = AnaMuslimItem::with(['authors', 'attachments', 'locales'])
            ->where('source_id', $id)
            ->first();

        // Fallback to local auto-incrementing ID mapping for compatibility.
        if (!$item) {
            $item = AnaMuslimItem::with(['authors', 'attachments', 'locales'])
                ->find($id);
        }

        if (!$item) {
            return response()->json(['error' => 'Item not found'], 404);
        }

        return response()->json($this->transformItem($item, true));
    }

    /**
     * @return array<string, mixed>
     */
    private function transformItem(AnaMuslimItem $item, bool $withDetails): array
    {
        $externalId = (int) ($item->source_id ?: $item->id);
        $normalizedType = $this->normalizeType((string) ($item->type ?? ''));

        $payload = [
            'id' => $externalId,
            'source_id' => $externalId,
            'title' => (string) $item->title,
            'type' => $normalizedType,
            'add_date' => (int) ($item->add_date ?? 0),
            'update_date' => (int) ($item->update_date ?? 0),
            'description' => $item->description,
            'full_description' => $item->full_description,
            'image' => $this->sanitizeUrl($item->image),
            'source_language' => $item->source_language,
            'translated_language' => $item->translated_language,
            'api_url' => $item->api_url,
        ];

        if (!$withDetails) {
            return $payload;
        }

        $payload['content'] = $item->full_description ?? $item->description;
        $payload['prepared_by'] = $item->authors
            ->map(function ($author): array {
                $authorId = (int) ($author->source_id ?: $author->id);

                return [
                    'id' => $authorId,
                    'title' => (string) $author->title,
                    'kind' => (string) ($author->kind ?: $author->type ?: 'author'),
                ];
            })
            ->values()
            ->all();

        $payload['attachments'] = $item->attachments
            ->sortBy('order')
            ->map(fn ($attachment): array => [
                'url' => (string) $attachment->url,
                'description' => (string) ($attachment->description ?? ''),
                'extension_type' => (string) ($attachment->extension_type ?? ''),
                'size' => (string) ($attachment->size ?? ''),
            ])
            ->values()
            ->all();

        $payload['locales'] = $item->locales
            ->map(fn ($locale): array => [
                'language' => (string) $locale->language,
                'url' => (string) $locale->url,
            ])
            ->values()
            ->all();

        return $payload;
    }

    /**
     * @return array{data: array<int, array<string, mixed>>, links: array<string, mixed>}
     */
    private function buildPagedPayload(LengthAwarePaginator $paginator): array
    {
        $data = $paginator
            ->getCollection()
            ->map(fn (AnaMuslimItem $item): array => $this->transformItem($item, false))
            ->values()
            ->all();

        return [
            'data' => $data,
            'links' => [
                'current_page' => $paginator->currentPage(),
                'pages_number' => $paginator->lastPage(),
                'total_items' => $paginator->total(),
                'per_page' => $paginator->perPage(),
                'has_more' => $paginator->hasMorePages(),
            ],
        ];
    }

    /**
     * @return \Illuminate\Database\Eloquent\Builder
     */
    private function baseItemsQuery(string $sourceLanguage)
    {
        $query = AnaMuslimItem::query()
            ->whereRaw("TRIM(COALESCE(title, '')) <> ''");

        if ($sourceLanguage !== '') {
            $query->whereRaw('LOWER(TRIM(COALESCE(source_language, ?))) = ?', [$sourceLanguage, $sourceLanguage]);
        }

        return $query;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadTypesFromSiteMetadata(string $language, string $sourceLanguage): array
    {
        if (!Schema::hasTable('islamhouse_available_types')) {
            return [];
        }

        $rows = DB::table('islamhouse_available_types')
            ->select('block_name', 'type')
            ->selectRaw('MAX(items_count) as items_count')
            ->selectRaw('MAX(api_url) as api_url')
            ->where('scope_type', 'site')
            ->where(function ($query) use ($language): void {
                $query->whereNull('language')
                    ->orWhereRaw('LOWER(TRIM(language)) = ?', [$language]);
            })
            ->groupBy('block_name', 'type')
            ->get();

        $typesByKey = [];
        foreach ($rows as $row) {
            $blockName = $this->normalizeType((string) ($row->block_name ?? ''));
            $rawType = $this->normalizeType((string) ($row->type ?? ''));

            if ($blockName === '') {
                $blockName = $rawType !== 'section' ? $rawType : '';
            }

            if ($blockName === '') {
                continue;
            }

            $typesByKey[$blockName] = [
                'block_name' => $blockName,
                'type' => $blockName,
                'items_count' => (int) ($row->items_count ?? 0),
                'api_url' => $this->buildItemsApiUrl($blockName, $language, $sourceLanguage),
            ];
        }

        return array_values($typesByKey);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadTypesFromItems(string $language, string $sourceLanguage): array
    {
        $rows = $this->baseItemsQuery($sourceLanguage)
            ->selectRaw('LOWER(TRIM(type)) as block_name')
            ->selectRaw('COUNT(*) as items_count')
            ->whereRaw("TRIM(COALESCE(type, '')) <> ''")
            ->groupBy('block_name')
            ->get();

        $result = [];
        foreach ($rows as $row) {
            $blockName = $this->normalizeType((string) ($row->block_name ?? ''));
            if ($blockName === '') {
                continue;
            }

            $result[] = [
                'block_name' => $blockName,
                'type' => $blockName,
                'items_count' => (int) ($row->items_count ?? 0),
                'api_url' => $this->buildItemsApiUrl($blockName, $language, $sourceLanguage),
            ];
        }

        return $result;
    }

    private function sanitizeLanguage(mixed $language): string
    {
        $value = Str::lower(trim((string) $language));
        $value = preg_replace('/[^a-z0-9_-]/', '', $value) ?: '';

        return $value !== '' ? $value : self::DEFAULT_LANGUAGE;
    }

    private function normalizeType(string $type): string
    {
        return Str::lower(trim($type));
    }

    private function boundInt(mixed $value, int $min, int $max): int
    {
        $parsed = is_numeric($value) ? (int) $value : $min;
        return max($min, min($max, $parsed));
    }

    private function buildItemsApiUrl(string $type, string $language, string $sourceLanguage): string
    {
        $requestBase = request()->getSchemeAndHttpHost();
        $base = trim((string) $requestBase) !== ''
            ? rtrim((string) $requestBase, '/')
            : rtrim((string) config('app.url'), '/');

        $query = http_build_query([
            'language' => $language,
            'source_language' => $sourceLanguage,
        ]);

        return "{$base}/api/islamic-content/items/{$type}?{$query}";
    }

    private function sanitizeUrl(?string $url): ?string
    {
        $value = trim((string) $url);
        if ($value === '') {
            return null;
        }

        if (Str::startsWith($value, ['http://', 'https://'])) {
            return $value;
        }

        return null;
    }
}
