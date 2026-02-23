<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ana_muslim_ramadan_schedule', function (Blueprint $table) {
            $table->id();
            $table->string('city_key', 64)->index();   // e.g. 'mecca', 'london'
            $table->decimal('lat', 10, 7);
            $table->decimal('lon', 10, 7);
            $table->date('date')->index();
            $table->string('day_name', 32)->nullable();
            $table->string('hijri_date', 32)->nullable();
            $table->string('hijri_readable', 128)->nullable();
            $table->string('sahur_time', 32)->nullable();
            $table->string('iftar_time', 32)->nullable();
            $table->string('fasting_duration', 64)->nullable();
            $table->boolean('is_white_day')->default(false);
            // Daily dua
            $table->text('dua_title')->nullable();
            $table->text('dua_arabic')->nullable();
            $table->text('dua_translation')->nullable();
            $table->text('dua_transliteration')->nullable();
            $table->string('dua_reference', 256)->nullable();
            // Daily hadith
            $table->text('hadith_arabic')->nullable();
            $table->text('hadith_english')->nullable();
            $table->string('hadith_source', 256)->nullable();
            $table->string('hadith_grade', 128)->nullable();

            $table->timestamps();

            $table->unique(['city_key', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_ramadan_schedule');
    }
};
