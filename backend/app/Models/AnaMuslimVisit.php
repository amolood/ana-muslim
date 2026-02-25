<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimVisit extends Model
{
    protected $fillable = [
        'ip', 'url', 'country', 'city', 'browser', 'os', 'device', 'referer', 'is_unique'
    ];
}
