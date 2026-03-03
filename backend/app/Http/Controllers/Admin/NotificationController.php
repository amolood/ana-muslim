<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimNotification;
use Illuminate\Http\Request;
use Pusher\Pusher;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = AnaMuslimNotification::latest()->paginate(20);

        return view('admin.notifications.index', compact('notifications'));
    }

    public function create()
    {
        return view('admin.notifications.form');
    }

    public function send(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'type' => 'required|string',
            'target_url' => 'nullable|url',
        ]);

        $notification = AnaMuslimNotification::create($validated);

        // Send via Pusher
        try {
            $pusher = new Pusher(
                config('broadcasting.connections.pusher.key'),
                config('broadcasting.connections.pusher.secret'),
                config('broadcasting.connections.pusher.app_id'),
                [
                    'cluster' => config('broadcasting.connections.pusher.options.cluster'),
                    'useTLS' => true,
                ]
            );

            $data = [
                'title' => $notification->title,
                'body' => $notification->message,
                'type' => $notification->type,
                'target_url' => $notification->target_url,
                'sent_at' => now()->toDateTimeString(),
            ];

            $pusher->trigger('ana-muslim-channel', 'admin-notification', $data);

            $notification->update(['sent_at' => now()]);

            return redirect()->route('admin.notifications.index')->with('success', 'تم إرسال التنبيه بنجاح');
        } catch (\Exception $e) {
            return back()->with('error', 'فشل في إرسال التنبيه: '.$e->getMessage());
        }
    }
}
