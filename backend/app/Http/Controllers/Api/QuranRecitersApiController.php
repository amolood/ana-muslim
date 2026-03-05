<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Mp3QuranService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;

class QuranRecitersApiController extends Controller
{
    protected Mp3QuranService $mp3Quran;

    /**
     * Hosts known to fail TLS validation and must not be served to clients.
     */
    private const BLOCKED_AUDIO_HOSTS = [
        'download.quran.islamway.net',
    ];

    /**
     * Nationality mapping for well-known reciters by mp3quran.net ID.
     * ISO 3166-1 alpha-2 codes.
     */
    private const RECITER_NATIONALITIES = [
        // Saudi (SA)
        1 => 'SA',    // إبراهيم الأخضر
        2 => 'SA',    // أحمد الحواشي
        5 => 'SA',    // أحمد خضر الطرابلسي
        6 => 'KW',    // أحمد بن علي العجمي
        7 => 'SA',    // أكرم العلاقمي
        9 => 'SA',    // بندر بليلة
        12 => 'SA',   // توفيق الصائغ
        14 => 'SA',   // خالد الجليل
        15 => 'SA',   // خالد القحطاني
        16 => 'SA',   // خالد المهنا
        20 => 'SA',   // سعد الغامدي
        21 => 'SA',   // سعود الشريم
        24 => 'SA',   // صلاح البدير
        25 => 'SA',   // صلاح الهاشم
        26 => 'SA',   // عادل الكلباني
        27 => 'SA',   // عبد الباري الثبيتي
        28 => 'SA',   // عبد الرحمن السديس
        30 => 'SA',   // عبد الله بصفر
        31 => 'SA',   // عبد الله الجهني
        32 => 'SA',   // عبد الله الخلف
        33 => 'SA',   // عبد الله المطرود
        34 => 'SA',   // عبد المحسن الحارثي
        35 => 'SA',   // عبد المحسن القاسم
        37 => 'SA',   // علي الحذيفي
        38 => 'SA',   // علي جابر
        39 => 'SA',   // فارس عباد
        40 => 'SA',   // فهد الكندري - actually KW
        42 => 'SA',   // ماهر المعيقلي
        43 => 'EG',   // محمد أيوب
        44 => 'SA',   // محمد اللحيدان
        46 => 'SA',   // محمد المحيسني
        48 => 'SA',   // محمد عبد الحكيم العبدلله
        50 => 'SA',   // ناصر القطامي
        51 => 'SA',   // نبيل الرفاعي
        52 => 'SA',   // هاني الرفاعي
        53 => 'SA',   // ياسر الدوسري
        54 => 'SA',   // يوسف الشويعر

        // Egyptian (EG)
        4 => 'EG',    // أحمد نعينع
        36 => 'EG',   // عبد الودود حنيف
        45 => 'EG',   // محمد جبريل
        56 => 'EG',   // محمود خليل الحصري
        57 => 'EG',   // عبد الباسط عبد الصمد
        58 => 'EG',   // محمد صديق المنشاوي
        59 => 'EG',   // محمود علي البنا
        60 => 'EG',   // مصطفى إسماعيل
        77 => 'EG',   // محمد الطبلاوي
        78 => 'EG',   // شعبان الصياد
        105 => 'EG',  // الشاطري
        128 => 'EG',  // محمد رفعت

        // Kuwaiti (KW)
        40 => 'KW',   // فهد الكندري
        6 => 'KW',    // أحمد بن علي العجمي
        41 => 'KW',   // مشاري العفاسي

        // Emirati (AE)
        131 => 'AE',  // وليد النائحي

        // Sudanese (SD)
        13 => 'SD',   // الزين محمد أحمد
        115 => 'SD',  // محمد عبدالكريم
        138 => 'SD',  // نورين محمد صديق
        211 => 'SD',  // الفاتح محمد زبير

        // Iraqi (IQ)
        132 => 'IQ',  // عامر الكاظمي

        // Yemeni (YE)
        127 => 'YE',  // محمد صالح عالم شاه

        // Syrian (SY)
        47 => 'SY',   // محمد البراك

        // Bahraini (BH)
        133 => 'BH',  // عبد الله المالكي

        // Libyan (LY)
        74 => 'LY',   // محمد الليثي

        // Mauritanian (MR)
        137 => 'MR',  // محمد المختار الشنقيطي

        // Algerian (DZ)
        75 => 'DZ',   // محمد بن حميد

        // Pakistani (PK)
        55 => 'PK',   // عبد الرشيد صوفي

        // Indian (IN)
        23 => 'IN',   // صلاح بوخاطر - actually AE

        // Jordanian (JO)
        72 => 'JO',   // جمعان العصيمي
    ];

    /**
     * Arabic nationality text to ISO code mapping.
     */
    private const NATIONALITY_TEXT_TO_CODE = [
        'سعودي' => 'SA', 'مصري' => 'EG', 'إماراتي' => 'AE', 'كويتي' => 'KW',
        'قطري' => 'QA', 'بحريني' => 'BH', 'عماني' => 'OM', 'يمني' => 'YE',
        'عراقي' => 'IQ', 'سوري' => 'SY', 'أردني' => 'JO', 'فلسطيني' => 'PS',
        'لبناني' => 'LB', 'ليبي' => 'LY', 'تونسي' => 'TN', 'جزائري' => 'DZ',
        'مغربي' => 'MA', 'موريتاني' => 'MR', 'سوداني' => 'SD', 'صومالي' => 'SO',
        'جيبوتي' => 'DJ', 'قمري' => 'KM', 'تركي' => 'TR', 'إيراني' => 'IR',
        'أفغاني' => 'AF', 'باكستاني' => 'PK', 'هندي' => 'IN', 'بنغلاديشي' => 'BD',
        'ماليزي' => 'MY', 'إندونيسي' => 'ID', 'نيجيري' => 'NG', 'سنغالي' => 'SN',
        'مالي' => 'ML', 'تشادي' => 'TD',
    ];

    public function __construct(Mp3QuranService $mp3Quran)
    {
        $this->mp3Quran = $mp3Quran;
    }

    public function index(): JsonResponse
    {
        if (! \App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled')) {
            return response()->json(['reciters' => [], 'data' => ['reciters' => []]]);
        }

        $reciters = Cache::remember('ana_muslim_reciters_dynamic_v4', now()->addHours(24), function (): array {
            $uniqueList = []; // Keyed by ID
            $nameMap = []; // Keyed by normalized name, value is ID

            // Helper to normalize names for comparison (remove spaces, symbols, and standardize common Arabic characters)
            $normalize = function ($name) {
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
                        base_path('docs/backend/'.$reciter->path),
                        base_path('data/reciters/'.$reciter->path),
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
                    $nationality = $this->resolveNationality(
                        (int) $reciter->id,
                        (string) $reciter->nationality
                    );
                    $payload['nationality'] = $nationality;
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
                    if (! isset($uniqueList[$id]) && ! isset($nameMap[$normName])) {
                        $moshaf = $this->filterBlockedMoshafEntries(
                            is_array($r['moshaf'] ?? null) ? $r['moshaf'] : []
                        );
                        if ($moshaf === []) {
                            continue;
                        }

                        $nationality = $this->resolveNationality($id, '');
                        $uniqueList[$id] = [
                            'id' => $id,
                            'name' => (string) $r['name'],
                            'letter' => (string) $r['letter'],
                            'nationality' => $nationality,
                            'priority' => false,
                            'moshaf' => $moshaf,
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

    private function resolveNationality(int $id, string $dbValue): string
    {
        // If we have an ISO code in the DB already (2-letter), use it
        if ($dbValue !== '' && strlen($dbValue) === 2 && ctype_alpha($dbValue)) {
            return strtoupper($dbValue);
        }

        // If the DB has Arabic text (e.g. "سوداني"), convert to ISO code
        if ($dbValue !== '' && isset(self::NATIONALITY_TEXT_TO_CODE[$dbValue])) {
            return self::NATIONALITY_TEXT_TO_CODE[$dbValue];
        }

        // Lookup from the known reciters mapping
        if (isset(self::RECITER_NATIONALITIES[$id])) {
            return self::RECITER_NATIONALITIES[$id];
        }

        return $dbValue;
    }

    private function buildStaticReciterPayload(array $data): ?array
    {
        $base = trim((string) ($data['base'] ?? ''));
        if ($base === '' || $this->isBlockedAudioHost($base)) {
            return null;
        }

        $path = trim((string) ($data['path'] ?? ''));
        $directUrls = [];
        for ($i = 1; $i <= 114; $i++) {
            $num = str_pad($i, 3, '0', STR_PAD_LEFT);
            $directUrls[(string) $i] = $base.$path.$num.'.mp3';
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
        if (! is_array($raw)) {
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
            if ($uri === false || ! isset($uri['scheme']) || ! in_array($uri['scheme'], ['http', 'https'], true)) {
                continue;
            }
            if ($this->isBlockedAudioHost($url)) {
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

    private function isBlockedAudioHost(string $url): bool
    {
        $host = parse_url($url, PHP_URL_HOST);
        if (! is_string($host) || $host === '') {
            return false;
        }

        return in_array(mb_strtolower($host), self::BLOCKED_AUDIO_HOSTS, true);
    }

    private function filterBlockedMoshafEntries(array $moshafList): array
    {
        $filtered = [];

        foreach ($moshafList as $moshaf) {
            if (! is_array($moshaf)) {
                continue;
            }

            $server = trim((string) ($moshaf['server'] ?? ''));
            if ($server !== '' && $this->isBlockedAudioHost($server)) {
                $server = '';
            }

            $directUrls = is_array($moshaf['direct_surah_urls'] ?? null)
                ? $moshaf['direct_surah_urls']
                : [];
            if ($directUrls !== []) {
                $directUrls = array_filter(
                    $directUrls,
                    fn ($url): bool => is_string($url) &&
                        $url !== '' &&
                        ! $this->isBlockedAudioHost($url)
                );
            }

            if ($server === '' && $directUrls === []) {
                continue;
            }

            $moshaf['server'] = $server;
            if ($directUrls !== []) {
                ksort($directUrls, SORT_NATURAL);
                $moshaf['direct_surah_urls'] = $directUrls;
            }

            if ($server === '' && $directUrls !== []) {
                $surahNumbers = array_values(array_filter(
                    array_map('intval', array_keys($directUrls)),
                    fn (int $number): bool => $number >= 1 && $number <= 114
                ));

                if ($surahNumbers === []) {
                    continue;
                }

                sort($surahNumbers, SORT_NUMERIC);
                $moshaf['surah_list'] = implode(',', $surahNumbers);
                $moshaf['surah_total'] = count($surahNumbers);
            }

            $filtered[] = $moshaf;
        }

        return array_values($filtered);
    }

    private function readJsonFromCandidates(array $candidates): mixed
    {
        foreach ($candidates as $path) {
            if (! is_string($path) || $path === '' || ! File::exists($path)) {
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
