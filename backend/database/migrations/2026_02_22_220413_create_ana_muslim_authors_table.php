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
        Schema::create('ana_muslim_authors', function (Blueprint $table) {
            $table->id('id');
            $table->unsignedBigInteger('source_id')->nullable();
            $table->string('title', 500);
            $table->string('type')->nullable();
            $table->string('kind')->nullable();
            $table->longText('description')->nullable();
            $table->string('api_url', 500)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_authors');
    }
};
