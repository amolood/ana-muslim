<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class Mp3QuranService
{
    protected string $baseUrl = 'https://www.mp3quran.net/api/v3';
    protected int $cacheTTL = 86400; // 24 hours

    /**
     * Get list of reciters
     */
    public function getReciters(string $language = 'ar')
    {
        return Cache::remember("mp3quran_reciters_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/reciters', ['language' => $language]);
        });
    }

    /**
     * Get list of radios
     */
    public function getRadios(string $language = 'ar')
    {
        return Cache::remember("mp3quran_radios_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/radios', ['language' => $language]);
        });
    }

    /**
     * Get live TV streams
     */
    public function getLiveTv(string $language = 'ar')
    {
        return Cache::remember("mp3quran_live_tv_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/live-tv', ['language' => $language]);
        });
    }

    /**
     * Get categories / video types
     */
    public function getVideoTypes(string $language = 'ar')
    {
        return Cache::remember("mp3quran_video_types_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/video-types', ['language' => $language]);
        });
    }

    /**
     * Get videos
     */
    public function getVideos(string $language = 'ar')
    {
        return Cache::remember("mp3quran_videos_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/videos', ['language' => $language]);
        });
    }

    /**
     * Get suwar list
     */
    public function getSuwar(string $language = 'ar')
    {
        return Cache::remember("mp3quran_suwar_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/suwar', ['language' => $language]);
        });
    }

    /**
     * Get tafasir
     */
    public function getTafasir(string $language = 'ar')
    {
        return Cache::remember("mp3quran_tafasir_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/tafasir', ['language' => $language]);
        });
    }

    /**
     * Get tadabor
     */
    public function getTadabor(string $language = 'ar')
    {
        return Cache::remember("mp3quran_tadabor_{$language}", $this->cacheTTL, function () use ($language) {
            return $this->fetch('/tadabor', ['language' => $language]);
        });
    }

    /**
     * Helper to perform HTTP requests
     */
    protected function fetch(string $endpoint, array $params = [])
    {
        try {
            $response = Http::withHeaders([
                'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            ])->timeout(15)
              ->get($this->baseUrl . $endpoint, $params);

            if ($response->successful()) {
                return $response->json();
            }

            Log::error("Mp3Quran API Error [{$endpoint}]: " . $response->status());
        } catch (\Throwable $e) {
            Log::error("Mp3Quran API Exception [{$endpoint}]: " . $e->getMessage());
        }

        return null;
    }
}
