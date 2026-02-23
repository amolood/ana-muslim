<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\AnaMuslimAuthor;

class AuthorController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = AnaMuslimAuthor::query();

        if ($request->has('search')) {
            $search = $request->get('search');
            $query->where('title', 'like', "%{$search}%");
        }

        $authors = $query->latest()->paginate(20);

        // Calculate Stats
        $stats = [
            'total_authors' => AnaMuslimAuthor::count(),
            'authors_with_items' => AnaMuslimAuthor::has('items')->count(),
            'authors_without_items' => AnaMuslimAuthor::doesntHave('items')->count(),
        ];

        return view('admin.authors.index', compact('authors', 'stats'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('admin.authors.form');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:500',
            'type' => 'nullable|string|max:255',
            'kind' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'api_url' => 'nullable|url|max:500',
        ]);

        AnaMuslimAuthor::create($validated);

        return redirect()->route('admin.authors.index')->with('success', 'تم إضافة المؤلف بنجاح');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $author = AnaMuslimAuthor::findOrFail($id);
        return view('admin.authors.form', compact('author'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $author = AnaMuslimAuthor::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:500',
            'type' => 'nullable|string|max:255',
            'kind' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'api_url' => 'nullable|url|max:500',
        ]);

        $author->update($validated);

        return redirect()->route('admin.authors.index')->with('success', 'تم تحديث المؤلف بنجاح');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $author = AnaMuslimAuthor::findOrFail($id);
        
        // Detach from all items first
        $author->items()->detach();
        $author->delete();

        return redirect()->route('admin.authors.index')->with('success', 'تم حذف المؤلف بنجاح');
    }
}
