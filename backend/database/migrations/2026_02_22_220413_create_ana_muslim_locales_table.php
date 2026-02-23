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
        Schema::create('ana_muslim_locales', function (Blueprint $table) {
            $table->id('id');
            $table->unsignedBigInteger('item_id')->index();
            $table->string('language');
            $table->string('url', 1000);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_locales');
    }
};
