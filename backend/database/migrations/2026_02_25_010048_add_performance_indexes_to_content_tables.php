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
        Schema::table('ana_muslim_items', function (Blueprint $table) {
            $table->index('updated_at');
        });
        Schema::table('ana_muslim_categories', function (Blueprint $table) {
            $table->index('updated_at');
        });
        Schema::table('ana_muslim_authors', function (Blueprint $table) {
            $table->index('updated_at');
        });
        Schema::table('ana_muslim_attachments', function (Blueprint $table) {
            $table->index('updated_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('content_tables', function (Blueprint $table) {
            //
        });
    }
};
