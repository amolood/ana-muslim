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
        Schema::create('ana_muslim_hadiths', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('hadith_book_id');
            $table->unsignedBigInteger('hadith_chapter_id')->nullable();
            $table->unsignedBigInteger('source_hadith_id')->nullable()->index();
            $table->string('hadith_number', 40)->index();
            $table->string('chapter_number', 40)->nullable()->index();
            $table->longText('arabic_text')->nullable();
            $table->text('english_narrator')->nullable();
            $table->longText('english_text')->nullable();
            $table->timestamps();

            $table->foreign('hadith_book_id')
                ->references('id')
                ->on('ana_muslim_hadith_books')
                ->onDelete('cascade');

            $table->foreign('hadith_chapter_id')
                ->references('id')
                ->on('ana_muslim_hadith_chapters')
                ->nullOnDelete();

            $table->index(['hadith_book_id', 'hadith_chapter_id'], 'am_hadiths_book_chapter_idx');
            $table->index(['hadith_book_id', 'hadith_number'], 'am_hadiths_book_number_idx');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_hadiths');
    }
};
