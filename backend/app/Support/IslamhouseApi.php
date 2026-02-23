<?php

namespace App\Support;

class IslamhouseApi
{
    public static function url(string $path): string
    {
        $base = rtrim((string) config('islamhouse.base_url', 'https://api3.islamhouse.com/v3'), '/');
        $key = trim((string) config('islamhouse.api_key', ''), " /\t\n\r\0\x0B");
        $path = ltrim($path, '/');

        if ($key !== '') {
            return "{$base}/{$key}/{$path}";
        }

        return "{$base}/{$path}";
    }

    public static function normalizeUrl(string $url): string
    {
        $normalized = preg_replace('#^http://#i', 'https://', trim($url)) ?? trim($url);
        $base = rtrim((string) config('islamhouse.base_url', 'https://api3.islamhouse.com/v3'), '/');
        $key = trim((string) config('islamhouse.api_key', ''), " /\t\n\r\0\x0B");

        if (preg_match('#^https?://api3\.islamhouse\.com/v3/#i', $normalized) === 1) {
            if ($key !== '') {
                return preg_replace(
                    '#^https?://api3\.islamhouse\.com/v3/[^/]+#i',
                    "{$base}/{$key}",
                    $normalized
                ) ?? $normalized;
            }

            return preg_replace('#^https?://api3\.islamhouse\.com/v3#i', $base, $normalized) ?? $normalized;
        }

        return $normalized;
    }
}
