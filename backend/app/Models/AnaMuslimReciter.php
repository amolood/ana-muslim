<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimReciter extends Model
{
    protected $fillable = ['name', 'nationality', 'path', 'base_url', 'is_active', 'display_order'];
}
