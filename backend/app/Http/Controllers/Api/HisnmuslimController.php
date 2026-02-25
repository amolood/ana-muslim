<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\HisnmuslimChapter;
use App\Models\HisnmuslimDua;
use Illuminate\Http\Request;

class HisnmuslimController extends Controller
{
    public function chapters()
    {
        $chapters = HisnmuslimChapter::where('is_active', true)
            ->orderBy('order')
            ->get();

        return response()->json($chapters);
    }

    public function duas($chapterId)
    {
        $chapter = HisnmuslimChapter::where('chapter_id', $chapterId)
            ->where('is_active', true)
            ->firstOrFail();

        $duas = HisnmuslimDua::where('chapter_id', $chapter->id)
            ->where('is_active', true)
            ->orderBy('order')
            ->get();

        return response()->json([
            'chapter' => $chapter,
            'duas' => $duas
        ]);
    }
}
