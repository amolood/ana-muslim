<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnaMuslimHadithBook extends Model
{
    protected $table = 'ana_muslim_hadith_books';

    protected $fillable = [
        'source_book_id',
        'slug',
        'source_group',
        'title_ar',
        'title_en',
        'author_ar',
        'author_en',
        'introduction_ar',
        'introduction_en',
        'total_chapters',
        'total_hadith',
        'metadata_json',
    ];

    protected $casts = [
        'source_book_id' => 'integer',
        'total_chapters' => 'integer',
        'total_hadith' => 'integer',
    ];

    public function chapters(): HasMany
    {
        return $this->hasMany(AnaMuslimHadithChapter::class, 'hadith_book_id')
            ->orderBy('chapter_order');
    }

    public function hadiths(): HasMany
    {
        return $this->hasMany(AnaMuslimHadith::class, 'hadith_book_id');
    }
}
