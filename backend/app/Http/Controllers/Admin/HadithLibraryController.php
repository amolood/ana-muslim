<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimHadith;
use App\Models\AnaMuslimHadithBook;
use App\Models\AnaMuslimHadithChapter;
use Illuminate\Http\Request;

class HadithLibraryController extends Controller
{
    public function index(Request $request)
    {
        $search = trim((string) $request->query('search', ''));

        $query = AnaMuslimHadithBook::query()->withCount(['chapters', 'hadiths']);

        if ($search !== '') {
            $query->where(function ($builder) use ($search): void {
                $builder->where('slug', 'like', "%{$search}%")
                    ->orWhere('title_ar', 'like', "%{$search}%")
                    ->orWhere('title_en', 'like', "%{$search}%")
                    ->orWhere('author_ar', 'like', "%{$search}%")
                    ->orWhere('author_en', 'like', "%{$search}%");
            });
        }

        $books = $query
            ->orderBy('source_book_id')
            ->orderBy('slug')
            ->paginate(15)
            ->withQueryString();

        $stats = [
            'books_count' => (int) AnaMuslimHadithBook::query()->count(),
            'chapters_count' => (int) AnaMuslimHadithChapter::query()->count(),
            'hadith_count' => (int) AnaMuslimHadith::query()->count(),
            'sahih_collections' => (int) AnaMuslimHadithBook::query()
                ->whereIn('slug', ['bukhari', 'muslim'])
                ->count(),
        ];

        return view('admin.hadith.index', compact('books', 'stats'));
    }

    public function show(Request $request, AnaMuslimHadithBook $book)
    {
        $search = trim((string) $request->query('search', ''));
        $chapterFilter = trim((string) $request->query('chapter', ''));

        $chapters = $book->chapters()->get();

        $query = AnaMuslimHadith::query()
            ->with('chapter')
            ->where('hadith_book_id', $book->id)
            ->orderByRaw('CAST(hadith_number AS UNSIGNED) ASC')
            ->orderBy('id');

        if ($chapterFilter !== '') {
            $chapter = AnaMuslimHadithChapter::query()
                ->where('hadith_book_id', $book->id)
                ->where('source_chapter_id', (int) $chapterFilter)
                ->first();

            if ($chapter) {
                $query->where('hadith_chapter_id', $chapter->id);
            }
        }

        if ($search !== '') {
            $query->where(function ($builder) use ($search): void {
                $builder->where('hadith_number', 'like', "%{$search}%")
                    ->orWhere('arabic_text', 'like', "%{$search}%")
                    ->orWhere('english_narrator', 'like', "%{$search}%")
                    ->orWhere('english_text', 'like', "%{$search}%");
            });
        }

        $hadiths = $query->paginate(40)->withQueryString();

        return view('admin.hadith.show', compact('book', 'chapters', 'hadiths'));
    }
}
