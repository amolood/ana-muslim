<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimRamadanSchedule extends Model
{
    protected $table = 'ana_muslim_ramadan_schedule';

    protected $fillable = [
        'city_key',
        'lat',
        'lon',
        'date',
        'day_name',
        'day_name_ar',
        'hijri_date',
        'hijri_readable',
        'hijri_readable_ar',
        'sahur_time',
        'iftar_time',
        'fasting_duration',
        'fasting_duration_ar',
        'is_white_day',
        'dua_title',
        'dua_title_ar',
        'dua_arabic',
        'dua_translation',
        'dua_transliteration',
        'dua_reference',
        'hadith_arabic',
        'hadith_english',
        'hadith_source',
        'hadith_grade',
    ];

    protected $casts = [
        'date'         => 'date',
        'is_white_day' => 'boolean',
        'lat'          => 'float',
        'lon'          => 'float',
    ];
}
