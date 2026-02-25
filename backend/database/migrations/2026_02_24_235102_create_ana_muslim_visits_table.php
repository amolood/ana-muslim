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
        Schema::create('ana_muslim_visits', function (Blueprint $table) {
            $table->id();
            $table->string('ip')->index();
            $table->string('url')->index();
            $table->string('country')->nullable()->index();
            $table->string('city')->nullable();
            $table->string('browser')->nullable();
            $table->string('os')->nullable();
            $table->string('device')->nullable(); // mobile, desktop, tablet
            $table->string('referer')->nullable();
            $table->boolean('is_unique')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_visits');
    }
};
