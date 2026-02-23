<?php
declare(strict_types=1);



header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, max-age=604800'); // Cache for 1 week
header('Access-Control-Allow-Origin: *');

$config = [
    'cache_ttl_seconds' => 604800, // 1 week
    'cache_dir' => __DIR__ . '/cache',
    'request_timeout_seconds' => 20,

    // Azkar source can be:
    // 1) old format: {"rows":[[category,zekr,description,count,reference,search],...]}
    // 2) new format: {"items":[{category,zekr,description,count,reference,search},...]}
    'azkar_source' => __DIR__ . '/data/azkar.json',

    // Asma Allah source format:
    // [{"id":1,"name":"الله","meaning":"..."}, ...]
    'asma_source' => __DIR__ . '/data/asma_allah.json',

    // Hadith files: same shape as hadith package dataset.
    'hadith' => [
        'bukhari' => [
            'books' => __DIR__ . '/data/hadith/bukhari/books.json',
            'hadiths' => __DIR__ . '/data/hadith/bukhari/hadiths.json',
        ],
        'muslim' => [
            'books' => __DIR__ . '/data/hadith/muslim/books.json',
            'hadiths' => __DIR__ . '/data/hadith/muslim/hadiths.json',
        ],
    ],

    // Custom reciters list:
    // source format is list rows containing at least number + direct_link.
    'reciters' => [
        [
            'id' => 990001,
            'name' => 'أحمد محمد طاهر',
            'letter' => 'أ',
            'moshaf_id' => 9900011,
            'moshaf_name' => 'حفص عن عاصم - إسلام ويب',
            'source' => __DIR__ . '/data/reciters/ahmed_mohamed_taher_islamway_links.json',
        ],
        [
            'id' => 990003,
            'name' => 'محمد عثمان',
            'letter' => 'م',
            'moshaf_id' => 9900031,
            'moshaf_name' => 'حفص عن عاصم - تلاوات',
            'source' => __DIR__ . '/data/reciters/mohamed_osman_links.json',
        ],
    ],
];

try {
    $action = isset($_GET['action']) ? trim((string)$_GET['action']) : 'azkar';
    $collection = isset($_GET['collection']) ? strtolower(trim((string)$_GET['collection'])) : '';
    $book = isset($_GET['book']) ? trim((string)$_GET['book']) : '';
    $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : null;
    $limit = isset($_GET['limit']) ? max(1, (int)$_GET['limit']) : null;
    $refresh = isset($_GET['refresh']) && $_GET['refresh'] === '1';

    $cacheKey = buildCacheKey($action, $collection, $book, $page, $limit);
    $cacheFile = rtrim($config['cache_dir'], '/\\') . DIRECTORY_SEPARATOR . $cacheKey . '.json';

    if (!$refresh) {
        $cached = readFreshCache($cacheFile, (int)$config['cache_ttl_seconds']);
        if ($cached !== null) {
            echo $cached;
            exit;
        }
    }

    $response = match ($action) {
        'reciters' => handleReciters($config),
        'azkar' => handleAzkar($config),
        'asma' => handleAsma($config),
        'hadith_books' => handleHadithBooks($config, $collection),
        'hadith_book' => handleHadithBook($config, $collection, $book),
        'hadith_all' => handleHadithAll($config, $collection),
        default => [
            'status' => 'error',
            'message' => 'Unknown action',
            'action' => $action,
        ],
    };

    if ($page !== null && $limit !== null && $limit > 0 && ($response['status'] ?? '') === 'ok') {
        $offset = ($page - 1) * $limit;
        $slicedAny = false;
        
        // Target lists that could be paginated
        $paginableKeys = ['items', 'hadiths', 'asma_allah'];
        foreach ($paginableKeys as $key) {
            if (isset($response['data'][$key]) && is_array($response['data'][$key]) && array_is_list($response['data'][$key])) {
                $sliced = array_slice($response['data'][$key], $offset, $limit);
                $response['data'][$key] = $sliced;
                if (isset($response[$key]) && is_array($response[$key])) {
                    $response[$key] = $sliced;
                }
                $slicedAny = true;
            }
        }
        
        if ($slicedAny) {
            $response['page'] = $page;
            $response['limit'] = $limit;
        }
    }

    if (($response['status'] ?? '') !== 'ok') {
        http_response_code(400);
    }

    $json = json_encode(
        $response,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE
    );
    if ($json === false) {
        throw new RuntimeException('Failed to encode response');
    }

    if (($response['status'] ?? '') === 'ok') {
        writeCache($cacheFile, $json);
    }
    echo $json;
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(
        [
            'status' => 'error',
            'message' => 'Server error',
            'error' => $e->getMessage(),
        ],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
}

function handleReciters(array $config): array
{
    $rows = [];
    foreach ($config['reciters'] as $spec) {
        $item = buildReciter($spec, (int)$config['request_timeout_seconds']);
        if ($item !== null) {
            $rows[] = $item;
        }
    }

    return [
        'status' => 'ok',
        'count' => count($rows),
        'reciters' => $rows,
        'data' => ['reciters' => $rows],
    ];
}

function buildReciter(array $spec, int $timeoutSeconds): ?array
{
    $sourceRows = readJsonSource((string)$spec['source'], $timeoutSeconds);
    if (!is_array($sourceRows)) {
        return null;
    }

    if (array_key_exists('rows', $sourceRows) && is_array($sourceRows['rows'])) {
        $sourceRows = $sourceRows['rows'];
    } elseif (array_key_exists('items', $sourceRows) && is_array($sourceRows['items'])) {
        $sourceRows = $sourceRows['items'];
    }

    $surahUrls = [];
    $serverPrefix = '';
    foreach ($sourceRows as $row) {
        $number = 0;
        $link = null;

        if (is_array($row)) {
            if (array_is_list($row)) {
                $number = parseInt($row[0] ?? null);
                $link = normalizeHttpMp3($row[3] ?? null);
            } else {
                $number = parseInt($row['number'] ?? null);
                $link = normalizeHttpMp3($row['direct_link'] ?? null);
            }
        }

        if ($number < 1 || $number > 114 || $link === null) {
            continue;
        }
        $surahUrls[(string)$number] = $link;
        if ($serverPrefix === '') {
            $serverPrefix = extractServerPrefix($link);
        }
    }

    if (empty($surahUrls)) {
        return null;
    }

    $surahNumbers = array_map('intval', array_keys($surahUrls));
    sort($surahNumbers, SORT_NUMERIC);

    return [
        'id' => parseInt($spec['id'] ?? null),
        'name' => (string)($spec['name'] ?? ''),
        'letter' => (string)($spec['letter'] ?? ''),
        'moshaf' => [[
            'id' => parseInt($spec['moshaf_id'] ?? null),
            'name' => (string)($spec['moshaf_name'] ?? ''),
            'server' => $serverPrefix,
            'surah_list' => implode(',', $surahNumbers),
            'surah_total' => count($surahNumbers),
            'direct_surah_urls' => $surahUrls,
        ]],
    ];
}

function handleAzkar(array $config): array
{
    $azkarRaw = readJsonSource((string)$config['azkar_source'], (int)$config['request_timeout_seconds']);
    $items = parseAzkarItems($azkarRaw);
    $categories = buildAzkarCategories($items);
    $asma = parseAsmaEntries(readJsonSource((string)$config['asma_source'], (int)$config['request_timeout_seconds']));

    return [
        'status' => 'ok',
        'data' => [
            'items' => $items,
            'categories' => $categories,
            'asma_allah' => $asma,
        ],
    ];
}

function handleAsma(array $config): array
{
    $asma = parseAsmaEntries(readJsonSource((string)$config['asma_source'], (int)$config['request_timeout_seconds']));
    return [
        'status' => 'ok',
        'data' => $asma,
        'asma_allah' => $asma,
    ];
}

function handleHadithBooks(array $config, string $collection): array
{
    if (!isset($config['hadith'][$collection])) {
        return ['status' => 'error', 'message' => 'Invalid collection'];
    }
    $books = readJsonSource((string)$config['hadith'][$collection]['books'], (int)$config['request_timeout_seconds']);
    if (!is_array($books)) {
        $books = [];
    }
    return [
        'status' => 'ok',
        'collection' => $collection,
        'books' => $books,
        'data' => ['books' => $books],
    ];
}

function handleHadithBook(array $config, string $collection, string $book): array
{
    if (!isset($config['hadith'][$collection])) {
        return ['status' => 'error', 'message' => 'Invalid collection'];
    }
    if ($book === '') {
        return ['status' => 'error', 'message' => 'Missing book parameter'];
    }

    $all = readJsonSource((string)$config['hadith'][$collection]['hadiths'], (int)$config['request_timeout_seconds']);
    if (!is_array($all)) {
        $all = [];
    }
    $hadiths = [];
    if (isset($all[$book]) && is_array($all[$book])) {
        $hadiths = $all[$book];
    }

    return [
        'status' => 'ok',
        'collection' => $collection,
        'book' => $book,
        'hadiths' => $hadiths,
        'data' => ['hadiths' => $hadiths],
    ];
}

function handleHadithAll(array $config, string $collection): array
{
    if (!isset($config['hadith'][$collection])) {
        return ['status' => 'error', 'message' => 'Invalid collection'];
    }

    $all = readJsonSource((string)$config['hadith'][$collection]['hadiths'], (int)$config['request_timeout_seconds']);
    if (!is_array($all)) {
        $all = [];
    }

    $rows = [];
    foreach ($all as $bookList) {
        if (!is_array($bookList)) {
            continue;
        }
        foreach ($bookList as $hadith) {
            if (is_array($hadith)) {
                $rows[] = $hadith;
            }
        }
    }

    return [
        'status' => 'ok',
        'collection' => $collection,
        'hadiths' => $rows,
        'data' => ['hadiths' => $rows],
    ];
}

function parseAzkarItems($raw): array
{
    if (!is_array($raw)) {
        return [];
    }

    $rows = [];
    if (array_key_exists('rows', $raw) && is_array($raw['rows'])) {
        $rows = $raw['rows'];
    } elseif (array_key_exists('items', $raw) && is_array($raw['items'])) {
        $rows = $raw['items'];
    } elseif (array_is_list($raw)) {
        $rows = $raw;
    }

    $items = [];
    $id = 1;
    foreach ($rows as $row) {
        if (is_array($row) && array_is_list($row)) {
            if (count($row) < 2) {
                continue;
            }
            $category = trim((string)($row[0] ?? ''));
            $zekr = trim((string)($row[1] ?? ''));
            if ($category === '' || $zekr === '') {
                continue;
            }
            $items[] = [
                'id' => $id++,
                'category' => $category,
                'zekr' => $zekr,
                'description' => (string)($row[2] ?? ''),
                'count' => max(1, parseInt($row[3] ?? 1)),
                'reference' => (string)($row[4] ?? ''),
                'search' => (string)($row[5] ?? ''),
            ];
            continue;
        }

        if (is_array($row)) {
            $category = trim((string)($row['category'] ?? ''));
            $zekr = trim((string)($row['zekr'] ?? $row['text'] ?? ''));
            if ($category === '' || $zekr === '') {
                continue;
            }
            $items[] = [
                'id' => parseInt($row['id'] ?? $id),
                'category' => $category,
                'zekr' => $zekr,
                'description' => (string)($row['description'] ?? ''),
                'count' => max(1, parseInt($row['count'] ?? 1)),
                'reference' => (string)($row['reference'] ?? ''),
                'search' => (string)($row['search'] ?? ''),
            ];
            $id++;
        }
    }
    return $items;
}

function buildAzkarCategories(array $items): array
{
    $seen = [];
    $categories = [];
    $id = 1;
    foreach ($items as $item) {
        if (!is_array($item)) {
            continue;
        }
        $name = trim((string)($item['category'] ?? ''));
        if ($name === '' || isset($seen[$name])) {
            continue;
        }
        $seen[$name] = true;
        $categories[] = ['id' => $id++, 'name' => $name];
    }
    return $categories;
}

function parseAsmaEntries($raw): array
{
    $rows = [];
    if (is_array($raw) && array_is_list($raw)) {
        $rows = $raw;
    } elseif (is_array($raw) && isset($raw['data']) && is_array($raw['data'])) {
        $rows = $raw['data'];
    } elseif (is_array($raw) && isset($raw['asma_allah']) && is_array($raw['asma_allah'])) {
        $rows = $raw['asma_allah'];
    }

    $result = [];
    $id = 1;
    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }
        $name = trim((string)($row['name'] ?? ''));
        if ($name === '') {
            continue;
        }
        $result[] = [
            'id' => parseInt($row['id'] ?? $id),
            'name' => $name,
            'meaning' => (string)($row['meaning'] ?? $row['description'] ?? ''),
        ];
        $id++;
    }
    return $result;
}

function readJsonSource(string $source, int $timeoutSeconds)
{
    $raw = isHttpUrl($source)
        ? httpGetRaw($source, $timeoutSeconds)
        : fileGetRaw($source);

    if ($raw === null || trim($raw) === '') {
        return [];
    }

    $decoded = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        return [];
    }
    return $decoded;
}

function httpGetRaw(string $url, int $timeoutSeconds): ?string
{
    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => $timeoutSeconds,
            CURLOPT_TIMEOUT => $timeoutSeconds,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_MAXREDIRS => 3,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_USERAGENT => 'ImMuslim-RemoteAPI/1.0',
        ]);
        $result = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if (!is_string($result) || $status >= 400) {
            return null;
        }
        return $result;
    }

    $ctx = stream_context_create([
        'http' => [
            'method' => 'GET',
            'timeout' => $timeoutSeconds,
            'header' => "User-Agent: ImMuslim-RemoteAPI/1.0\r\n",
        ],
    ]);
    $raw = @file_get_contents($url, false, $ctx);
    return is_string($raw) ? $raw : null;
}

function fileGetRaw(string $path): ?string
{
    if (!is_file($path) || !is_readable($path)) {
        return null;
    }
    $raw = @file_get_contents($path);
    return is_string($raw) ? $raw : null;
}

function normalizeHttpMp3($value): ?string
{
    $link = trim((string)$value);
    if ($link === '' || !isHttpUrl($link)) {
        return null;
    }
    $path = parse_url($link, PHP_URL_PATH);
    if (!is_string($path) || !str_ends_with(strtolower($path), '.mp3')) {
        return null;
    }
    return $link;
}

function extractServerPrefix(string $link): string
{
    $lastSlash = strrpos($link, '/');
    if ($lastSlash === false) {
        return '';
    }
    return substr($link, 0, $lastSlash + 1);
}

function parseInt($value): int
{
    if (is_int($value)) return $value;
    if (is_float($value)) return (int)$value;
    if (is_string($value) && preg_match('/^-?\d+$/', trim($value))) {
        return (int)$value;
    }
    return 0;
}

function isHttpUrl(string $value): bool
{
    $url = filter_var($value, FILTER_VALIDATE_URL);
    if ($url === false) return false;
    $scheme = strtolower((string)parse_url($url, PHP_URL_SCHEME));
    return $scheme === 'http' || $scheme === 'https';
}

function buildCacheKey(string $action, string $collection, string $book, ?int $page, ?int $limit): string
{
    $parts = [$action];
    if ($collection !== '') $parts[] = $collection;
    if ($book !== '') $parts[] = $book;
    if ($page !== null) $parts[] = 'p' . $page;
    if ($limit !== null) $parts[] = 'l' . $limit;
    return preg_replace('/[^a-zA-Z0-9_-]+/', '_', implode('_', $parts));
}

function readFreshCache(string $cacheFile, int $ttlSeconds): ?string
{
    if (!is_file($cacheFile)) return null;
    $modifiedAt = @filemtime($cacheFile);
    if (!is_int($modifiedAt)) return null;
    if ((time() - $modifiedAt) > $ttlSeconds) return null;
    $raw = @file_get_contents($cacheFile);
    return is_string($raw) ? $raw : null;
}

function writeCache(string $cacheFile, string $json): void
{
    $dir = dirname($cacheFile);
    if (!is_dir($dir)) {
        @mkdir($dir, 0775, true);
    }
    @file_put_contents($cacheFile, $json, LOCK_EX);
}
