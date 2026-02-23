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
        Schema::create('ana_muslim_hadith_books', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('source_book_id')->nullable()->index();
            $table->string('slug', 120)->unique();
            $table->string('source_group', 120)->default('by_book')->index();
            $table->string('title_ar', 500);
            $table->string('title_en', 500)->nullable();
            $table->string('author_ar', 500)->nullable();
            $table->string('author_en', 500)->nullable();
            $table->text('introduction_ar')->nullable();
            $table->text('introduction_en')->nullable();
            $table->unsignedInteger('total_chapters')->default(0);
            $table->unsignedInteger('total_hadith')->default(0);
            $table->longText('metadata_json')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ana_muslim_hadith_books');
    }
};
