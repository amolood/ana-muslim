<?php

namespace Database\Seeders;

use App\Models\AnaMuslimSetting;
use Illuminate\Database\Seeder;

class AnaMuslimSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            [
                'key' => 'app_name',
                'label' => 'اسم التطبيق',
                'value' => 'أنا مسلم',
                'type' => 'text',
            ],
            [
                'key' => 'app_description',
                'label' => 'وصف التطبيق',
                'value' => 'تطبيق إسلامي شامل للأدعية والأذكار والقرآن الكريم',
                'type' => 'text',
            ],
            [
                'key' => 'app_logo',
                'label' => 'رابط الشعار',
                'value' => 'https://anaalmuslim.com/assets/anaalmuslim.svg',
                'type' => 'image',
            ],
            [
                'key' => 'contact_email',
                'label' => 'بريد التواصل',
                'value' => 'info@anaalmuslim.com',
                'type' => 'text',
            ],

            // ── App Version Control ──────────────────────────────────────
            [
                'key' => 'app_min_version',
                'label' => 'الحد الأدنى المدعوم (إلزامي)',
                'value' => '1.0.0',
                'type' => 'text',
            ],
            [
                'key' => 'app_latest_version',
                'label' => 'أحدث إصدار متاح',
                'value' => '1.0.0',
                'type' => 'text',
            ],
            [
                'key' => 'app_force_update',
                'label' => 'تحديث إلزامي للجميع',
                'value' => '0',
                'type' => 'boolean',
            ],
            [
                'key' => 'app_store_url_android',
                'label' => 'رابط Google Play',
                'value' => '',
                'type' => 'text',
            ],
            [
                'key' => 'app_store_url_ios',
                'label' => 'رابط App Store',
                'value' => '',
                'type' => 'text',
            ],
            [
                'key' => 'app_update_message_ar',
                'label' => 'رسالة التحديث (عربي)',
                'value' => 'يتوفر إصدار جديد من التطبيق، يرجى التحديث للاستمتاع بأحدث الميزات.',
                'type' => 'text',
            ],
            [
                'key' => 'app_update_message_en',
                'label' => 'رسالة التحديث (إنجليزي)',
                'value' => 'A new version is available. Please update to enjoy the latest features.',
                'type' => 'text',
            ],
            [
                'key' => 'app_update_message_fr',
                'label' => 'رسالة التحديث (فرنسي)',
                'value' => 'Une nouvelle version est disponible. Veuillez mettre à jour pour profiter des dernières fonctionnalités.',
                'type' => 'text',
            ],
        ];

        foreach ($settings as $setting) {
            AnaMuslimSetting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }
    }
}
