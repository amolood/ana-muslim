<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimCategory extends Model
{
    protected $table = 'ana_muslim_categories';
    protected $fillable = ['title', 'block_name', 'items_count', 'language', 'parent_id'];

    public function parent()
    {
        return $this->belongsTo(AnaMuslimCategory::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(AnaMuslimCategory::class, 'parent_id');
    }
}
