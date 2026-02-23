<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimHadith;
use App\Models\AnaMuslimHadithBook;
use App\Models\AnaMuslimHadithChapter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HadithApiController extends Controller
{
    /**
     * Legacy endpoint compatible with the Flutter HadithRepository.
     */
    public function legacy(Request $request): JsonResponse
    {
        $action = trim(strtolower((string) $request->query('action', '')));
        $collectionSlug = $this->normalizeCollectionSlug((string) $request->query('collection', ''));

        if (!in_array($action, ['hadith_books', 'hadith_book', 'hadith_all', 'hadith_search'], true)) {
            return response()->json(['error' => 'Unsupported action'], 422);
        }

        if ($collectionSlug === '') {
            return response()->json(['error' => 'Collection is required'], 422);
        }

        $book = $this->findCollection($collectionSlug);
        if (!$book) {
            return response()->json([
                $action === 'hadith_books' ? 'books' : 'hadiths' => [],
            ]);
        }

        if ($action === 'hadith_books') {
            $books = $this->buildBooksPayload($book);

            return response()->json(['books' => $books]);
        }

        if ($action === 'hadith_book') {
            $bookNumber = trim((string) $request->query('book', ''));
            $offset = max(0, (int) $request->query('offset', 0));
            $limit = $request->query->has('limit')
                ? min(200, max(1, (int) $request->query('limit', 60)))
                : null;
            $payload = $this->buildSingleBookPayload($book, $bookNumber, $offset, $limit);

            return response()->json($payload);
        }

        if ($action === 'hadith_search') {
            $query = trim((string) $request->query('q', ''));
            $limit = min(120, max(1, (int) $request->query('limit', 60)));
            $hadiths = $this->buildSearchPayload($book, $query, $limit);

            return response()->json(['hadiths' => $hadiths]);
        }

        $limit = min(1000, max(1, (int) $request->query('limit', 500)));
        $hadiths = $this->buildAllHadithPayload($book, $limit);

        return response()->json(['hadiths' => $hadiths]);
    }

    /**
     * REST-style endpoint: list available collections.
     */
    public function collections(): JsonResponse
    {
        $collections = AnaMuslimHadithBook::query()
            ->select(['slug', 'title_ar', 'title_en', 'total_chapters', 'total_hadith'])
            ->orderBy('source_book_id')
            ->orderBy('slug')
            ->get()
            ->map(fn (AnaMuslimHadithBook $book): array => [
                'slug' => $book->slug,
                'title_ar' => $book->title_ar,
                'title_en' => $book->title_en,
                'total_chapters' => (int) $book->total_chapters,
                'total_hadith' => (int) $book->total_hadith,
            ])
            ->values()
            ->all();

        return response()->json(['collections' => $collections]);
    }

    /**
     * REST-style endpoint: list chapters-as-books for one collection.
     */
    public function books(string $collection): JsonResponse
    {
        $book = $this->findCollection($this->normalizeCollectionSlug($collection));
        if (!$book) {
            return response()->json(['error' => 'Collection not found'], 404);
        }

        $books = $this->buildBooksPayload($book);

        return response()->json(['books' => $books]);
    }

    /**
     * REST-style endpoint: list hadiths for one chapter inside collection.
     */
    public function book(Request $request, string $collection, string $bookNumber): JsonResponse
    {
        $book = $this->findCollection($this->normalizeCollectionSlug($collection));
        if (!$book) {
            return response()->json(['error' => 'Collection not found'], 404);
        }

        $offset = max(0, (int) $request->query('offset', 0));
        $limit = $request->query->has('limit')
            ? min(200, max(1, (int) $request->query('limit', 60)))
            : null;
        $payload = $this->buildSingleBookPayload($book, $bookNumber, $offset, $limit);

        return response()->json($payload);
    }

    /**
     * REST-style endpoint: list all hadiths for one collection.
     */
    public function all(Request $request, string $collection): JsonResponse
    {
        $book = $this->findCollection($this->normalizeCollectionSlug($collection));
        if (!$book) {
            return response()->json(['error' => 'Collection not found'], 404);
        }

        $limit = min(1000, max(1, (int) $request->query('limit', 500)));
        $hadiths = $this->buildAllHadithPayload($book, $limit);

        return response()->json(['hadiths' => $hadiths]);
    }

    /**
     * REST-style endpoint: search in one collection.
     */
    public function search(Request $request, string $collection): JsonResponse
    {
        $book = $this->findCollection($this->normalizeCollectionSlug($collection));
        if (!$book) {
            return response()->json(['error' => 'Collection not found'], 404);
        }

        $query = trim((string) $request->query('q', ''));
        $limit = min(120, max(1, (int) $request->query('limit', 60)));
        $hadiths = $this->buildSearchPayload($book, $query, $limit);

        return response()->json(['hadiths' => $hadiths]);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function buildBooksPayload(AnaMuslimHadithBook $collectionBook): array
    {
        $chapters = AnaMuslimHadithChapter::query()
            ->where('hadith_book_id', $collectionBook->id)
            ->orderBy('chapter_order')
            ->get();

        if ($chapters->isEmpty()) {
            return [];
        }

        $stats = AnaMuslimHadith::query()
            ->select('hadith_chapter_id')
            ->selectRaw('COUNT(*) as total')
            ->selectRaw('MIN(CAST(hadith_number AS UNSIGNED)) as min_hadith_number')
            ->selectRaw('MAX(CAST(hadith_number AS UNSIGNED)) as max_hadith_number')
            ->where('hadith_book_id', $collectionBook->id)
            ->groupBy('hadith_chapter_id')
            ->get()
            ->keyBy('hadith_chapter_id');

        return $chapters
            ->map(function (AnaMuslimHadithChapter $chapter) use ($stats): array {
                $chapterStats = $stats->get($chapter->id);
                $start = (int) ($chapterStats->min_hadith_number ?? 0);
                $end = (int) ($chapterStats->max_hadith_number ?? 0);
                $count = (int) ($chapterStats->total ?? 0);

                return [
                    'bookNumber' => (string) $chapter->source_chapter_id,
                    'book' => [
                        [
                            'lang' => 'ar',
                            'name' => trim((string) ($chapter->title_ar ?? '')) ?: 'باب',
                        ],
                        [
                            'lang' => 'en',
                            'name' => trim((string) ($chapter->title_en ?? '')) ?: (trim((string) ($chapter->title_ar ?? '')) ?: 'Chapter'),
                        ],
                    ],
                    'hadithStartNumber' => $start,
                    'hadithEndNumber' => $end,
                    'numberOfHadith' => $count,
                ];
            })
            ->values()
            ->all();
    }

    /**
     * @return array{hadiths: array<int, array<string, mixed>>, pagination: array<string, int|bool>}
     */
    private function buildSingleBookPayload(
        AnaMuslimHadithBook $collectionBook,
        string $bookNumber,
        int $offset = 0,
        ?int $limit = null
    ): array
    {
        $normalizedBookNumber = trim($bookNumber);
        if ($normalizedBookNumber === '') {
            return [
                'hadiths' => [],
                'pagination' => [
                    'offset' => $offset,
                    'limit' => $limit ?? 0,
                    'returned' => 0,
                    'hasMore' => false,
                    'total' => 0,
                ],
            ];
        }

        $chapter = AnaMuslimHadithChapter::query()
            ->where('hadith_book_id', $collectionBook->id)
            ->where('source_chapter_id', (int) $normalizedBookNumber)
            ->first();

        if (!$chapter) {
            return [
                'hadiths' => [],
                'pagination' => [
                    'offset' => $offset,
                    'limit' => $limit ?? 0,
                    'returned' => 0,
                    'hasMore' => false,
                    'total' => 0,
                ],
            ];
        }

        $query = AnaMuslimHadith::query()
            ->with(['chapter:id,source_chapter_id,title_ar,title_en'])
            ->where('hadith_book_id', $collectionBook->id)
            ->where('hadith_chapter_id', $chapter->id)
            ->orderByRaw('CAST(hadith_number AS UNSIGNED) ASC')
            ->orderBy('id');

        $total = (clone $query)->count();

        if ($offset > 0) {
            $query->skip($offset);
        }
        if ($limit !== null) {
            $query->take($limit);
        }

        $hadithRows = $query->get();

        $hadiths = $hadithRows
            ->map(fn (AnaMuslimHadith $hadith): array => $this->transformHadith($collectionBook, $hadith, $chapter))
            ->values()
            ->all();

        $returned = count($hadiths);
        $hasMore = ($offset + $returned) < $total;

        return [
            'hadiths' => $hadiths,
            'pagination' => [
                'offset' => $offset,
                'limit' => $limit ?? $returned,
                'returned' => $returned,
                'hasMore' => $hasMore,
                'total' => $total,
            ],
        ];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function buildAllHadithPayload(AnaMuslimHadithBook $collectionBook, int $limit = 500): array
    {
        $hadithRows = AnaMuslimHadith::query()
            ->with(['chapter:id,source_chapter_id,title_ar,title_en'])
            ->where('hadith_book_id', $collectionBook->id)
            ->orderByRaw('CAST(hadith_number AS UNSIGNED) ASC')
            ->orderBy('id')
            ->limit($limit)
            ->get();

        return $hadithRows
            ->map(fn (AnaMuslimHadith $hadith): array => $this->transformHadith($collectionBook, $hadith))
            ->values()
            ->all();
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function buildSearchPayload(AnaMuslimHadithBook $collectionBook, string $query, int $limit): array
    {
        $trimmed = trim($query);
        if ($trimmed === '') {
            return [];
        }
        $normalizedArabicQuery = $this->stripArabicDiacritics($trimmed);
        $normalizedArabicSql = $this->normalizedArabicSql('arabic_text');

        $rows = AnaMuslimHadith::query()
            ->with(['chapter:id,source_chapter_id,title_ar,title_en'])
            ->where('hadith_book_id', $collectionBook->id)
            ->when(preg_match('/^\\d+$/', $trimmed) === 1, function ($builder) use ($trimmed): void {
                $builder->where('hadith_number', $trimmed);
            }, function ($builder) use ($trimmed, $normalizedArabicQuery, $normalizedArabicSql): void {
                $builder->where(function ($nested) use ($trimmed, $normalizedArabicQuery, $normalizedArabicSql): void {
                    $nested->where('arabic_text', 'like', '%'.$trimmed.'%')
                        ->orWhere('english_narrator', 'like', '%'.$trimmed.'%')
                        ->orWhere('english_text', 'like', '%'.$trimmed.'%');
                    if ($normalizedArabicQuery !== '') {
                        $nested->orWhereRaw("{$normalizedArabicSql} LIKE ?", ['%'.$normalizedArabicQuery.'%']);
                    }
                });
            })
            ->orderByRaw('CAST(hadith_number AS UNSIGNED) ASC')
            ->orderBy('id')
            ->limit($limit)
            ->get();

        return $rows
            ->map(fn (AnaMuslimHadith $hadith): array => $this->transformHadith($collectionBook, $hadith))
            ->values()
            ->all();
    }

    /**
     * @return array<string, mixed>
     */
    private function transformHadith(
        AnaMuslimHadithBook $collectionBook,
        AnaMuslimHadith $hadith,
        ?AnaMuslimHadithChapter $forcedChapter = null
    ): array {
        $chapter = $forcedChapter ?? $hadith->chapter;
        $chapterNumber = (string) ($chapter?->source_chapter_id ?? $hadith->chapter_number ?? '');
        $chapterTitleAr = trim((string) ($chapter?->title_ar ?? '')) ?: 'باب';
        $chapterTitleEn = trim((string) ($chapter?->title_en ?? '')) ?: 'Chapter';
        $urn = (int) ($hadith->source_hadith_id ?: $hadith->id);

        $details = [];

        $arabicBody = trim((string) ($hadith->arabic_text ?? ''));
        if ($arabicBody !== '') {
            $details[] = [
                'lang' => 'ar',
                'chapterNumber' => $chapterNumber,
                'chapterTitle' => $chapterTitleAr,
                'urn' => $urn,
                'body' => $arabicBody,
                'grades' => [],
            ];
        }

        $englishBody = trim(implode(' ', array_filter([
            trim((string) ($hadith->english_narrator ?? '')),
            trim((string) ($hadith->english_text ?? '')),
        ])));
        if ($englishBody !== '') {
            $details[] = [
                'lang' => 'en',
                'chapterNumber' => $chapterNumber,
                'chapterTitle' => $chapterTitleEn,
                'urn' => $urn,
                'body' => $englishBody,
                'grades' => [],
            ];
        }

        if ($details === []) {
            $details[] = [
                'lang' => 'ar',
                'chapterNumber' => $chapterNumber,
                'chapterTitle' => $chapterTitleAr,
                'urn' => $urn,
                'body' => '',
                'grades' => [],
            ];
        }

        return [
            'collection' => $collectionBook->slug,
            'bookNumber' => $chapterNumber,
            'chapterId' => $chapterNumber,
            'hadithNumber' => (string) $hadith->hadith_number,
            'hadith' => $details,
        ];
    }

    private function findCollection(string $slug): ?AnaMuslimHadithBook
    {
        if ($slug === '') {
            return null;
        }

        return AnaMuslimHadithBook::query()
            ->where('slug', $slug)
            ->first();
    }

    private function normalizeCollectionSlug(string $collection): string
    {
        $slug = trim(strtolower($collection));
        if ($slug === '') {
            return '';
        }

        $aliases = [
            'abu_dawud' => 'abudawud',
            'abu-dawud' => 'abudawud',
            'ibn_majah' => 'ibnmajah',
            'ibn-majah' => 'ibnmajah',
            'nawawi_40' => 'nawawi40',
            'nawawi-40' => 'nawawi40',
        ];

        return $aliases[$slug] ?? $slug;
    }

    private function stripArabicDiacritics(string $input): string
    {
        $normalized = (string) preg_replace('/[\x{064B}-\x{065F}\x{0670}]/u', '', $input);

        return str_replace(
            ['أ', 'إ', 'آ', 'ٱ', 'ى', 'ة'],
            ['ا', 'ا', 'ا', 'ا', 'ي', 'ه'],
            $normalized
        );
    }

    private function normalizedArabicSql(string $column): string
    {
        $expression = "COALESCE({$column}, '')";
        $diacritics = ['ً', 'ٌ', 'ٍ', 'َ', 'ُ', 'ِ', 'ّ', 'ْ', 'ٰ', 'ٓ', 'ٔ', 'ٕ', 'ٖ', 'ٗ', '٘', 'ٙ', 'ٚ', 'ٛ', 'ٜ', 'ٝ', 'ٞ', 'ٟ'];
        foreach ($diacritics as $char) {
            $expression = "REPLACE({$expression}, '{$char}', '')";
        }
        $normalizationMap = [
            'أ' => 'ا',
            'إ' => 'ا',
            'آ' => 'ا',
            'ٱ' => 'ا',
            'ى' => 'ي',
            'ة' => 'ه',
        ];
        foreach ($normalizationMap as $from => $to) {
            $expression = "REPLACE({$expression}, '{$from}', '{$to}')";
        }

        return $expression;
    }
}
