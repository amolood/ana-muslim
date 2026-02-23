<?php

namespace App\Console\Commands;

use App\Models\AnaMuslimHadith;
use App\Models\AnaMuslimHadithBook;
use App\Models\AnaMuslimHadithChapter;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Str;

class ImportHadithLibrary extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'hadith:import
                            {--path= : Absolute path to hadith-json db directory}
                            {--collections= : Comma separated slugs to import (e.g. bukhari,muslim)}
                            {--truncate : Truncate hadith tables before importing}
                            {--chunk=100 : Insert batch size}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import hadith collections from hadith-json into local database';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $dbPath = $this->resolveDatasetPath();
        $byBookPath = $dbPath.DIRECTORY_SEPARATOR.'by_book';
        $chunkSize = max(20, (int) $this->option('chunk'));
        $filter = $this->parseCollectionsFilter();

        if (!is_dir($dbPath) || !is_dir($byBookPath)) {
            $this->error("Invalid dataset path: {$dbPath}");
            $this->line('Expected a `by_book` folder inside the provided path.');

            return self::FAILURE;
        }

        if ($this->option('truncate')) {
            $this->warn('Truncating hadith tables...');
            DB::statement('SET FOREIGN_KEY_CHECKS=0');
            DB::table('ana_muslim_hadiths')->truncate();
            DB::table('ana_muslim_hadith_chapters')->truncate();
            DB::table('ana_muslim_hadith_books')->truncate();
            DB::statement('SET FOREIGN_KEY_CHECKS=1');
        }

        $files = collect(File::allFiles($byBookPath))
            ->filter(fn ($file): bool => strtolower((string) $file->getExtension()) === 'json')
            ->sortBy(fn ($file): string => (string) $file->getPathname())
            ->values();

        if ($files->isEmpty()) {
            $this->warn('No JSON files found under by_book.');

            return self::SUCCESS;
        }

        $this->info('Found '.$files->count().' files. Importing...');
        $bar = $this->output->createProgressBar($files->count());
        $bar->start();

        $importedBooks = 0;
        $importedChapters = 0;
        $importedHadiths = 0;
        $skipped = 0;
        $failed = 0;

        foreach ($files as $file) {
            $slug = Str::of((string) $file->getFilename())
                ->replaceLast('.json', '')
                ->lower()
                ->toString();

            if ($filter !== [] && !in_array($slug, $filter, true)) {
                $skipped++;
                $bar->advance();

                continue;
            }

            try {
                [$chaptersCount, $hadithCount] = $this->importSingleFile(
                    filePath: (string) $file->getPathname(),
                    byBookPath: $byBookPath,
                    slug: $slug,
                    chunkSize: $chunkSize,
                );

                $importedBooks++;
                $importedChapters += $chaptersCount;
                $importedHadiths += $hadithCount;
            } catch (\Throwable $exception) {
                $failed++;
                $this->newLine();
                $this->error("Failed importing {$slug}: ".$exception->getMessage());
            } finally {
                $bar->advance();
            }
        }

        $bar->finish();
        $this->newLine(2);

        $this->info('Hadith import finished.');
        $this->line("Books imported: {$importedBooks}");
        $this->line("Chapters imported: {$importedChapters}");
        $this->line("Hadith imported: {$importedHadiths}");
        $this->line("Files skipped: {$skipped}");
        $this->line("Files failed: {$failed}");

        return $failed > 0 ? self::FAILURE : self::SUCCESS;
    }

    /**
     * @return array{0: int, 1: int}
     */
    private function importSingleFile(
        string $filePath,
        string $byBookPath,
        string $slug,
        int $chunkSize
    ): array {
        $decoded = json_decode(File::get($filePath), true, 512, JSON_THROW_ON_ERROR);
        if (!is_array($decoded)) {
            throw new \RuntimeException('JSON payload is not an object.');
        }

        $metadata = is_array($decoded['metadata'] ?? null) ? $decoded['metadata'] : [];
        $chapters = is_array($decoded['chapters'] ?? null) ? $decoded['chapters'] : [];
        $hadiths = is_array($decoded['hadiths'] ?? null) ? $decoded['hadiths'] : [];

        $bookId = (int) ($decoded['id'] ?? $metadata['id'] ?? 0);
        $titleAr = trim((string) data_get($metadata, 'arabic.title', $slug));
        $titleEn = trim((string) data_get($metadata, 'english.title', $slug));
        $authorAr = trim((string) data_get($metadata, 'arabic.author', ''));
        $authorEn = trim((string) data_get($metadata, 'english.author', ''));
        $introAr = trim((string) data_get($metadata, 'arabic.introduction', ''));
        $introEn = trim((string) data_get($metadata, 'english.introduction', ''));

        $relativeDirectory = trim(str_replace($byBookPath, '', dirname($filePath)), DIRECTORY_SEPARATOR);
        $sourceGroup = $relativeDirectory === ''
            ? 'by_book'
            : str_replace(DIRECTORY_SEPARATOR, '/', $relativeDirectory);

        $now = now();

        return DB::transaction(function () use (
            $slug,
            $bookId,
            $sourceGroup,
            $titleAr,
            $titleEn,
            $authorAr,
            $authorEn,
            $introAr,
            $introEn,
            $chapters,
            $hadiths,
            $decoded,
            $chunkSize,
            $now
        ): array {
            $book = AnaMuslimHadithBook::query()->updateOrCreate(
                ['slug' => $slug],
                [
                    'source_book_id' => $bookId > 0 ? $bookId : null,
                    'source_group' => $sourceGroup,
                    'title_ar' => $titleAr !== '' ? $titleAr : $slug,
                    'title_en' => $titleEn !== '' ? $titleEn : null,
                    'author_ar' => $authorAr !== '' ? $authorAr : null,
                    'author_en' => $authorEn !== '' ? $authorEn : null,
                    'introduction_ar' => $introAr !== '' ? $introAr : null,
                    'introduction_en' => $introEn !== '' ? $introEn : null,
                    'total_chapters' => count($chapters),
                    'total_hadith' => count($hadiths),
                    'metadata_json' => json_encode($decoded['metadata'] ?? [], JSON_UNESCAPED_UNICODE),
                ]
            );

            AnaMuslimHadith::query()->where('hadith_book_id', $book->id)->delete();
            AnaMuslimHadithChapter::query()->where('hadith_book_id', $book->id)->delete();

            $chapterRows = [];
            $usedChapterIds = [];
            foreach ($chapters as $index => $chapter) {
                if (!is_array($chapter)) {
                    continue;
                }

                $rawChapterId = $chapter['id'] ?? null;
                $sourceChapterId = is_numeric($rawChapterId) ? (int) $rawChapterId : 0;
                if (array_key_exists($sourceChapterId, $usedChapterIds)) {
                    $sourceChapterId = 100000 + ($index + 1);
                }
                $usedChapterIds[$sourceChapterId] = true;

                $chapterRows[] = [
                    'hadith_book_id' => $book->id,
                    'source_chapter_id' => $sourceChapterId,
                    'chapter_order' => $index + 1,
                    'title_ar' => trim((string) ($chapter['arabic'] ?? '')) ?: null,
                    'title_en' => trim((string) ($chapter['english'] ?? '')) ?: null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];
            }

            if ($chapterRows !== []) {
                foreach (array_chunk($chapterRows, $chunkSize) as $batch) {
                    DB::table('ana_muslim_hadith_chapters')->insert($batch);
                }
            }

            $chaptersMap = AnaMuslimHadithChapter::query()
                ->where('hadith_book_id', $book->id)
                ->pluck('id', 'source_chapter_id')
                ->all();

            $hadithRows = [];
            foreach ($hadiths as $index => $hadith) {
                if (!is_array($hadith)) {
                    continue;
                }

                $english = is_array($hadith['english'] ?? null) ? $hadith['english'] : [];

                $sourceChapterId = (int) ($hadith['chapterId'] ?? 0);
                $sourceHadithId = (int) ($hadith['id'] ?? 0);
                $hadithNumber = trim((string) ($hadith['idInBook'] ?? ''));
                if ($hadithNumber === '') {
                    $hadithNumber = (string) ($index + 1);
                }

                $hadithRows[] = [
                    'hadith_book_id' => $book->id,
                    'hadith_chapter_id' => $chaptersMap[$sourceChapterId] ?? null,
                    'source_hadith_id' => $sourceHadithId > 0 ? $sourceHadithId : null,
                    'hadith_number' => $hadithNumber,
                    'chapter_number' => (string) $sourceChapterId,
                    'arabic_text' => trim((string) ($hadith['arabic'] ?? '')) ?: null,
                    'english_narrator' => trim((string) ($english['narrator'] ?? '')) ?: null,
                    'english_text' => trim((string) ($english['text'] ?? '')) ?: null,
                    'created_at' => $now,
                    'updated_at' => $now,
                ];

                if (count($hadithRows) >= $chunkSize) {
                    DB::table('ana_muslim_hadiths')->insert($hadithRows);
                    $hadithRows = [];
                }
            }

            if ($hadithRows !== []) {
                DB::table('ana_muslim_hadiths')->insert($hadithRows);
            }

            return [count($chapterRows), count($hadiths)];
        }, 3);
    }

    private function resolveDatasetPath(): string
    {
        $fromOption = trim((string) $this->option('path'));
        if ($fromOption !== '') {
            return $fromOption;
        }

        $fromEnv = trim((string) env('HADITH_LIBRARY_PATH', ''));
        if ($fromEnv !== '') {
            return $fromEnv;
        }

        return '/Users/molood/Downloads/hadith-json-main/db';
    }

    /**
     * @return array<int, string>
     */
    private function parseCollectionsFilter(): array
    {
        $raw = trim((string) $this->option('collections'));
        if ($raw === '') {
            return [];
        }

        return collect(explode(',', $raw))
            ->map(fn (string $entry): string => Str::of($entry)->trim()->lower()->toString())
            ->filter(fn (string $entry): bool => $entry !== '')
            ->unique()
            ->values()
            ->all();
    }
}
