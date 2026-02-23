<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimAuthor extends Model
{
    protected $table = 'ana_muslim_authors';
    protected $fillable = ['id', 'source_id', 'title', 'type', 'kind', 'description', 'api_url'];

    public function items()
    {
        return $this->belongsToMany(AnaMuslimItem::class, 'ana_muslim_item_author', 'author_id', 'item_id');
    }
}
