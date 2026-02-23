<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;

class QuranRecitersApiController extends Controller
{
    public function index(): JsonResponse
    {
        $reciters = Cache::remember('ana_muslim_custom_reciters_v1', now()->addHours(12), function (): array {
            return array_values(array_filter([
                $this->buildReciterPayload(
                    reciterId: 910001,
                    name: 'محمد عثمان الحاج',
                    candidates: [
                        base_path('docs/backend/mohamed_osman_links.json'),
                        base_path('data/reciters/mohamed_osman_links.json'),
                        base_path('data/reciters/mohamed_osman.json'),
                    ],
                ),
                $this->buildReciterPayload(
                    reciterId: 910002,
                    name: 'أحمد طاهر',
                    candidates: [
                        base_path('docs/backend/ahmed_taher_islamway_links.json'),
                        base_path('data/reciters/ahmed_taher_islamway_links.json'),
                        base_path('data/reciters/ahmed_taher.json'),
                    ],
                ),
            ]));
        });

        return response()->json([
            'reciters' => $reciters,
            'data' => [
                'reciters' => $reciters,
            ],
        ]);
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
