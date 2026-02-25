<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimSetting extends Model
{
    protected $fillable = ['key', 'value', 'type', 'label'];

    /**
     * Get setting value by key with caching
     */
    public static function getValue(string $key, $default = null)
    {
        return \Illuminate\Support\Facades\Cache::remember("setting_{$key}", 3600, function () use ($key, $default) {
            $setting = self::where('key', $key)->first();
            return $setting ? $setting->value : $default;
        });
    }

    /**
     * Check if a feature is enabled
     */
    public static function isEnabled(string $key): bool
    {
        return (bool) self::getValue($key, false);
    }
}
