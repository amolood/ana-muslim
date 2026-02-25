<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AnaMuslimSetting;

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
                'value' => 'https://anaalmuslim.com/logo.png',
                'type' => 'image',
            ],
            [
                'key' => 'contact_email',
                'label' => 'بريد التواصل',
                'value' => 'info@anaalmuslim.com',
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
