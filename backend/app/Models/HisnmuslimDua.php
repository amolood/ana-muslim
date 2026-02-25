<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HisnmuslimDua extends Model
{
    protected $fillable = [
        'chapter_id',
        'text_ar',
        'text_en',
        'translation_ar',
        'translation_en',
        'reference',
        'count',
        'order',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function chapter(): BelongsTo
    {
        return $this->belongsTo(HisnmuslimChapter::class, 'chapter_id');
    }
}
