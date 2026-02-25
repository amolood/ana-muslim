<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HisnmuslimChapter extends Model
{
    protected $fillable = [
        'chapter_id',
        'title_ar',
        'title_en',
        'audio_url',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function duas(): HasMany
    {
        return $this->hasMany(HisnmuslimDua::class, 'chapter_id');
    }
}
