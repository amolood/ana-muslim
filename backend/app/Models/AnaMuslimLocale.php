<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimLocale extends Model
{
    protected $table = 'ana_muslim_locales';
    protected $fillable = ['id', 'item_id', 'language', 'url'];

    public function item()
    {
        return $this->belongsTo(AnaMuslimItem::class, 'item_id');
    }
}
