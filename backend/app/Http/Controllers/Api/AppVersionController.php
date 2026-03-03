<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AnaMuslimSetting;
use Illuminate\Http\JsonResponse;

class AppVersionController extends Controller
{
    public function check(): JsonResponse
    {
        return response()->json([
            'latest_version' => AnaMuslimSetting::getValue('app_latest_version', '1.0.0'),
            'min_version' => AnaMuslimSetting::getValue('app_min_version', '1.0.0'),
            'force_update' => AnaMuslimSetting::isEnabled('app_force_update'),
            'store_url_android' => AnaMuslimSetting::getValue('app_store_url_android', ''),
            'store_url_ios' => AnaMuslimSetting::getValue('app_store_url_ios', ''),
            'message_ar' => AnaMuslimSetting::getValue('app_update_message_ar', 'يتوفر إصدار جديد من التطبيق'),
            'message_en' => AnaMuslimSetting::getValue('app_update_message_en', 'A new version is available'),
            'message_fr' => AnaMuslimSetting::getValue('app_update_message_fr', 'Une nouvelle version est disponible'),
        ]);
    }
}
