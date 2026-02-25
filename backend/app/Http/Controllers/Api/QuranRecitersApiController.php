<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;
use App\Services\Mp3QuranService;

class QuranRecitersApiController extends Controller
{
    protected Mp3QuranService $mp3Quran;

    public function __construct(Mp3QuranService $mp3Quran)
    {
        $this->mp3Quran = $mp3Quran;
    }

    public function index(): JsonResponse
    {
        if (!\App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled')) {
            return response()->json(['reciters' => [], 'data' => ['reciters' => []]]);
        }

        $reciters = Cache::remember('ana_muslim_reciters_dynamic_v3', now()->addHours(24), function (): array {
            $uniqueList = []; // Keyed by ID
            $nameMap = []; // Keyed by normalized name, value is ID
            
            // Helper to normalize names for comparison (remove spaces, symbols, and standardize common Arabic characters)
            $normalize = function($name) {
                // Remove spaces and punctuation
                $name = preg_replace('/[^\p{L}\p{N}]/u', '', $name);
                // Standardize Arabic characters (Alif, Ta Marbuta, etc.)
                $name = str_replace(['أ', 'إ', 'آ'], 'ا', $name);
                $name = str_replace('ة', 'ه', $name);
                $name = str_replace('ى', 'ي', $name);
                return mb_strtolower($name);
            };

            // 1. Load Primary/Priority Reciters from Database (Sudanese & Overrides)
            $dbReciters = \App\Models\AnaMuslimReciter::where('is_active', true)
                ->orderBy('display_order')
                ->get();

            foreach ($dbReciters as $reciter) {
                if ($reciter->base_url === 'json://') {
                    $payload = $this->buildReciterPayload((int) $reciter->id, (string) $reciter->name, [
                        base_path('docs/backend/' . $reciter->path),
                        base_path('data/reciters/' . $reciter->path),
                    ]);
                } else {
                    $payload = $this->buildStaticReciterPayload([
                        'id' => (int) $reciter->id,
                        'name' => (string) $reciter->name,
                        'nationality' => (string) $reciter->nationality,
                        'path' => (string) $reciter->path,
                        'base' => (string) $reciter->base_url,
                    ]);
                }

                if ($payload) {
                    $payload['nationality'] = (string) $reciter->nationality;
                    $payload['priority'] = true;
                    $id = (int) $reciter->id;
                    $uniqueList[$id] = $payload;
                    $nameMap[$normalize($payload['name'])] = $id;
                }
            }
            
            // 2. Load from mp3quran.net API v3 via Service
            $apiData = $this->mp3Quran->getReciters();
            if (isset($apiData['reciters']) && is_array($apiData['reciters'])) {
                foreach ($apiData['reciters'] as $r) {
                    $id = (int) $r['id'];
                    $normName = $normalize($r['name']);

                    // Only add if not already in uniqueList AND not present in nameMap
                    if (!isset($uniqueList[$id]) && !isset($nameMap[$normName])) {
                        $uniqueList[$id] = [
                            'id' => $id,
                            'name' => (string) $r['name'],
                            'letter' => (string) $r['letter'],
                            'nationality' => '',
                            'priority' => false,
                            'moshaf' => $r['moshaf'] ?? [],
                        ];
                        $nameMap[$normName] = $id;
                    }
                }
            }

            // Convert to indexed array and return
            return array_values($uniqueList);
        });

        return response()->json([
            'reciters' => $reciters,
            'data' => [
                'reciters' => $reciters,
            ],
        ]);
    }

    private function buildStaticReciterPayload(array $data): array
    {
        $directUrls = [];
        for ($i = 1; $i <= 114; $i++) {
            $num = str_pad($i, 3, '0', STR_PAD_LEFT);
            $directUrls[(string) $i] = $data['base'] . $data['path'] . $num . ".mp3";
        }

        return [
            'id' => $data['id'],
            'name' => $data['name'],
            'nationality' => $data['nationality'] ?? '',
            'letter' => mb_substr($data['name'], 0, 1),
            'moshaf' => [
                [
                    'id' => $data['id'] * 10,
                    'name' => 'رواية حفص (مرتل)',
                    'server' => '',
                    'surah_list' => implode(',', range(1, 114)),
                    'surah_total' => 114,
                    'direct_surah_urls' => $directUrls,
                ],
            ],
        ];
    }

    /**
     * @return array<string, mixed>|null
     */
    private function buildReciterPayload(int $reciterId, string $name, array $candidates): ?array
    {
        $raw = $this->readJsonFromCandidates($candidates);
        if (!is_array($raw)) {
            return null;
        }

        $rows = array_values(array_filter($raw, static fn ($row): bool => is_array($row)));
        if ($rows === []) {
            return null;
        }

        $surahNumbers = [];
        $directUrls = [];

        foreach ($rows as $row) {
            $number = (int) ($row['number'] ?? $row['surah_number'] ?? 0);
            $url = trim((string) ($row['direct_link'] ?? $row['url'] ?? ''));
            if ($number < 1 || $number > 114 || $url === '') {
                continue;
            }

            $uri = parse_url($url);
            if ($uri === false || !isset($uri['scheme']) || !in_array($uri['scheme'], ['http', 'https'], true)) {
                continue;
            }

            $surahNumbers[$number] = $number;
            $directUrls[(string) $number] = $url;
        }

        if ($surahNumbers === []) {
            return null;
        }

        ksort($surahNumbers);
        ksort($directUrls, SORT_NATURAL);
        $surahList = implode(',', array_values($surahNumbers));

        return [
            'id' => $reciterId,
            'name' => $name,
            'letter' => mb_substr($name, 0, 1),
            'moshaf' => [
                [
                    'id' => ($reciterId * 10) + 1,
                    'name' => 'رواية حفص (روابط مباشرة)',
                    'server' => '',
                    'surah_list' => $surahList,
                    'surah_total' => count($surahNumbers),
                    'direct_surah_urls' => $directUrls,
                ],
            ],
        ];
    }

    private function readJsonFromCandidates(array $candidates): mixed
    {
        foreach ($candidates as $path) {
            if (!is_string($path) || $path === '' || !File::exists($path)) {
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
}
