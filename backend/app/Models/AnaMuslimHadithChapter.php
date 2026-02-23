<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnaMuslimHadithChapter extends Model
{
    protected $table = 'ana_muslim_hadith_chapters';

    protected $fillable = [
        'hadith_book_id',
        'source_chapter_id',
        'chapter_order',
        'title_ar',
        'title_en',
    ];

    protected $casts = [
        'hadith_book_id' => 'integer',
        'source_chapter_id' => 'integer',
        'chapter_order' => 'integer',
    ];

    public function book(): BelongsTo
    {
        return $this->belongsTo(AnaMuslimHadithBook::class, 'hadith_book_id');
    }

    public function hadiths(): HasMany
    {
        return $this->hasMany(AnaMuslimHadith::class, 'hadith_chapter_id');
    }
}
