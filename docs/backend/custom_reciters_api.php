<?php
declare(strict_types=1);

/**
 * Custom Reciters API
 *
 * Upload this file to your server, then set:
 * --dart-define=CUSTOM_RECITERS_API_URL=https://your-domain.com/custom_reciters_api.php
 *
 * Expected source JSON shape per reciter file:
 * [
 *   {"number": 1, "direct_link": "https://.../001.mp3"},
 *   ...
 * ]
 */

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, max-age=300');
header('Access-Control-Allow-Origin: *');

$config = [
    'cache_ttl_seconds' => 300,
    'cache_file' => __DIR__ . '/cache/custom_reciters.cache.json',
    'request_timeout_seconds' => 20,
    'reciters' => [
        [
            'id' => 990001,
            'name' => 'أحمد محمد طاهر',
            'letter' => 'أ',
            'moshaf_id' => 9900011,
            'moshaf_name' => 'حفص عن عاصم - إسلام ويب',
            // Local file on server OR full URL
            'source' => __DIR__ . '/data/ahmed_mohamed_taher_islamway_links.json',
        ],
        [
            'id' => 990003,
            'name' => 'محمد عثمان',
            'letter' => 'م',
            'moshaf_id' => 9900031,
            'moshaf_name' => 'حفص عن عاصم - تلاوات',
            // Local file on server OR full URL
            'source' => __DIR__ . '/data/mohamed_osman_links.json',
        ],
    ],
];

try {
    $forceRefresh = isset($_GET['refresh']) && $_GET['refresh'] === '1';
    if (!$forceRefresh) {
        $cached = readFreshCache($config['cache_file'], (int)$config['cache_ttl_seconds']);
        if ($cached !== null) {
            echo $cached;
            exit;
        }
    }

    $reciters = [];
    foreach ($config['reciters'] as $reciterSpec) {
        $reciter = buildReciterPayload($reciterSpec, (int)$config['request_timeout_seconds']);
        if ($reciter !== null) {
            $reciters[] = $reciter;
        }
    }

    $payload = [
        'status' => 'ok',
        'generated_at' => gmdate(DATE_ATOM),
        'count' => count($reciters),
        'reciters' => $reciters,
    ];

    $json = json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE
    );
    if ($json === false) {
        throw new RuntimeException('Failed to encode JSON response');
    }

    writeCache($config['cache_file'], $json);
    echo $json;
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(
        [
            'status' => 'error',
            'message' => 'Failed to build reciters payload',
            'error' => $e->getMessage(),
        ],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
}

function buildReciterPayload(array $spec, int $timeoutSeconds): ?array
{
    $rows = loadSourceRows((string)$spec['source'], $timeoutSeconds);
    if (empty($rows)) {
        return null;
    }

    $directSurahUrls = [];
    $serverPrefix = '';
    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $number = parseInt($row['number'] ?? null);
        if ($number < 1 || $number > 114) {
            continue;
        }

        $link = normalizeHttpMp3($row['direct_link'] ?? null);
        if ($link === null) {
            continue;
        }

        $directSurahUrls[(string)$number] = $link;
        if ($serverPrefix === '') {
            $serverPrefix = extractServerPrefix($link);
        }
    }

    if (empty($directSurahUrls)) {
        return null;
    }

    $surahNumbers = array_map('intval', array_keys($directSurahUrls));
    sort($surahNumbers, SORT_NUMERIC);

    return [
        'id' => parseInt($spec['id'] ?? null),
        'name' => (string)($spec['name'] ?? ''),
        'letter' => (string)($spec['letter'] ?? ''),
        'moshaf' => [
            [
                'id' => parseInt($spec['moshaf_id'] ?? null),
                'name' => (string)($spec['moshaf_name'] ?? ''),
                'server' => $serverPrefix,
                'surah_list' => implode(',', $surahNumbers),
                'surah_total' => count($surahNumbers),
                'direct_surah_urls' => $directSurahUrls,
            ],
        ],
    ];
}

function loadSourceRows(string $source, int $timeoutSeconds): array
{
    $raw = isHttpUrl($source)
        ? httpGetRaw($source, $timeoutSeconds)
        : fileGetRaw($source);

    if ($raw === null || trim($raw) === '') {
        return [];
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
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
            CURLOPT_USERAGENT => 'ImMuslim-CustomReciters/1.0',
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
            'header' => "User-Agent: ImMuslim-CustomReciters/1.0\r\n",
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
    if ($link === '') {
        return null;
    }

    if (!isHttpUrl($link)) {
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
    if (is_int($value)) {
        return $value;
    }
    if (is_float($value)) {
        return (int)$value;
    }
    if (is_string($value) && preg_match('/^-?\d+$/', trim($value))) {
        return (int)$value;
    }
    return 0;
}

function isHttpUrl(string $value): bool
{
    $url = filter_var($value, FILTER_VALIDATE_URL);
    if ($url === false) {
        return false;
    }
    $scheme = strtolower((string)parse_url($url, PHP_URL_SCHEME));
    return $scheme === 'http' || $scheme === 'https';
}

function readFreshCache(string $cacheFile, int $ttlSeconds): ?string
{
    if (!is_file($cacheFile)) {
        return null;
    }
    $modifiedAt = @filemtime($cacheFile);
    if (!is_int($modifiedAt)) {
        return null;
    }
    if ((time() - $modifiedAt) > $ttlSeconds) {
        return null;
    }
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
