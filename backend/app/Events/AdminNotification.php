<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * حدث الإشعارات المخصصة من الإدارة
 *
 * يتم استخدام هذا الحدث لإرسال إشعارات فورية من الإدارة إلى جميع المستخدمين
 * عبر Pusher. جميع إشعارات الصلوات ورمضان تتم محلياً في التطبيق.
 */
class AdminNotification implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * عنوان الإشعار
     */
    public string $title;

    /**
     * محتوى الإشعار
     */
    public string $body;

    /**
     * نوع الإشعار (general, announcement, alert, etc.)
     */
    public string $type;

    /**
     * بيانات إضافية اختيارية
     */
    public ?array $metadata;

    /**
     * إنشاء حدث جديد
     *
     * @param string $title عنوان الإشعار
     * @param string $body محتوى الإشعار
     * @param string $type نوع الإشعار (general, announcement, alert)
     * @param array|null $metadata بيانات إضافية
     */
    public function __construct(
        string $title,
        string $body,
        string $type = 'general',
        ?array $metadata = null
    ) {
        $this->title = $title;
        $this->body = $body;
        $this->type = $type;
        $this->metadata = $metadata;
    }

    /**
     * القناة التي سيتم البث عليها
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new Channel('muslim-app'),
        ];
    }

    /**
     * اسم الحدث عند البث
     *
     * @return string
     */
    public function broadcastAs(): string
    {
        return 'admin-notification';
    }

    /**
     * البيانات التي سيتم بثها
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        $data = [
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type,
            'timestamp' => now()->toIso8601String(),
        ];

        if ($this->metadata !== null) {
            $data['metadata'] = $this->metadata;
        }

        return $data;
    }
}
