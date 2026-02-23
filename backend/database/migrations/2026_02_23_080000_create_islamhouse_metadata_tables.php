<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('islamhouse_endpoint_snapshots', function (Blueprint $table) {
            $table->id();
            $table->string('endpoint_slug', 191)->index();
            $table->string('endpoint_group', 191)->nullable()->index();
            $table->string('endpoint_name', 255);
            $table->string('method', 16)->default('GET');
            $table->text('request_url');
            $table->char('request_url_hash', 64)->unique();
            $table->unsignedSmallInteger('status_code')->nullable();
            $table->longText('payload')->nullable();
            $table->longText('raw_body')->nullable();
            $table->char('response_hash', 64)->nullable()->index();
            $table->timestamp('fetched_at')->nullable()->index();
            $table->timestamps();
        });

        Schema::create('islamhouse_site_sections', function (Blueprint $table) {
            $table->id();
            $table->string('language', 16)->default('ar');
            $table->string('block_name', 191);
            $table->string('section_type', 64)->nullable();
            $table->unsignedInteger('items_count')->default(0);
            $table->text('api_url')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();

            $table->unique(['language', 'block_name'], 'ih_site_sec_lang_block_uq');
        });

        Schema::create('islamhouse_languages', function (Blueprint $table) {
            $table->id();
            $table->string('language_code', 32)->unique();
            $table->string('name', 255)->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_language_terms', function (Blueprint $table) {
            $table->id();
            $table->string('language', 16);
            $table->string('term_key', 191);
            $table->longText('term_value')->nullable();
            $table->timestamps();

            $table->unique(['language', 'term_key'], 'ih_lang_terms_lang_key_uq');
            $table->index(['language'], 'ih_lang_terms_lang_idx');
        });

        Schema::create('islamhouse_available_languages', function (Blueprint $table) {
            $table->id();
            $table->string('scope_type', 32);
            $table->unsignedBigInteger('scope_id')->nullable();
            $table->string('context_language', 16)->nullable();
            $table->string('language_code', 32);
            $table->string('language_name', 255)->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();

            $table->unique(
                ['scope_type', 'scope_id', 'context_language', 'language_code'],
                'ih_av_lang_scope_lang_code_uq'
            );
            $table->index(['scope_type', 'scope_id'], 'ih_av_lang_scope_idx');
        });

        Schema::create('islamhouse_available_types', function (Blueprint $table) {
            $table->id();
            $table->string('scope_type', 32);
            $table->unsignedBigInteger('scope_id')->nullable();
            $table->string('language', 16)->nullable();
            $table->string('type', 100);
            $table->string('block_name', 191)->nullable();
            $table->unsignedInteger('items_count')->default(0);
            $table->text('api_url')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();

            $table->unique(['scope_type', 'scope_id', 'language', 'type'], 'ih_av_types_scope_lang_type_uq');
            $table->index(['scope_type', 'scope_id'], 'ih_av_types_scope_idx');
        });

        Schema::create('islamhouse_site_settings', function (Blueprint $table) {
            $table->id();
            $table->string('section', 64);
            $table->string('setting_key', 191);
            $table->string('language', 16)->nullable();
            $table->longText('setting_value')->nullable();
            $table->timestamps();

            $table->unique(['section', 'setting_key', 'language'], 'ih_site_settings_sec_key_lang_uq');
            $table->index(['section'], 'ih_site_settings_sec_idx');
        });

        Schema::create('islamhouse_footer_items', function (Blueprint $table) {
            $table->id();
            $table->string('external_key', 64)->unique();
            $table->unsignedBigInteger('source_id')->nullable()->index();
            $table->string('language', 16)->default('ar');
            $table->string('title', 500)->nullable();
            $table->text('description')->nullable();
            $table->longText('full_description')->nullable();
            $table->string('type', 100)->nullable();
            $table->string('add_type', 100)->nullable();
            $table->integer('order')->nullable();
            $table->boolean('enabled')->nullable();
            $table->text('url')->nullable();
            $table->longText('attachments')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_item_counts', function (Blueprint $table) {
            $table->id();
            $table->string('item_type', 100);
            $table->string('source_language', 16)->nullable();
            $table->string('translated_language', 16)->nullable();
            $table->unsignedInteger('items_count')->default(0);
            $table->longText('payload')->nullable();
            $table->timestamps();

            $table->unique(['item_type', 'source_language', 'translated_language'], 'ih_item_counts_type_lang_uq');
        });

        Schema::create('islamhouse_quran_categories', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('source_id')->unique();
            $table->string('language', 16)->default('ar');
            $table->string('title', 500)->nullable();
            $table->text('description')->nullable();
            $table->string('type', 100)->nullable();
            $table->boolean('has_children')->default(false);
            $table->text('api_url')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_quran_authors', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('source_id')->unique();
            $table->string('language', 16)->default('ar');
            $table->string('title', 500)->nullable();
            $table->string('type', 100)->nullable();
            $table->string('source_language', 16)->nullable();
            $table->string('translation_language', 16)->nullable();
            $table->unsignedInteger('recitations_count')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_quran_recitations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('source_id')->unique();
            $table->string('language', 16)->default('ar');
            $table->string('title', 500)->nullable();
            $table->text('description')->nullable();
            $table->text('primary_url')->nullable();
            $table->string('extension_type', 50)->nullable();
            $table->string('size', 50)->nullable();
            $table->longText('attachments')->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_quran_suras', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('source_id')->unique();
            $table->string('language', 16)->default('ar');
            $table->string('title', 255)->nullable();
            $table->text('url')->nullable();
            $table->string('extension_type', 50)->nullable();
            $table->string('size', 50)->nullable();
            $table->longText('payload')->nullable();
            $table->timestamps();
        });

        Schema::create('islamhouse_quran_category_author', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('category_source_id');
            $table->unsignedBigInteger('author_source_id');
            $table->timestamps();

            $table->unique(['category_source_id', 'author_source_id'], 'ih_quran_cat_author_uq');
        });

        Schema::create('islamhouse_quran_author_recitation', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('author_source_id');
            $table->unsignedBigInteger('recitation_source_id');
            $table->timestamps();

            $table->unique(['author_source_id', 'recitation_source_id'], 'ih_quran_author_recite_uq');
        });

        Schema::create('islamhouse_quran_sura_recitation', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('sura_source_id');
            $table->unsignedBigInteger('recitation_source_id');
            $table->timestamps();

            $table->unique(['sura_source_id', 'recitation_source_id'], 'ih_quran_sura_recite_uq');
        });

        if (Schema::hasTable('ana_muslim_items')) {
            // Keep earliest record per source_id before enforcing uniqueness.
            $duplicateSourceIds = DB::table('ana_muslim_items')
                ->select('source_id')
                ->whereNotNull('source_id')
                ->groupBy('source_id')
                ->havingRaw('COUNT(*) > 1')
                ->pluck('source_id');

            foreach ($duplicateSourceIds as $sourceId) {
                $keepId = DB::table('ana_muslim_items')->where('source_id', $sourceId)->min('id');
                DB::table('ana_muslim_items')
                    ->where('source_id', $sourceId)
                    ->where('id', '!=', $keepId)
                    ->delete();
            }

            Schema::table('ana_muslim_items', function (Blueprint $table) {
                $table->index('type', 'ana_muslim_items_type_idx');
                $table->unique('source_id', 'ana_muslim_items_source_id_uq');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('ana_muslim_items')) {
            Schema::table('ana_muslim_items', function (Blueprint $table) {
                $table->dropUnique('ana_muslim_items_source_id_uq');
                $table->dropIndex('ana_muslim_items_type_idx');
            });
        }

        Schema::dropIfExists('islamhouse_quran_sura_recitation');
        Schema::dropIfExists('islamhouse_quran_author_recitation');
        Schema::dropIfExists('islamhouse_quran_category_author');
        Schema::dropIfExists('islamhouse_quran_suras');
        Schema::dropIfExists('islamhouse_quran_recitations');
        Schema::dropIfExists('islamhouse_quran_authors');
        Schema::dropIfExists('islamhouse_quran_categories');
        Schema::dropIfExists('islamhouse_item_counts');
        Schema::dropIfExists('islamhouse_footer_items');
        Schema::dropIfExists('islamhouse_site_settings');
        Schema::dropIfExists('islamhouse_available_types');
        Schema::dropIfExists('islamhouse_available_languages');
        Schema::dropIfExists('islamhouse_language_terms');
        Schema::dropIfExists('islamhouse_languages');
        Schema::dropIfExists('islamhouse_site_sections');
        Schema::dropIfExists('islamhouse_endpoint_snapshots');
    }
};
