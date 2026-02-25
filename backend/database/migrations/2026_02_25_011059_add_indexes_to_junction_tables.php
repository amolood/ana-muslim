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
        Schema::table('ana_muslim_item_category', function (Blueprint $table) {
            $table->index('category_id');
        });
        Schema::table('ana_muslim_item_author', function (Blueprint $table) {
            $table->index('author_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('junction_tables', function (Blueprint $table) {
            //
        });
    }
};
