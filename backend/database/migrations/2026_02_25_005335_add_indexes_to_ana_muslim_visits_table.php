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
        Schema::table('ana_muslim_visits', function (Blueprint $table) {
            $table->index('created_at');
            $table->index('is_unique');
            $table->index('os');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ana_muslim_visits', function (Blueprint $table) {
            //
        });
    }
};
