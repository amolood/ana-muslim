<?php

namespace App\Console\Commands;

use App\Support\IslamhouseApi;
use Illuminate\Console\Command;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class ImportIslamhouseFull extends Command
{
    protected $signature = 'import:islamhouse-full
        {language=ar : UI language code used for endpoints that require locale}
        {--collection=../Islamhouse API v3.postman_collection.json : Postman collection path relative to backend/}
        {--memory-limit= : Runtime PHP memory_limit override (e.g. 1024M)}
        {--max-pages=200 : Maximum page count for paginated author catalog import}
        {--sura-max=114 : Maximum sura number for Quran sura scan}
        {--with-items : Also import full items via categories + queue}
        {--with-category-sync : Populate ana_muslim_item_category after item import}';

    protected $description = 'Import Islamhouse API v3 resources from the full Postman collection into local DB.';

    private int $snapshotWrites = 0;
    private int $requestOk = 0;
    private int $requestFail = 0;

    public function handle(): int
    {
        $language = (string) $this->argument('language');
        $memoryLimit = trim((string) ($this->option('memory-limit') ?: config('islamhouse.import_memory_limit', '1024M')));
        $this->applyMemoryLimit($memoryLimit);

        $collectionPath = $this->resolveCollectionPath((string) $this->option('collection'));

        if (!File::exists($collectionPath)) {
            $this->error("Collection file not found: {$collectionPath}");
            return self::FAILURE;
        }

        $endpoints = $this->loadCollectionEndpoints($collectionPath);
        if (count($endpoints) === 0) {
            $this->error('No endpoints found in collection.');
            return self::FAILURE;
        }

        $this->info("Loaded " . count($endpoints) . " endpoints from collection.");

        $bar = $this->output->createProgressBar(count($endpoints));
        $bar->start();

        foreach ($endpoints as $endpoint) {
            $this->fetchAndProcessEndpoint(
                group: $endpoint['group'],
                name: $endpoint['name'],
                method: $endpoint['method'],
                rawUrl: $endpoint['url'],
                fallbackLanguage: $language
            );

            $bar->advance();
        }

        $bar->finish();
        $this->newLine(2);

        $this->info('Expanding paginated authors catalog...');
        $this->importAuthorPages($language, (int) $this->option('max-pages'));

        $this->info('Expanding Quran resources (categories, authors, recitations, suras)...');
        $this->expandQuranResources($language, (int) $this->option('sura-max'));

        if ((bool) $this->option('with-items')) {
            $this->info('Starting full item import (categories + queue)...');
            $this->call('import:ana-muslim-categories', [
                'language' => $language,
                'sourceLanguage' => $language,
            ]);

            $this->drainQueue();

            if ((bool) $this->option('with-category-sync')) {
                $this->info('Syncing item-category pivot table...');
                $this->call('sync:missing-categories', [
                    '--language' => $language,
                    '--source-language' => $language,
                    '--memory-limit' => $memoryLimit,
                ]);
            }
        }

        $this->printSummary();

        return self::SUCCESS;
    }

    private function resolveCollectionPath(string $option): string
    {
        $trimmed = trim($option);

        if ($trimmed === '') {
            return base_path('../Islamhouse API v3.postman_collection.json');
        }

        if (Str::startsWith($trimmed, '/')) {
            return $trimmed;
        }

        return base_path($trimmed);
    }

    /**
     * @return array<int, array{group:string,name:string,method:string,url:string}>
     */
    private function loadCollectionEndpoints(string $collectionPath): array
    {
        $json = json_decode((string) File::get($collectionPath), true);

        if (!is_array($json) || !isset($json['item']) || !is_array($json['item'])) {
            return [];
        }

        $endpoints = [];

        $walk = function (array $items, ?string $group = null) use (&$walk, &$endpoints): void {
            foreach ($items as $item) {
                if (!is_array($item)) {
                    continue;
                }

                if (isset($item['item']) && is_array($item['item'])) {
                    $walk($item['item'], (string) ($item['name'] ?? $group ?? 'General'));
                    continue;
                }

                $request = $item['request'] ?? null;
                if (!is_array($request)) {
                    continue;
                }

                $method = strtoupper((string) ($request['method'] ?? 'GET'));
                if ($method === '') {
                    $method = 'GET';
                }

                $urlRaw = $request['url']['raw'] ?? null;
                if (!is_string($urlRaw) || trim($urlRaw) === '') {
                    continue;
                }

                $endpoints[] = [
                    'group' => (string) ($group ?? 'General'),
                    'name' => (string) ($item['name'] ?? 'Unnamed endpoint'),
                    'method' => $method,
                    'url' => trim($urlRaw),
                ];
            }
        };

        $walk($json['item']);

        return $endpoints;
    }

    private function fetchAndProcessEndpoint(
        string $group,
        string $name,
        string $method,
        string $rawUrl,
        string $fallbackLanguage
    ): void {
        $url = IslamhouseApi::normalizeUrl($rawUrl);

        try {
            $response = Http::timeout((int) config('islamhouse.timeout', 90))
                ->retry(
                    (int) config('islamhouse.retry_times', 2),
                    (int) config('islamhouse.retry_sleep_ms', 500)
                )
                ->send($method, $url);
        } catch (\Throwable $e) {
            $this->requestFail++;
            $this->storeSnapshot($group, $name, $method, $url, null, null, $e->getMessage());
            $this->warn("Request failed for {$name}: {$e->getMessage()}");
            return;
        }

        $statusCode = $response->status();
        $body = $response->body();

        $decoded = json_decode($body, true);
        $isJson = json_last_error() === JSON_ERROR_NONE;

        if ($statusCode >= 200 && $statusCode < 300) {
            $this->requestOk++;
        } else {
            $this->requestFail++;
        }

        $this->storeSnapshot(
            group: $group,
            name: $name,
            method: $method,
            url: $url,
            statusCode: $statusCode,
            payload: $isJson ? $decoded : null,
            rawBody: $isJson ? null : $body
        );

        if ($statusCode >= 200 && $statusCode < 300 && $isJson) {
            $this->processPayloadForUrl($url, $decoded, $fallbackLanguage);
        }
    }

    private function storeSnapshot(
        string $group,
        string $name,
        string $method,
        string $url,
        ?int $statusCode,
        mixed $payload,
        ?string $rawBody = null
    ): void {
        $payloadJson = is_null($payload) ? null : $this->encodeJson($payload);
        $rawPayload = $rawBody ?? $payloadJson;

        DB::table('islamhouse_endpoint_snapshots')->updateOrInsert(
            ['request_url_hash' => hash('sha256', $url)],
            [
                'endpoint_slug' => Str::slug($group . '-' . $name),
                'endpoint_group' => $group,
                'endpoint_name' => $name,
                'method' => strtoupper($method),
                'request_url' => $url,
                'status_code' => $statusCode,
                'payload' => $payloadJson,
                'raw_body' => $rawPayload,
                'response_hash' => $rawPayload ? hash('sha256', $rawPayload) : null,
                'fetched_at' => now(),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        $this->snapshotWrites++;
    }

    private function processPayloadForUrl(string $url, mixed $payload, string $fallbackLanguage): void
    {
        $path = (string) (parse_url($url, PHP_URL_PATH) ?? '');

        if ($path === '') {
            return;
        }

        if (preg_match('#/languages/get-language-details/json$#', $path) === 1) {
            $this->persistLanguageDetails($payload);
            return;
        }

        if (preg_match('#/languages/get-language-terms/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistLanguageTerms($payload, $m[1]);
            return;
        }

        if (preg_match('#/languages/get-social/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistSiteSettingMap('social', $payload, $m[1]);
            return;
        }

        if (preg_match('#/main/get-footer/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistFooterItems($payload, $m[1]);
            return;
        }

        if (preg_match('#/main/get-language-items-count/([^/]+)/([^/]+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistItemCount($payload, $m[1], $m[2], $m[3]);
            return;
        }

        if (preg_match('#/main/get-available-languages/[^/]+/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistAvailableLanguages($payload, 'global', null, $m[1]);
            return;
        }

        if (preg_match('#/main/get-category-source-languages/(\d+)/[^/]+/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistAvailableLanguages($payload, 'category', (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/main/get-author-available-languages/(\d+)/[^/]+/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistAvailableLanguages($payload, 'author', (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/main/get-category-types-available/(\d+)/([^/]+)/[^/]+/json$#', $path, $m) === 1) {
            $this->persistAvailableTypes($payload, 'category', (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/main/get-author-types-avaliable/(\d+)/([^/]+)/[^/]+/json$#', $path, $m) === 1) {
            $this->persistAvailableTypes($payload, 'author', (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/main/sitecontent/([^/]+)/#', $path, $m) === 1) {
            $lang = $m[1] ?: $fallbackLanguage;
            $this->persistSiteSections($payload, $lang);
            $this->persistAvailableTypes($payload, 'site', null, $lang);
            return;
        }

        if (preg_match('#/categories/showall/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistFlatCategories($payload, $m[1]);
            return;
        }

        if (preg_match('#/main/get-object-category-tree/([^/]+)/json$#', $path, $m) === 1) {
            if (is_array($payload)) {
                $this->persistCategoryTreeNode($payload, null, $m[1]);
            }
            return;
        }

        if (preg_match('#/main/get-sub-categories/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            if (is_array($payload)) {
                $this->persistCategoryTreeNode($payload, null, $m[2]);
            }
            return;
        }

        if (preg_match('#/main/get-authors-data/#', $path) === 1) {
            $this->persistAuthorsList($payload, $fallbackLanguage);
            return;
        }

        if (preg_match('#/main/home/json$#', $path) === 1) {
            $this->persistSiteSettingMap('home', $payload, $fallbackLanguage);
            $statistics = Arr::get($payload, 'statistics');
            if (is_array($statistics)) {
                $this->persistSiteSettingMap('home_statistics', $statistics, $fallbackLanguage);
            }
            $data = Arr::get($payload, 'data');
            if (is_array($data)) {
                $this->persistSiteSettingMap('home_data', $data, $fallbackLanguage);
            }
            return;
        }

        if (preg_match('#/quran/get-categories/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranCategories($payload, $m[1]);
            return;
        }

        if (preg_match('#/quran/get-category/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranCategoryDetail($payload, (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/quran/get-author/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranAuthorDetail($payload, (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/quran/get-author-recitations/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranAuthorRecitations($payload, (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/quran/get-recitation/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranRecitationDetail($payload, (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/quran/get-sura/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranSuraDetail($payload, (int) $m[1], $m[2]);
            return;
        }

        if (preg_match('#/quran/get-sura-recitations/(\d+)/([^/]+)/json$#', $path, $m) === 1) {
            $this->persistQuranSuraRecitations($payload, (int) $m[1], $m[2]);
        }
    }

    private function persistSiteSections(mixed $payload, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $rows = [];

        foreach ($payload as $row) {
            if (!is_array($row)) {
                continue;
            }

            $blockName = (string) ($row['block_name'] ?? $row['type'] ?? 'unknown');

            $rows[] = [
                'language' => $language,
                'block_name' => $blockName,
                'section_type' => $row['type'] ?? null,
                'items_count' => (int) ($row['items_count'] ?? 0),
                'api_url' => $row['api_url'] ?? null,
                'payload' => $this->encodeJson($row),
                'updated_at' => now(),
                'created_at' => now(),
            ];
        }

        if ($rows !== []) {
            DB::table('islamhouse_site_sections')->upsert(
                $rows,
                ['language', 'block_name'],
                ['section_type', 'items_count', 'api_url', 'payload', 'updated_at']
            );
        }
    }

    private function persistFlatCategories(mixed $payload, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        foreach ($payload as $category) {
            if (!is_array($category) || !isset($category['id']) || !is_numeric($category['id'])) {
                continue;
            }

            $id = (int) $category['id'];

            DB::table('ana_muslim_categories')->updateOrInsert(
                ['id' => $id],
                [
                    'title' => (string) ($category['title'] ?? 'Untitled'),
                    'block_name' => null,
                    'items_count' => 0,
                    'language' => $language,
                    'parent_id' => null,
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistCategoryTreeNode(array $node, ?int $parentId, string $language): void
    {
        $id = null;

        if (isset($node['source_id']) && is_numeric($node['source_id'])) {
            $id = (int) $node['source_id'];
        } elseif (isset($node['id']) && is_numeric($node['id'])) {
            $id = (int) $node['id'];
        }

        if ($id === null || $id <= 0) {
            return;
        }

        DB::table('ana_muslim_categories')->updateOrInsert(
            ['id' => $id],
            [
                'title' => (string) ($node['title'] ?? 'Untitled'),
                'block_name' => $node['block_name'] ?? null,
                'items_count' => (int) ($node['items_count'] ?? 0),
                'language' => $language,
                'parent_id' => $parentId,
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        $children = $node['sub_categories'] ?? [];
        if (!is_array($children)) {
            return;
        }

        foreach ($children as $child) {
            if (is_array($child)) {
                $this->persistCategoryTreeNode($child, $id, $language);
            }
        }
    }

    private function persistAuthorsList(mixed $payload, string $language): void
    {
        $rows = is_array($payload) && isset($payload['data']) && is_array($payload['data'])
            ? $payload['data']
            : (is_array($payload) ? $payload : []);

        foreach ($rows as $author) {
            if (!is_array($author) || !isset($author['id']) || !is_numeric($author['id'])) {
                continue;
            }

            $sourceId = (int) $author['id'];

            DB::table('ana_muslim_authors')->updateOrInsert(
                ['source_id' => $sourceId],
                [
                    'title' => (string) ($author['title'] ?? 'Untitled'),
                    'type' => $author['type'] ?? null,
                    'kind' => $author['kind'] ?? null,
                    'description' => $author['description'] ?? null,
                    'api_url' => $author['api_url'] ?? null,
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistLanguageDetails(mixed $payload): void
    {
        if (!is_array($payload)) {
            return;
        }

        foreach ($payload as $code => $value) {
            if (!is_string($code) || $code === '') {
                continue;
            }

            DB::table('islamhouse_languages')->updateOrInsert(
                ['language_code' => $code],
                [
                    'name' => is_scalar($value) ? (string) $value : null,
                    'payload' => $this->encodeJson($value),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistLanguageTerms(mixed $payload, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $rows = [];
        foreach ($payload as $key => $value) {
            if (!is_string($key) || $key === '') {
                continue;
            }

            $rows[] = [
                'language' => $language,
                'term_key' => $key,
                'term_value' => is_scalar($value) ? (string) $value : $this->encodeJson($value),
                'updated_at' => now(),
                'created_at' => now(),
            ];
        }

        foreach (array_chunk($rows, 500) as $chunk) {
            DB::table('islamhouse_language_terms')->upsert(
                $chunk,
                ['language', 'term_key'],
                ['term_value', 'updated_at']
            );
        }
    }

    private function persistAvailableLanguages(mixed $payload, string $scopeType, ?int $scopeId, ?string $contextLanguage): void
    {
        if (!is_array($payload)) {
            return;
        }

        $rows = [];

        foreach ($payload as $entry) {
            if (is_array($entry)) {
                $code = (string) ($entry['langsymbol'] ?? $entry['str'] ?? '');
                $name = isset($entry['langtranslation']) ? (string) $entry['langtranslation'] : null;
                $entryPayload = $entry;
            } elseif (is_string($entry)) {
                $code = $entry;
                $name = null;
                $entryPayload = ['value' => $entry];
            } else {
                continue;
            }

            if ($code === '') {
                continue;
            }

            $rows[] = [
                'scope_type' => $scopeType,
                'scope_id' => $scopeId,
                'context_language' => $contextLanguage,
                'language_code' => $code,
                'language_name' => $name,
                'payload' => $this->encodeJson($entryPayload),
                'updated_at' => now(),
                'created_at' => now(),
            ];
        }

        if ($rows !== []) {
            DB::table('islamhouse_available_languages')->upsert(
                $rows,
                ['scope_type', 'scope_id', 'context_language', 'language_code'],
                ['language_name', 'payload', 'updated_at']
            );
        }
    }

    private function persistAvailableTypes(mixed $payload, string $scopeType, ?int $scopeId, ?string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $rows = [];
        foreach ($payload as $entry) {
            if (!is_array($entry)) {
                continue;
            }

            $type = (string) ($entry['type'] ?? '');
            if ($type === '') {
                continue;
            }

            $rows[] = [
                'scope_type' => $scopeType,
                'scope_id' => $scopeId,
                'language' => $language,
                'type' => $type,
                'block_name' => $entry['block_name'] ?? null,
                'items_count' => (int) ($entry['items_count'] ?? 0),
                'api_url' => $entry['api_url'] ?? null,
                'payload' => $this->encodeJson($entry),
                'updated_at' => now(),
                'created_at' => now(),
            ];
        }

        if ($rows !== []) {
            DB::table('islamhouse_available_types')->upsert(
                $rows,
                ['scope_type', 'scope_id', 'language', 'type'],
                ['block_name', 'items_count', 'api_url', 'payload', 'updated_at']
            );
        }
    }

    private function persistItemCount(mixed $payload, string $type, ?string $sourceLanguage, ?string $translatedLanguage): void
    {
        if (!is_array($payload)) {
            return;
        }

        DB::table('islamhouse_item_counts')->updateOrInsert(
            [
                'item_type' => $type,
                'source_language' => $sourceLanguage,
                'translated_language' => $translatedLanguage,
            ],
            [
                'items_count' => (int) ($payload['items_count'] ?? 0),
                'payload' => $this->encodeJson($payload),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );
    }

    private function persistSiteSettingMap(string $section, mixed $payload, ?string $language): void
    {
        if (!is_array($payload)) {
            DB::table('islamhouse_site_settings')->updateOrInsert(
                ['section' => $section, 'setting_key' => 'payload', 'language' => $language],
                [
                    'setting_value' => $this->encodeJson($payload),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
            return;
        }

        foreach ($payload as $key => $value) {
            $settingKey = is_string($key) ? $key : 'item_' . $key;

            DB::table('islamhouse_site_settings')->updateOrInsert(
                ['section' => $section, 'setting_key' => $settingKey, 'language' => $language],
                [
                    'setting_value' => $this->encodeJson($value),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistFooterItems(mixed $payload, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        foreach ($payload as $item) {
            if (!is_array($item)) {
                continue;
            }

            $sourceId = isset($item['source_id']) && is_numeric($item['source_id']) ? (int) $item['source_id'] : null;

            $externalKey = $sourceId
                ? hash('sha256', $language . ':' . $sourceId)
                : hash('sha256', $language . ':' . (string) ($item['title'] ?? '') . ':' . (string) ($item['url'] ?? ''));

            DB::table('islamhouse_footer_items')->updateOrInsert(
                ['external_key' => $externalKey],
                [
                    'source_id' => $sourceId,
                    'language' => $language,
                    'title' => $item['title'] ?? null,
                    'description' => $item['description'] ?? null,
                    'full_description' => $item['full_description'] ?? null,
                    'type' => $item['type'] ?? null,
                    'add_type' => $item['add_type'] ?? null,
                    'order' => isset($item['order']) ? (int) $item['order'] : null,
                    'enabled' => isset($item['enabled']) ? (bool) $item['enabled'] : null,
                    'url' => $item['url'] ?? null,
                    'attachments' => $this->encodeJson($item['attachments'] ?? []),
                    'payload' => $this->encodeJson($item),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistQuranCategories(mixed $payload, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $rows = [];

        foreach ($payload as $category) {
            if (!is_array($category) || !isset($category['id']) || !is_numeric($category['id'])) {
                continue;
            }

            $rows[] = [
                'source_id' => (int) $category['id'],
                'language' => $language,
                'title' => $category['title'] ?? null,
                'description' => $category['description'] ?? null,
                'type' => $category['type'] ?? null,
                'has_children' => (bool) ($category['has_children'] ?? false),
                'api_url' => $category['api_url'] ?? null,
                'payload' => $this->encodeJson($category),
                'updated_at' => now(),
                'created_at' => now(),
            ];
        }

        if ($rows !== []) {
            DB::table('islamhouse_quran_categories')->upsert(
                $rows,
                ['source_id'],
                ['language', 'title', 'description', 'type', 'has_children', 'api_url', 'payload', 'updated_at']
            );
        }
    }

    private function persistQuranCategoryDetail(mixed $payload, int $categoryId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        DB::table('islamhouse_quran_categories')->updateOrInsert(
            ['source_id' => $categoryId],
            [
                'language' => $language,
                'title' => $payload['title'] ?? null,
                'description' => $payload['description'] ?? null,
                'type' => $payload['type'] ?? null,
                'has_children' => false,
                'api_url' => null,
                'payload' => $this->encodeJson($payload),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        $authors = $payload['authors'] ?? [];
        if (!is_array($authors)) {
            return;
        }

        foreach ($authors as $author) {
            if (!is_array($author) || !isset($author['id']) || !is_numeric($author['id'])) {
                continue;
            }

            $authorId = (int) $author['id'];

            DB::table('islamhouse_quran_authors')->updateOrInsert(
                ['source_id' => $authorId],
                [
                    'language' => $language,
                    'title' => $author['title'] ?? null,
                    'type' => $author['type'] ?? null,
                    'payload' => $this->encodeJson($author),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            DB::table('islamhouse_quran_category_author')->updateOrInsert(
                [
                    'category_source_id' => $categoryId,
                    'author_source_id' => $authorId,
                ],
                [
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistQuranAuthorDetail(mixed $payload, int $authorId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $recitationIds = [];

        $recitations = $payload['recitations'] ?? [];
        if (is_array($recitations)) {
            foreach ($recitations as $recitation) {
                if (is_array($recitation) && isset($recitation['id']) && is_numeric($recitation['id'])) {
                    $recitationIds[] = (int) $recitation['id'];
                    DB::table('islamhouse_quran_recitations')->updateOrInsert(
                        ['source_id' => (int) $recitation['id']],
                        [
                            'language' => $language,
                            'title' => $recitation['title'] ?? null,
                            'description' => $recitation['description'] ?? null,
                            'payload' => $this->encodeJson($recitation),
                            'updated_at' => now(),
                            'created_at' => now(),
                        ]
                    );
                } elseif (is_numeric($recitation)) {
                    $recitationIds[] = (int) $recitation;
                }
            }
        }

        $recitationsInfo = $payload['recitations_info'] ?? [];
        if (is_array($recitationsInfo)) {
            foreach ($recitationsInfo as $recitation) {
                if (!is_array($recitation) || !isset($recitation['id']) || !is_numeric($recitation['id'])) {
                    continue;
                }

                $recitationId = (int) $recitation['id'];
                $recitationIds[] = $recitationId;

                DB::table('islamhouse_quran_recitations')->updateOrInsert(
                    ['source_id' => $recitationId],
                    [
                        'language' => $language,
                        'title' => $recitation['title'] ?? null,
                        'description' => $recitation['description'] ?? null,
                        'payload' => $this->encodeJson($recitation),
                        'updated_at' => now(),
                        'created_at' => now(),
                    ]
                );
            }
        }

        DB::table('islamhouse_quran_authors')->updateOrInsert(
            ['source_id' => $authorId],
            [
                'language' => $language,
                'title' => $payload['title'] ?? null,
                'type' => $payload['type'] ?? null,
                'source_language' => $payload['source_language'] ?? null,
                'translation_language' => $payload['translation_language'] ?? null,
                'recitations_count' => count(array_unique($recitationIds)),
                'payload' => $this->encodeJson($payload),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        foreach (array_unique($recitationIds) as $recitationId) {
            DB::table('islamhouse_quran_author_recitation')->updateOrInsert(
                [
                    'author_source_id' => $authorId,
                    'recitation_source_id' => $recitationId,
                ],
                [
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistQuranAuthorRecitations(mixed $payload, int $authorId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        foreach ($payload as $recitation) {
            if (!is_array($recitation) || !isset($recitation['id']) || !is_numeric($recitation['id'])) {
                continue;
            }

            $recitationId = (int) $recitation['id'];

            DB::table('islamhouse_quran_recitations')->updateOrInsert(
                ['source_id' => $recitationId],
                [
                    'language' => $language,
                    'title' => $recitation['title'] ?? null,
                    'description' => $recitation['description'] ?? null,
                    'payload' => $this->encodeJson($recitation),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            DB::table('islamhouse_quran_author_recitation')->updateOrInsert(
                [
                    'author_source_id' => $authorId,
                    'recitation_source_id' => $recitationId,
                ],
                [
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistQuranRecitationDetail(mixed $payload, int $recitationId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        $attachments = is_array($payload['attachments'] ?? null) ? $payload['attachments'] : [];
        $firstAttachment = (is_array($attachments) && isset($attachments[0]) && is_array($attachments[0])) ? $attachments[0] : [];

        DB::table('islamhouse_quran_recitations')->updateOrInsert(
            ['source_id' => $recitationId],
            [
                'language' => $language,
                'title' => $payload['title'] ?? null,
                'description' => $payload['description'] ?? null,
                'primary_url' => $firstAttachment['url'] ?? null,
                'extension_type' => $firstAttachment['extension_type'] ?? null,
                'size' => isset($firstAttachment['size']) ? (string) $firstAttachment['size'] : null,
                'attachments' => $this->encodeJson($attachments),
                'payload' => $this->encodeJson($payload),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        $preparedBy = $payload['prepared_by'] ?? [];
        if (!is_array($preparedBy)) {
            return;
        }

        foreach ($preparedBy as $author) {
            if (!is_array($author) || !isset($author['id']) || !is_numeric($author['id'])) {
                continue;
            }

            $authorId = (int) $author['id'];

            DB::table('islamhouse_quran_authors')->updateOrInsert(
                ['source_id' => $authorId],
                [
                    'language' => $language,
                    'title' => $author['title'] ?? null,
                    'type' => $author['type'] ?? null,
                    'payload' => $this->encodeJson($author),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            DB::table('islamhouse_quran_author_recitation')->updateOrInsert(
                [
                    'author_source_id' => $authorId,
                    'recitation_source_id' => $recitationId,
                ],
                [
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function persistQuranSuraDetail(mixed $payload, int $suraId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        DB::table('islamhouse_quran_suras')->updateOrInsert(
            ['source_id' => $suraId],
            [
                'language' => $language,
                'title' => $payload['title'] ?? null,
                'url' => $payload['url'] ?? null,
                'extension_type' => $payload['extension_type'] ?? null,
                'size' => isset($payload['sizex']) ? (string) $payload['sizex'] : (isset($payload['size']) ? (string) $payload['size'] : null),
                'payload' => $this->encodeJson($payload),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );
    }

    private function persistQuranSuraRecitations(mixed $payload, int $suraId, string $language): void
    {
        if (!is_array($payload)) {
            return;
        }

        foreach ($payload as $recitation) {
            if (!is_array($recitation) || !isset($recitation['id']) || !is_numeric($recitation['id'])) {
                continue;
            }

            $recitationId = (int) $recitation['id'];

            DB::table('islamhouse_quran_recitations')->updateOrInsert(
                ['source_id' => $recitationId],
                [
                    'language' => $language,
                    'title' => $recitation['title'] ?? null,
                    'description' => $recitation['description'] ?? null,
                    'payload' => $this->encodeJson($recitation),
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            DB::table('islamhouse_quran_sura_recitation')->updateOrInsert(
                [
                    'sura_source_id' => $suraId,
                    'recitation_source_id' => $recitationId,
                ],
                [
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    private function importAuthorPages(string $language, int $maxPages): void
    {
        $page = 1;
        $maxPages = max(1, $maxPages);

        while ($page <= $maxPages) {
            $url = IslamhouseApi::url("main/get-authors-data/showall/showall/countdesc/{$language}/{$page}/100/json");

            $response = Http::timeout((int) config('islamhouse.timeout', 90))
                ->retry((int) config('islamhouse.retry_times', 2), (int) config('islamhouse.retry_sleep_ms', 500))
                ->get($url);

            $payload = $response->json();
            $this->storeSnapshot(
                'Authors (expanded)',
                "Authors page {$page}",
                'GET',
                $url,
                $response->status(),
                $payload,
                null
            );

            if (!$response->successful() || !is_array($payload)) {
                break;
            }

            $this->persistAuthorsList($payload, $language);

            if (empty($payload['links']['next'])) {
                break;
            }

            $page++;
        }

        $this->line("Authors pages imported: {$page}");
    }

    private function expandQuranResources(string $language, int $suraMax): void
    {
        $categoryIds = DB::table('islamhouse_quran_categories')->pluck('source_id')->filter()->values();
        $bar = $this->output->createProgressBar(max(1, $categoryIds->count()));
        $bar->start();

        foreach ($categoryIds as $categoryId) {
            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Category {$categoryId}",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-category/{$categoryId}/{$language}/json"),
                fallbackLanguage: $language
            );
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();

        $authorIds = DB::table('islamhouse_quran_category_author')
            ->pluck('author_source_id')
            ->filter()
            ->unique()
            ->values();
        $bar = $this->output->createProgressBar(max(1, $authorIds->count()));
        $bar->start();

        foreach ($authorIds as $authorId) {
            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Author {$authorId}",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-author/{$authorId}/{$language}/json"),
                fallbackLanguage: $language
            );

            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Author {$authorId} recitations",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-author-recitations/{$authorId}/{$language}/json"),
                fallbackLanguage: $language
            );
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();

        $recitationIds = DB::table('islamhouse_quran_recitations')->pluck('source_id')->filter()->unique()->values();
        $bar = $this->output->createProgressBar(max(1, $recitationIds->count()));
        $bar->start();

        foreach ($recitationIds as $recitationId) {
            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Recitation {$recitationId}",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-recitation/{$recitationId}/{$language}/json"),
                fallbackLanguage: $language
            );
            $bar->advance();
        }
        $bar->finish();
        $this->newLine();

        $suraMax = max(1, min(114, $suraMax));
        $bar = $this->output->createProgressBar($suraMax);
        $bar->start();

        for ($suraId = 1; $suraId <= $suraMax; $suraId++) {
            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Sura {$suraId}",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-sura/{$suraId}/{$language}/json"),
                fallbackLanguage: $language
            );

            $this->fetchAndProcessEndpoint(
                group: 'Quran',
                name: "Sura {$suraId} recitations",
                method: 'GET',
                rawUrl: IslamhouseApi::url("quran/get-sura-recitations/{$suraId}/{$language}/json"),
                fallbackLanguage: $language
            );

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();
    }

    private function drainQueue(): void
    {
        $stagnantRuns = 0;

        for ($iteration = 1; $iteration <= 100; $iteration++) {
            $pendingBefore = (int) DB::table('jobs')->count();
            if ($pendingBefore === 0) {
                $this->info('Queue is empty.');
                return;
            }

            $this->line("Queue pending: {$pendingBefore} (pass {$iteration})");

            $this->call('queue:work', [
                '--stop-when-empty' => true,
                '--sleep' => 1,
                '--tries' => 3,
                '--timeout' => 180,
                '--memory' => (int) config('islamhouse.queue_worker_memory', 512),
                '--queue' => 'default',
            ]);

            $pendingAfter = (int) DB::table('jobs')->count();
            if ($pendingAfter === 0) {
                $this->info('Queue drained successfully.');
                return;
            }

            if ($pendingAfter >= $pendingBefore) {
                $stagnantRuns++;
                DB::table('jobs')->whereNotNull('reserved_at')->update(['reserved_at' => null]);
            } else {
                $stagnantRuns = 0;
            }

            if ($stagnantRuns >= 3) {
                $this->warn('Queue appears stagnant after multiple passes; stopping automatic drain.');
                return;
            }
        }

        $this->warn('Queue drain loop hit max iterations.');
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

    private function encodeJson(mixed $value): string
    {
        return json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '{}';
    }

    private function printSummary(): void
    {
        $this->newLine();
        $this->info('Import summary:');
        $this->line("- HTTP OK: {$this->requestOk}");
        $this->line("- HTTP failed: {$this->requestFail}");
        $this->line("- Snapshots written: {$this->snapshotWrites}");
        $this->line('- ana_muslim_items: ' . DB::table('ana_muslim_items')->count());
        $this->line('- ana_muslim_categories: ' . DB::table('ana_muslim_categories')->count());
        $this->line('- ana_muslim_authors: ' . DB::table('ana_muslim_authors')->count());
        $this->line('- quran_categories: ' . DB::table('islamhouse_quran_categories')->count());
        $this->line('- quran_authors: ' . DB::table('islamhouse_quran_authors')->count());
        $this->line('- quran_recitations: ' . DB::table('islamhouse_quran_recitations')->count());
        $this->line('- quran_suras: ' . DB::table('islamhouse_quran_suras')->count());
        $this->line('- language_terms: ' . DB::table('islamhouse_language_terms')->count());
        $this->line('- endpoint_snapshots: ' . DB::table('islamhouse_endpoint_snapshots')->count());
        $this->line('- jobs_pending: ' . DB::table('jobs')->count());
        $this->line('- jobs_failed: ' . DB::table('failed_jobs')->count());
    }
}
