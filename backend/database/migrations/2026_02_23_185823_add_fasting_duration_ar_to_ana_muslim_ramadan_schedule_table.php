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
            $table->string('fasting_duration_ar', 64)->nullable()->after('fasting_duration');
        });
    }

    public function down(): void
    {
        Schema::table('ana_muslim_ramadan_schedule', function (Blueprint $table) {
            $table->dropColumn('fasting_duration_ar');
        });
    }
};
