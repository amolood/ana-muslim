<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AnaMuslimNotification extends Model
{
    protected $fillable = ['title', 'message', 'type', 'target_url', 'payload', 'sent_at', 'recipients_count'];

    protected $casts = [
        'payload' => 'array',
        'sent_at' => 'datetime',
    ];
}
