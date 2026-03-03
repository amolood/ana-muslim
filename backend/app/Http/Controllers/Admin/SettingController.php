<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimSetting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    public function index()
    {
        $settings = AnaMuslimSetting::all();

        return view('admin.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        // Handle regular text/boolean settings (excludes the image file array).
        foreach ($request->except(['_token', 'image_files']) as $key => $value) {
            $setting = AnaMuslimSetting::where('key', $key)->first();
            if ($setting) {
                $setting->update(['value' => $value]);
                Cache::forget("setting_{$key}");
            }
        }

        // Handle image uploads — stored in public disk, saved as full URL.
        foreach ($request->file('image_files', []) as $key => $file) {
            if (! $file->isValid()) {
                continue;
            }

            $setting = AnaMuslimSetting::where('key', $key)->first();
            if ($setting) {
                $path = $file->store('settings', 'public');
                $url = Storage::disk('public')->url($path);
                $setting->update(['value' => $url]);
                Cache::forget("setting_{$key}");
            }
        }

        return redirect()->route('admin.settings.index')->with('success', 'تم تحديث الإعدادات بنجاح');
    }
}
