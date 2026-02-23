<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimItem extends Model
{
    protected $table = 'ana_muslim_items';
    protected $fillable = [
        'id', 'source_id', 'title', 'type', 'description', 'full_description', 
        'source_language', 'translated_language', 'importance_level', 'add_date', 
        'update_date', 'image', 'api_url'
    ];

    public function authors()
    {
        return $this->belongsToMany(AnaMuslimAuthor::class, 'ana_muslim_item_author', 'item_id', 'author_id');
    }

    public function categories()
    {
        return $this->belongsToMany(AnaMuslimCategory::class, 'ana_muslim_item_category', 'item_id', 'category_id');
    }

    public function category()
    {
        return $this->categories()->first();
    }

    public function attachments()
    {
        return $this->hasMany(AnaMuslimAttachment::class, 'item_id');
    }

    public function locales()
    {
        return $this->hasMany(AnaMuslimLocale::class, 'item_id');
    }
}
