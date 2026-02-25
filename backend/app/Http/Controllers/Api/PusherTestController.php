<?php

namespace App\Http\Controllers\Api;

use App\Events\AdminNotification;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller لاختبار Pusher
 *
 * ملاحظة: Pusher يستخدم فقط للإشعارات المخصصة من الإدارة
 * جميع إشعارات الصلوات ورمضان تتم محلياً في التطبيق
 */
class PusherTestController extends Controller
{
    /**
     * اختبار إرسال إشعار مخصص من الإدارة
     */
    public function testAdminNotification(Request $request): JsonResponse
    {
        $title = $request->input('title', 'إشعار تجريبي');
        $body = $request->input('body', 'هذا إشعار تجريبي من الإدارة');
        $type = $request->input('type', 'general');
        $metadata = $request->input('metadata', null);

        // إطلاق حدث الإشعار المخصص
        event(new AdminNotification($title, $body, $type, $metadata));

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال الإشعار المخصص عبر Pusher',
            'data' => [
                'title' => $title,
                'body' => $body,
                'type' => $type,
                'metadata' => $metadata,
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * إرسال إشعار عام لجميع المستخدمين
     */
    public function sendGeneralNotification(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:1000',
            'type' => 'nullable|string|in:general,announcement,alert,reminder',
        ]);

        event(new AdminNotification(
            $request->input('title'),
            $request->input('body'),
            $request->input('type', 'general'),
            $request->input('metadata', null)
        ));

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال الإشعار بنجاح',
        ]);
    }

    /**
     * معلومات عن إعدادات Pusher
     */
    public function info(): JsonResponse
    {
        return response()->json([
            'pusher_configured' => config('broadcasting.default') === 'pusher',
            'app_key' => config('broadcasting.connections.pusher.key'),
            'cluster' => config('broadcasting.connections.pusher.options.cluster'),
            'app_id' => config('broadcasting.connections.pusher.app_id'),
            'note' => 'Pusher is used only for custom admin notifications. Prayer and Ramadan notifications are handled locally in the app.',
        ]);
    }
}
