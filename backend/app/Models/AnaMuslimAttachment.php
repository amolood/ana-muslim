<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimAttachment extends Model
{
    protected $table = 'ana_muslim_attachments';
    protected $fillable = ['id', 'item_id', 'order', 'size', 'extension_type', 'description', 'url'];

    public function item()
    {
        return $this->belongsTo(AnaMuslimItem::class, 'item_id');
    }
}
