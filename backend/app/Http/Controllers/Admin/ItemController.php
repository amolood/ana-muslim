<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimAuthor;
use App\Models\AnaMuslimItem;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = AnaMuslimItem::with(['categories', 'authors']);

        if ($request->has('search') && $request->get('search') !== '') {
            $search = trim((string) $request->get('search'));
            $query->where(function ($searchQuery) use ($search) {
                $searchQuery
                    ->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('full_description', 'like', "%{$search}%")
                    ->orWhereHas('authors', function ($authorsQuery) use ($search) {
                        $authorsQuery->where('title', 'like', "%{$search}%");
                    });
            });
        }

        if ($request->has('type') && $request->get('type') !== '') {
            $query->where('type', $request->get('type'));
        }

        $currentCategory = null;
        if ($request->has('category_id') && $request->get('category_id') !== '') {
            $categoryId = $request->get('category_id');
            $currentCategory = \App\Models\AnaMuslimCategory::find($categoryId);

            if ($currentCategory) {
                // Fetch all child category IDs across the tree structure (up to 3 levels deep)
                $categoryIds = [$categoryId];

                // Get Level 1 children
                $level1 = \App\Models\AnaMuslimCategory::where('parent_id', $categoryId)->pluck('id')->toArray();
                if (! empty($level1)) {
                    $categoryIds = array_merge($categoryIds, $level1);

                    // Get Level 2 children
                    $level2 = \App\Models\AnaMuslimCategory::whereIn('parent_id', $level1)->pluck('id')->toArray();
                    if (! empty($level2)) {
                        $categoryIds = array_merge($categoryIds, $level2);

                        // Get Level 3 children (just in case)
                        $level3 = \App\Models\AnaMuslimCategory::whereIn('parent_id', $level2)->pluck('id')->toArray();
                        if (! empty($level3)) {
                            $categoryIds = array_merge($categoryIds, $level3);
                        }
                    }
                }

                $query->whereHas('categories', function ($q) use ($categoryIds) {
                    $q->whereIn('ana_muslim_categories.id', $categoryIds);
                });
            }
        }

        $items = $query->latest()->paginate(20);

        $types = AnaMuslimItem::select('type')->distinct()->pluck('type')
            ->reject(function ($type) {
                return is_numeric($type) || empty(trim($type));
            })->values();

        // Arabic translations mapping for known types
        $typeMap = [
            'audio' => 'صوتيات',
            'audios' => 'صوتيات',
            'video' => 'مرئيات',
            'videos' => 'مرئيات',
            'books' => 'كتب',
            'book' => 'كتاب',
            'articles' => 'مقالات',
            'article' => 'مقال',
            'fatwa' => 'فتاوى',
            'apps' => 'تطبيقات',
            'app' => 'تطبيق',
            'quran' => 'قرآن كريم',
            'khotab' => 'خطب',
            'poster' => 'بطاقات وملصقات',
            'favorites' => 'مفضلة',
        ];

        // Retrieve detailed statistics
        $stats = [
            'total_items' => AnaMuslimItem::count(),
            'audio_video' => AnaMuslimItem::whereIn('type', ['audio', 'audios', 'video', 'videos'])->count(),
            'books_articles' => AnaMuslimItem::whereIn('type', ['book', 'books', 'article', 'articles'])->count(),
            'total_authors' => AnaMuslimAuthor::count(),
        ];

        return view('admin.items.index', compact('items', 'types', 'typeMap', 'stats', 'currentCategory'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $categories = \App\Models\AnaMuslimCategory::with('parent.parent')->orderBy('title')->get();
        $authors = \App\Models\AnaMuslimAuthor::orderBy('title')->get();

        return view('admin.items.form', compact('categories', 'authors'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:500',
            'type' => 'nullable|string|max:100',
            'description' => 'nullable|string',
            'full_description' => 'nullable|string',
            'source_language' => 'nullable|string|max:10',
            'translated_language' => 'nullable|string|max:10',
            'importance_level' => 'nullable|string|max:255',
            'image' => 'nullable|string|max:500',
            'api_url' => 'nullable|url|max:500',
            'categories' => 'nullable|array',
            'categories.*' => 'exists:ana_muslim_categories,id',
            'authors' => 'nullable|array',
            'authors.*' => 'exists:ana_muslim_authors,id',
        ]);

        $item = AnaMuslimItem::create($validated);

        if ($request->has('categories')) {
            $item->categories()->sync($request->categories);
        }
        if ($request->has('authors')) {
            $item->authors()->sync($request->authors);
        }

        return redirect()->route('admin.items.index')->with('success', 'تم إضافة المادة بنجاح');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $item = AnaMuslimItem::findOrFail($id);
        $categories = \App\Models\AnaMuslimCategory::with('parent.parent')->orderBy('title')->get();
        $authors = \App\Models\AnaMuslimAuthor::orderBy('title')->get();

        return view('admin.items.form', compact('item', 'categories', 'authors'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $item = AnaMuslimItem::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:500',
            'type' => 'nullable|string|max:100',
            'description' => 'nullable|string',
            'full_description' => 'nullable|string',
            'source_language' => 'nullable|string|max:10',
            'translated_language' => 'nullable|string|max:10',
            'importance_level' => 'nullable|string|max:255',
            'image' => 'nullable|string|max:500',
            'api_url' => 'nullable|url|max:500',
            'categories' => 'nullable|array',
            'categories.*' => 'exists:ana_muslim_categories,id',
            'authors' => 'nullable|array',
            'authors.*' => 'exists:ana_muslim_authors,id',
        ]);

        $item->update($validated);

        if ($request->has('categories')) {
            $item->categories()->sync($request->categories);
        } else {
            $item->categories()->detach();
        }

        if ($request->has('authors')) {
            $item->authors()->sync($request->authors);
        } else {
            $item->authors()->detach();
        }

        return redirect()->route('admin.items.index')->with('success', 'تم تحديث المادة بنجاح');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $item = AnaMuslimItem::findOrFail($id);

        // Detach relations
        $item->categories()->detach();
        $item->authors()->detach();
        $item->attachments()->delete();
        $item->locales()->delete();

        $item->delete();

        return redirect()->route('admin.items.index')->with('success', 'تم حذف المادة بنجاح');
    }
}
