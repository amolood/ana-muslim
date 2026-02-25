<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimReciter;
use Illuminate\Http\Request;

class ReciterController extends Controller
{
    public function index()
    {
        $reciters = AnaMuslimReciter::orderBy('display_order')->paginate(20);
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
}
