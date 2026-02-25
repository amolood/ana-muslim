<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\HisnmuslimChapter;
use App\Models\HisnmuslimDua;
use Illuminate\Http\Request;

class HisnmuslimAdminController extends Controller
{
    // List all chapters
    public function index()
    {
        $chapters = HisnmuslimChapter::withCount('duas')
            ->orderBy('order')
            ->paginate(20);

        return view('admin.hisnmuslim.index', compact('chapters'));
    }

    // Show chapter details with duas
    public function show($id)
    {
        $chapter = HisnmuslimChapter::with('duas')->findOrFail($id);
        return view('admin.hisnmuslim.show', compact('chapter'));
    }

    // Edit chapter form
    public function editChapter($id)
    {
        $chapter = HisnmuslimChapter::findOrFail($id);
        return view('admin.hisnmuslim.edit-chapter', compact('chapter'));
    }

    // Update chapter
    public function updateChapter(Request $request, $id)
    {
        $chapter = HisnmuslimChapter::findOrFail($id);

        $validated = $request->validate([
            'title_ar' => 'required|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'audio_url' => 'nullable|url',
            'order' => 'required|integer',
            'is_active' => 'boolean',
        ]);

        $chapter->update($validated);

        return redirect()->route('admin.hisnmuslim.show', $chapter->id)
            ->with('success', 'تم تحديث الباب بنجاح');
    }

    // Edit dua form
    public function editDua($id)
    {
        $dua = HisnmuslimDua::with('chapter')->findOrFail($id);
        return view('admin.hisnmuslim.edit-dua', compact('dua'));
    }

    // Update dua
    public function updateDua(Request $request, $id)
    {
        $dua = HisnmuslimDua::findOrFail($id);

        $validated = $request->validate([
            'text_ar' => 'required|string',
            'text_en' => 'nullable|string',
            'translation_ar' => 'nullable|string',
            'translation_en' => 'nullable|string',
            'reference' => 'nullable|string',
            'count' => 'nullable|integer',
            'order' => 'required|integer',
            'is_active' => 'boolean',
        ]);

        $dua->update($validated);

        return redirect()->route('admin.hisnmuslim.show', $dua->chapter_id)
            ->with('success', 'تم تحديث الدعاء بنجاح');
    }

    // Create new chapter form
    public function createChapter()
    {
        return view('admin.hisnmuslim.create-chapter');
    }

    // Store new chapter
    public function storeChapter(Request $request)
    {
        $validated = $request->validate([
            'chapter_id' => 'required|integer|unique:hisnmuslim_chapters',
            'title_ar' => 'required|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'audio_url' => 'nullable|url',
            'order' => 'required|integer',
        ]);

        $chapter = HisnmuslimChapter::create($validated);

        return redirect()->route('admin.hisnmuslim.show', $chapter->id)
            ->with('success', 'تم إضافة الباب بنجاح');
    }

    // Create new dua form
    public function createDua($chapterId)
    {
        $chapter = HisnmuslimChapter::findOrFail($chapterId);
        return view('admin.hisnmuslim.create-dua', compact('chapter'));
    }

    // Store new dua
    public function storeDua(Request $request, $chapterId)
    {
        $validated = $request->validate([
            'text_ar' => 'required|string',
            'text_en' => 'nullable|string',
            'translation_ar' => 'nullable|string',
            'translation_en' => 'nullable|string',
            'reference' => 'nullable|string',
            'count' => 'nullable|integer',
            'order' => 'required|integer',
        ]);

        $validated['chapter_id'] = $chapterId;

        HisnmuslimDua::create($validated);

        return redirect()->route('admin.hisnmuslim.show', $chapterId)
            ->with('success', 'تم إضافة الدعاء بنجاح');
    }

    // Delete chapter
    public function deleteChapter($id)
    {
        $chapter = HisnmuslimChapter::findOrFail($id);
        $chapter->delete();

        return redirect()->route('admin.hisnmuslim.index')
            ->with('success', 'تم حذف الباب بنجاح');
    }

    // Delete dua
    public function deleteDua($id)
    {
        $dua = HisnmuslimDua::findOrFail($id);
        $chapterId = $dua->chapter_id;
        $dua->delete();

        return redirect()->route('admin.hisnmuslim.show', $chapterId)
            ->with('success', 'تم حذف الدعاء بنجاح');
    }
}
