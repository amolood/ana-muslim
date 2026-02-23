<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\AnaMuslimAttachment;
use App\Models\AnaMuslimItem;

class AttachmentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = AnaMuslimAttachment::with('item');

        $item_id = $request->get('item_id');
        if (!empty($item_id)) {
            $query->where('item_id', $item_id);
            $item = AnaMuslimItem::find($item_id);
        } else {
            $item = null;
        }

        $attachments = $query->orderBy('item_id')->orderBy('order')->paginate(20);

        // Calculate Stats
        $baseQuery = $item ? AnaMuslimAttachment::where('item_id', $item_id) : AnaMuslimAttachment::query();
        
        $stats = [
            'total' => (clone $baseQuery)->count(),
            'audio' => (clone $baseQuery)->whereIn('extension_type', ['mp3', 'مقطع صوتي', 'audio'])->count(),
            'video' => (clone $baseQuery)->whereIn('extension_type', ['mp4', 'مقطع مرئي', 'video', 'youtube'])->count(),
            'docs' => (clone $baseQuery)->whereIn('extension_type', ['pdf', 'doc', 'docx', 'book', 'كتاب'])->count(),
        ];

        return view('admin.attachments.index', compact('attachments', 'item', 'stats'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        $item_id = $request->get('item_id');
        $item = $item_id ? AnaMuslimItem::findOrFail($item_id) : null;
        
        return view('admin.attachments.form', compact('item'));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'item_id' => 'required|exists:ana_muslim_items,id',
            'order' => 'nullable|integer',
            'size' => 'nullable|string|max:255',
            'extension_type' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'url' => 'required|url|max:1000',
        ]);

        $attachment = AnaMuslimAttachment::create($validated);

        return redirect()->route('admin.attachments.index', ['item_id' => $attachment->item_id])
            ->with('success', 'تم إضافة المرفق بنجاح');
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $attachment = AnaMuslimAttachment::with('item')->findOrFail($id);
        $item = $attachment->item;
        return view('admin.attachments.form', compact('attachment', 'item'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $attachment = AnaMuslimAttachment::findOrFail($id);

        $validated = $request->validate([
            'item_id' => 'required|exists:ana_muslim_items,id',
            'order' => 'nullable|integer',
            'size' => 'nullable|string|max:255',
            'extension_type' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'url' => 'required|url|max:1000',
        ]);

        $attachment->update($validated);

        return redirect()->route('admin.attachments.index', ['item_id' => $attachment->item_id])
            ->with('success', 'تم تحديث المرفق بنجاح');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $attachment = AnaMuslimAttachment::findOrFail($id);
        $item_id = $attachment->item_id;
        $attachment->delete();

        return redirect()->route('admin.attachments.index', ['item_id' => $item_id])
            ->with('success', 'تم حذف المرفق بنجاح');
    }
}
