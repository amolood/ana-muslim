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
        Schema::create('ana_muslim_hadith_chapters', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('hadith_book_id');
            $table->unsignedInteger('source_chapter_id')->default(0);
            $table->unsignedInteger('chapter_order')->default(0);
            $table->string('title_ar', 500)->nullable();
            $table->string('title_en', 500)->nullable();
            $table->timestamps();

            $table->foreign('hadith_book_id')
                ->references('id')
                ->on('ana_muslim_hadith_books')
                ->onDelete('cascade');

            $table->index(['hadith_book_id', 'chapter_order'], 'am_hadith_chapters_book_order_idx');
            $table->unique(['hadith_book_id', 'source_chapter_id'], 'am_hadith_chapters_book_source_uq');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_hadith_chapters');
    }
};
