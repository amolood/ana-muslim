<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Mp3QuranService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class IslamicContentApiController extends Controller
{
    protected Mp3QuranService $mp3Quran;

    public function __construct(Mp3QuranService $mp3Quran)
    {
        $this->mp3Quran = $mp3Quran;
    }

    /**
     * Get list of radios
     */
    public function radios(Request $request): JsonResponse
    {
        if (!\App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled') || !\App\Models\AnaMuslimSetting::isEnabled('mp3quran_radios_enabled')) {
            return response()->json(['radios' => []]);
        }
        $language = $request->get('language', 'ar');
        return response()->json($this->mp3Quran->getRadios($language));
    }

    /**
     * Get live TV streams
     */
    public function liveTv(Request $request): JsonResponse
    {
        if (!\App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled') || !\App\Models\AnaMuslimSetting::isEnabled('mp3quran_live_tv_enabled')) {
            return response()->json(['livetv' => []]);
        }
        $language = $request->get('language', 'ar');
        return response()->json($this->mp3Quran->getLiveTv($language));
    }

    /**
     * Get categorized videos
     */
    public function videos(Request $request): JsonResponse
    {
        if (!\App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled') || !\App\Models\AnaMuslimSetting::isEnabled('mp3quran_videos_enabled')) {
            return response()->json(['types' => [], 'videos' => []]);
        }
        $language = $request->get('language', 'ar');
        return response()->json([
            'types' => $this->mp3Quran->getVideoTypes($language),
            'videos' => $this->mp3Quran->getVideos($language)
        ]);
    }

    /**
     * Get tafasir and tadabor
     */
    public function insights(Request $request): JsonResponse
    {
        if (!\App\Models\AnaMuslimSetting::isEnabled('mp3quran_enabled') || !\App\Models\AnaMuslimSetting::isEnabled('mp3quran_insights_enabled')) {
            return response()->json(['tafasir' => [], 'tadabor' => []]);
        }
        $language = $request->get('language', 'ar');
        return response()->json([
            'tafasir' => $this->mp3Quran->getTafasir($language),
            'tadabor' => $this->mp3Quran->getTadabor($language)
        ]);
    }
}
