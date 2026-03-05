<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimCategory;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = AnaMuslimCategory::with(['parent', 'children'])->orderBy('id', 'asc');

        $currentParent = null;
        $parentId = $request->get('parent_id');
        $search = trim((string) $request->get('search', ''));

        if ($parentId !== null && $parentId !== '') {
            $query->where('parent_id', $parentId);
            $currentParent = AnaMuslimCategory::find($parentId);
        } elseif ($search === '') {
            // Default view: root categories only
            $query->whereNull('parent_id');
        }

        if ($search !== '') {
            $query->where(function ($searchQuery) use ($search) {
                $searchQuery
                    ->where('title', 'like', "%{$search}%")
                    ->orWhere('block_name', 'like', "%{$search}%");
            });
        }

        $categories = $query->paginate(20);
        $parentCategories = AnaMuslimCategory::whereNull('parent_id')->orderBy('title', 'asc')->get();

        $stats = [
            'total_categories' => AnaMuslimCategory::count(),
            'root_categories' => AnaMuslimCategory::whereNull('parent_id')->count(),
            'sub_categories' => AnaMuslimCategory::whereNotNull('parent_id')->count(),
            'total_items_in_categories' => AnaMuslimCategory::sum('items_count'),
        ];

        return view('admin.categories.index', compact('categories', 'parentCategories', 'stats', 'currentParent'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $parentCategories = AnaMuslimCategory::orderBy('title')->get();

        return view('admin.categories.form', compact('parentCategories'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'block_name' => 'nullable|string|max:255',
            'items_count' => 'nullable|integer',
            'language' => 'required|string|max:10',
            'parent_id' => 'nullable|exists:ana_muslim_categories,id',
        ]);

        AnaMuslimCategory::create($validated);

        return redirect()->route('admin.categories.index')->with('success', 'تم إضافة التصنيف بنجاح');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $category = AnaMuslimCategory::findOrFail($id);
        $parentCategories = AnaMuslimCategory::where('id', '!=', $id)->orderBy('title')->get();

        return view('admin.categories.form', compact('category', 'parentCategories'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $category = AnaMuslimCategory::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'block_name' => 'nullable|string|max:255',
            'items_count' => 'nullable|integer',
            'language' => 'required|string|max:10',
            'parent_id' => 'nullable|exists:ana_muslim_categories,id',
        ]);

        // Prevent setting parent_id to itself
        if ($validated['parent_id'] == $category->id) {
            return back()->withErrors(['parent_id' => 'لا يمكن للتصنيف أن يكون أباً لنفسه.']);
        }

        $category->update($validated);

        return redirect()->route('admin.categories.index')->with('success', 'تم تحديث التصنيف بنجاح');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $category = AnaMuslimCategory::findOrFail($id);

        // Check if it has children
        if ($category->children()->count() > 0) {
            return back()->withErrors(['error' => 'لا يمكن حذف التصنيف لاحتوائه على تصنيفات فرعية.']);
        }

        $category->delete();

        return redirect()->route('admin.categories.index')->with('success', 'تم حذف التصنيف بنجاح');
    }
}
