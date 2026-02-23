<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnaMuslimHadith extends Model
{
    protected $table = 'ana_muslim_hadiths';

    protected $fillable = [
        'hadith_book_id',
        'hadith_chapter_id',
        'source_hadith_id',
        'hadith_number',
        'chapter_number',
        'arabic_text',
        'english_narrator',
        'english_text',
    ];

    protected $casts = [
        'hadith_book_id' => 'integer',
        'hadith_chapter_id' => 'integer',
        'source_hadith_id' => 'integer',
    ];

    public function book(): BelongsTo
    {
        return $this->belongsTo(AnaMuslimHadithBook::class, 'hadith_book_id');
    }

    public function chapter(): BelongsTo
    {
        return $this->belongsTo(AnaMuslimHadithChapter::class, 'hadith_chapter_id');
    }
}
