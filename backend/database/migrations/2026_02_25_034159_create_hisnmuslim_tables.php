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
        Schema::create('hisnmuslim_chapters', function (Blueprint $table) {
            $table->id();
            $table->integer('chapter_id')->unique();
            $table->string('title_ar');
            $table->string('title_en')->nullable();
            $table->string('audio_url')->nullable();
            $table->integer('order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('hisnmuslim_duas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chapter_id')->constrained('hisnmuslim_chapters')->onDelete('cascade');
            $table->text('text_ar');
            $table->text('text_en')->nullable();
            $table->text('translation_ar')->nullable();
            $table->text('translation_en')->nullable();
            $table->string('reference')->nullable();
            $table->integer('count')->nullable();
            $table->integer('order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hisnmuslim_duas');
        Schema::dropIfExists('hisnmuslim_chapters');
    }
};
