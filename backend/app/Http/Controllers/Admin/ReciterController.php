<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimReciter;
use Illuminate\Http\Request;

class ReciterController extends Controller
{
    public function index(Request $request)
    {
        $query = AnaMuslimReciter::query()->orderBy('display_order');

        if ($request->filled('search')) {
            $query->where('name', 'like', '%'.$request->get('search').'%');
        }

        if ($request->filled('nationality')) {
            $query->where('nationality', $request->get('nationality'));
        }

        if ($request->filled('status')) {
            $query->where('is_active', $request->get('status') === 'active');
        }

        $reciters = $query->paginate(20)->withQueryString();

        return view('admin.reciters.index', compact('reciters'));
    }

    public function create()
    {
        return view('admin.reciters.form');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'nationality' => 'nullable|string|max:10',
            'path' => 'required|string|max:255',
            'base_url' => 'required|url|max:255',
            'is_active' => 'boolean',
            'display_order' => 'integer',
        ]);

        AnaMuslimReciter::create($validated);

        return redirect()->route('admin.reciters.index')->with('success', 'تم إضافة القارئ بنجاح');
    }

    public function edit(AnaMuslimReciter $reciter)
    {
        return view('admin.reciters.form', compact('reciter'));
    }

    public function update(Request $request, AnaMuslimReciter $reciter)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'nationality' => 'nullable|string|max:10',
            'path' => 'required|string|max:255',
            'base_url' => 'required|url|max:255',
            'is_active' => 'boolean',
            'display_order' => 'integer',
        ]);

        $reciter->update($validated);

        return redirect()->route('admin.reciters.index')->with('success', 'تم تحديث القارئ بنجاح');
    }

    public function destroy(AnaMuslimReciter $reciter)
    {
        $reciter->delete();

        return redirect()->route('admin.reciters.index')->with('success', 'تم حذف القارئ بنجاح');
    }

    public function updateOrder(Request $request)
    {
        $request->validate([
            'order' => 'required|array',
            'order.*' => 'required|integer|exists:ana_muslim_reciters,id',
        ]);

        foreach ($request->order as $position => $id) {
            AnaMuslimReciter::where('id', $id)->update(['display_order' => $position]);
        }

        return response()->json(['success' => true]);
    }
}
