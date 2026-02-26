<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AnaMuslimInitialDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reciters
        $reciters = [
            // Official mp3quran.net v3 IDs for top Sudanese reciters
            ['id' => 13, 'name' => 'الزين محمد أحمد', 'nationality' => 'SD', 'path' => 'alzain/', 'base_url' => 'https://server9.mp3quran.net/', 'display_order' => 1],
            ['id' => 138, 'name' => 'نورين محمد صديق', 'nationality' => 'SD', 'path' => 'nourin_siddig/Rewayat-Aldori-A-n-Abi-Amr/', 'base_url' => 'https://server16.mp3quran.net/', 'display_order' => 2],
            ['id' => 211, 'name' => 'الفاتح محمد زبير', 'nationality' => 'SD', 'path' => 'fateh/', 'base_url' => 'https://server6.mp3quran.net/', 'display_order' => 3],
            ['id' => 115, 'name' => 'محمد عبدالكريم', 'nationality' => 'SD', 'path' => 'm_krm/', 'base_url' => 'https://server12.mp3quran.net/', 'display_order' => 4],

            // Custom Sudanese Reciters
            ['id' => 910001, 'name' => 'محمد عثمان الحاج', 'nationality' => 'SD', 'path' => 'mohamed_osman_links.json', 'base_url' => 'json://', 'display_order' => 5],
            ['id' => 910002, 'name' => 'أحمد محمد طاهر', 'nationality' => 'SD', 'path' => 'quran3/4431/14647/128/', 'base_url' => 'https://download.quran.islamway.net/', 'display_order' => 6],
        ];

        foreach ($reciters as $reciter) {
            \App\Models\AnaMuslimReciter::updateOrCreate(['id' => $reciter['id']], $reciter);
        }

        // Settings
        $settings = [
            ['key' => 'app_name', 'value' => 'أنا المسلم', 'type' => 'string', 'label' => 'اسم التطبيق'],
            ['key' => 'branding_logo', 'value' => null, 'type' => 'image', 'label' => 'شعار التطبيق'],
            ['key' => 'mp3quran_enabled', 'value' => '1', 'type' => 'boolean', 'label' => 'تفعيل نظام mp3quran'],
            ['key' => 'mp3quran_radios_enabled', 'value' => '1', 'type' => 'boolean', 'label' => 'تفعيل الإذاعات'],
            ['key' => 'mp3quran_live_tv_enabled', 'value' => '1', 'type' => 'boolean', 'label' => 'تفعيل البث المباشر'],
            ['key' => 'mp3quran_videos_enabled', 'value' => '1', 'type' => 'boolean', 'label' => 'تفعيل الفيديوهات'],
            ['key' => 'mp3quran_insights_enabled', 'value' => '1', 'type' => 'boolean', 'label' => 'تفعيل التفسير والتدبر'],
        ];

        foreach ($settings as $setting) {
            \App\Models\AnaMuslimSetting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
