<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('ana_muslim_ramadan_schedule', function (Blueprint $table) {
            $table->string('day_name_ar', 64)->nullable()->after('day_name');
            $table->string('hijri_readable_ar', 128)->nullable()->after('hijri_readable');
            $table->text('dua_title_ar')->nullable()->after('dua_title');
        });
    }

    public function down(): void
    {
        Schema::table('ana_muslim_ramadan_schedule', function (Blueprint $table) {
            $table->dropColumn(['day_name_ar', 'hijri_readable_ar', 'dua_title_ar']);
        });
    }
};
