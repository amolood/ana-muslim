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
        Schema::create('ana_muslim_items', function (Blueprint $table) {
            $table->id('id'); // using their id
            $table->unsignedBigInteger('source_id')->nullable();
            $table->string('title', 500);
            $table->string('type', 100)->nullable();
            $table->longText('description')->nullable();
            $table->longText('full_description')->nullable();
            $table->string('source_language')->nullable();
            $table->string('translated_language')->nullable();
            $table->string('importance_level')->nullable();
            $table->integer('add_date')->nullable();
            $table->integer('update_date')->nullable();
            $table->string('image', 500)->nullable();
            $table->string('api_url', 500)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_items');
    }
};
